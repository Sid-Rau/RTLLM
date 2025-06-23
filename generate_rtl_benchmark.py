import os
import json
import time
import random
import argparse
from typing import List, Dict, Any, Optional, Union
from datetime import datetime

# LangChain imports
from langchain.prompts import PromptTemplate
from langchain.schema import HumanMessage, SystemMessage, BaseMessage

# Chat model imports
try:
    from langchain_openai import ChatOpenAI
    OPENAI_AVAILABLE = True
except ImportError:
    OPENAI_AVAILABLE = False
    ChatOpenAI = None

try:
    from langchain_anthropic import ChatAnthropic
    ANTHROPIC_AVAILABLE = True
except ImportError:
    ANTHROPIC_AVAILABLE = False
    ChatAnthropic = None

try:
    from langchain_google_genai import ChatGoogleGenerativeAI
    GOOGLE_AVAILABLE = True
except ImportError:
    GOOGLE_AVAILABLE = False
    ChatGoogleGenerativeAI = None

try:
    from langchain_community.chat_models import Ollama
    OLLAMA_AVAILABLE = True
except ImportError:
    OLLAMA_AVAILABLE = False
    Ollama = None

from run_benchmark import build_benchmark_directory_list, test_file, compile_module_stats, pretty_print_module_stats, write_combined_stats_to_log

# =============================================================================
# CONFIGURATION
# =============================================================================

# Model configuration
PROVIDER = "openai"  # Options: "openai", "anthropic", "google", "ollama"
MODEL_NAME = "gpt-4o-mini"  # Model name for the selected provider
TEMPERATURE = 0.5
MAX_TOKENS = 4000

# Provider-specific configurations
PROVIDER_CONFIGS = {
    "openai": {
        "api_key_env": "OPENAI_API_KEY",
        "available": OPENAI_AVAILABLE,
        "models": ["gpt-4o", "gpt-4o-mini", "gpt-4-turbo", "gpt-3.5-turbo"],
        "class": ChatOpenAI
    },
    "anthropic": {
        "api_key_env": "ANTHROPIC_API_KEY", 
        "available": ANTHROPIC_AVAILABLE,
        "models": ["claude-3-5-sonnet-20241022", "claude-3-opus-20240229", "claude-3-sonnet-20240229"],
        "class": ChatAnthropic
    },
    "google": {
        "api_key_env": "GOOGLE_API_KEY",
        "available": GOOGLE_AVAILABLE,
        "models": ["gemini-1.5-pro", "gemini-1.5-flash", "gemini-pro"],
        "class": ChatGoogleGenerativeAI
    },
    "ollama": {
        "api_key_env": None,  # Ollama doesn't use API keys
        "available": OLLAMA_AVAILABLE,
        "models": ["llama3.2", "codellama", "mistral", "qwen2"],
        "class": Ollama
    }
}

# Benchmark configuration
PASS_AT_K = 5  # Number of attempts per design
OUTPUT_DIR = "generated_rtl"

# LangChain prompt template
DESIGN_PROMPT_TEMPLATE = PromptTemplate(
    input_variables=["design_description"],
    template="""You are a professional Verilog designer. Please implement the following design based on the description:

{design_description}

Please provide ONLY the complete Verilog code for the module. Do not include any explanations, comments, or additional text outside the code. The code should be ready to compile and test immediately.

Requirements:
1. Use the exact module name specified in the description
2. Include all required input and output ports
3. Implement the functionality as described
4. Use standard Verilog syntax (SystemVerilog is also acceptable)
5. Ensure the code is syntactically correct and ready for compilation
6. Do not include any testbench code - only the design module

Here is the complete Verilog implementation:"""
)

SYSTEM_MESSAGE = """You are a professional Verilog designer. Provide only the Verilog code without any explanations, comments, or markdown formatting. The code should be ready to compile and test immediately."""

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

def validate_provider_config(provider: str, model_name: str) -> None:
    """Validate provider and model configuration."""
    if provider not in PROVIDER_CONFIGS:
        raise ValueError(f"Unsupported provider: {provider}. Available providers: {list(PROVIDER_CONFIGS.keys())}")
    
    config = PROVIDER_CONFIGS[provider]
    if not config["available"]:
        raise ValueError(f"Provider {provider} is not available. Please install the required package.")
    
    if config["api_key_env"] and not os.getenv(config["api_key_env"]):
        raise ValueError(f"{config['api_key_env']} environment variable not set for provider {provider}")
    
    if model_name not in config["models"]:
        print(f"Warning: Model {model_name} not in known models for {provider}. Available: {config['models']}")

def setup_langchain_client(provider: str = None, model_name: str = None, temperature: float = None, max_tokens: int = None):
    """Setup LangChain chat model for the specified provider."""
    # Use defaults if not provided
    provider = provider or PROVIDER
    model_name = model_name or MODEL_NAME
    temperature = temperature or TEMPERATURE
    max_tokens = max_tokens or MAX_TOKENS
    
    # Validate configuration
    validate_provider_config(provider, model_name)
    
    # Get provider config
    config = PROVIDER_CONFIGS[provider]
    chat_model_class = config["class"]
    
    # Create chat model instance
    if provider == "openai":
        chat_model = chat_model_class(
            model=model_name,
            temperature=temperature,
            max_tokens=max_tokens,
            openai_api_key=os.getenv("OPENAI_API_KEY")
        )
    elif provider == "anthropic":
        chat_model = chat_model_class(
            model=model_name,
            temperature=temperature,
            max_tokens=max_tokens,
            anthropic_api_key=os.getenv("ANTHROPIC_API_KEY")
        )
    elif provider == "google":
        chat_model = chat_model_class(
            model=model_name,
            temperature=temperature,
            max_tokens=max_tokens,
            google_api_key=os.getenv("GOOGLE_API_KEY")
        )
    elif provider == "ollama":
        chat_model = chat_model_class(
            model=model_name,
            temperature=temperature
        )
    else:
        raise ValueError(f"Unsupported provider: {provider}")
    
    return chat_model

def read_design_description(benchmark_dir: str) -> Optional[str]:
    """
    Read the design description from a benchmark directory.
    
    Args:
        benchmark_dir: Path to the benchmark directory
        
    Returns:
        Design description text or None if not found
    """
    description_file = os.path.join(benchmark_dir, "design_description.txt")
    if os.path.exists(description_file):
        with open(description_file, 'r', encoding='utf-8') as f:
            return f.read().strip()
    return None

def extract_module_name_from_description(description: str) -> Optional[str]:
    """
    Extract the module name from the design description.
    
    Args:
        description: Design description text
        
    Returns:
        Module name or None if not found
    """
    lines = description.split('\n')
    for line in lines:
        if 'module name:' in line.lower() or 'module:' in line.lower():
            # Extract the module name after the colon
            parts = line.split(':')
            if len(parts) >= 2:
                return parts[1].strip()
    return None

def generate_rtl_design(chat_model, design_description: str, attempt: int = 1) -> Optional[str]:
    """
    Generate RTL design using the specified chat model.
    
    Args:
        chat_model: LangChain chat model instance
        design_description: Design description text
        attempt: Attempt number (for logging)
        
    Returns:
        Generated Verilog code or None if failed
    """
    try:
        # Format the prompt
        formatted_prompt = DESIGN_PROMPT_TEMPLATE.format(design_description=design_description)
        
        # Create messages
        messages = [
            SystemMessage(content=SYSTEM_MESSAGE),
            HumanMessage(content=formatted_prompt)
        ]
        
        # Generate response using the chat model
        response = chat_model.invoke(messages)
        generated_code = response.content.strip()
        
        # Clean up the response - remove any markdown formatting
        if generated_code.startswith('```'):
            lines = generated_code.split('\n')
            if len(lines) > 2:
                # Remove first line (```verilog or similar) and last line (```)
                generated_code = '\n'.join(lines[1:-1])
        
        return generated_code
        
    except Exception as e:
        print(f"Error generating design (attempt {attempt}): {e}")
        return None

def save_generated_design(output_dir: str, module_name: str, attempt: int, code: str) -> str:
    """
    Save generated RTL design to file.
    
    Args:
        output_dir: Output directory
        module_name: Name of the module
        attempt: Attempt number
        code: Generated Verilog code
        
    Returns:
        Path to the saved file
    """
    os.makedirs(output_dir, exist_ok=True)
    filename = f"{module_name}_attempt_{attempt}.sv"
    filepath = os.path.join(output_dir, filename)
    
    with open(filepath, 'w') as f:
        f.write(code)
    
    return filepath

def run_pass_at_k_evaluation(benchmark_dir: str, generated_files: List[str]) -> Dict[str, Any]:
    """
    Run pass@k evaluation for a single design.
    
    Args:
        benchmark_dir: Benchmark directory containing testbench
        generated_files: List of generated RTL files to test
        
    Returns:
        Dictionary with evaluation results
    """
    results = {
        "module_name": os.path.basename(benchmark_dir),
        "total_attempts": len(generated_files),
        "passed_attempts": 0,
        "results": []
    }
    
    for i, filepath in enumerate(generated_files):
        print(f"  Testing attempt {i+1}/{len(generated_files)}: {os.path.basename(filepath)}")
        
        # Test the generated design
        test_result = test_file(filepath, benchmark_dir)
        results["results"].append({
            "attempt": i+1,
            "file": filepath,
            "status": test_result["status"],
            "passed": test_result["status"] == "test_passed"
        })
        
        if test_result["status"] == "test_passed":
            results["passed_attempts"] += 1
    
    results["pass_at_k"] = results["passed_attempts"] / results["total_attempts"] if results["total_attempts"] > 0 else 0
    return results

# =============================================================================
# MAIN EXECUTION
# =============================================================================

def main():
    """Main function to run the RTL generation benchmark."""
    # Parse command line arguments
    parser = argparse.ArgumentParser(description="RTL Generation Benchmark with Multiple LLM Providers")
    parser.add_argument("--provider", choices=list(PROVIDER_CONFIGS.keys()), default=PROVIDER,
                       help=f"LLM provider to use (default: {PROVIDER})")
    parser.add_argument("--model", default=MODEL_NAME,
                       help=f"Model name to use (default: {MODEL_NAME})")
    parser.add_argument("--temperature", type=float, default=TEMPERATURE,
                       help=f"Temperature for generation (default: {TEMPERATURE})")
    parser.add_argument("--max-tokens", type=int, default=MAX_TOKENS,
                       help=f"Maximum tokens for generation (default: {MAX_TOKENS})")
    parser.add_argument("--pass-at-k", type=int, default=PASS_AT_K,
                       help=f"Number of attempts per design (default: {PASS_AT_K})")
    parser.add_argument("--output-dir", default=OUTPUT_DIR,
                       help=f"Output directory for generated RTL (default: {OUTPUT_DIR})")
    parser.add_argument("--list-providers", action="store_true",
                       help="List available providers and their models")
    
    args = parser.parse_args()
    
    # Handle list providers option
    if args.list_providers:
        print("Available providers and models:")
        print("=" * 50)
        for provider, config in PROVIDER_CONFIGS.items():
            status = "✅ Available" if config["available"] else "❌ Not available"
            print(f"\n{provider.upper()} ({status}):")
            if config["api_key_env"]:
                print(f"  API Key: {config['api_key_env']}")
            for model in config["models"]:
                print(f"  - {model}")
        return
    
    print("Starting RTL Generation Benchmark")
    print("=" * 50)
    print(f"Provider: {args.provider}")
    print(f"Model: {args.model}")
    print(f"Temperature: {args.temperature}")
    print(f"Max Tokens: {args.max_tokens}")
    print(f"Pass@K: {args.pass_at_k}")
    print(f"Output Directory: {args.output_dir}")
    print("=" * 50)
    
    # Setup LangChain client
    try:
        chat_model = setup_langchain_client(
            provider=args.provider,
            model_name=args.model,
            temperature=args.temperature,
            max_tokens=args.max_tokens
        )
        print(f"LangChain chat model initialized with provider: {args.provider}, model: {args.model}")
    except Exception as e:
        print(f"Failed to setup LangChain chat model: {e}")
        return
    
    # Get benchmark directories
    benchmark_dirs = build_benchmark_directory_list()
    print(f"Found {len(benchmark_dirs)} benchmark directories")
    
    # Create output directory
    os.makedirs(args.output_dir, exist_ok=True)
    
    # Results storage
    all_results = []
    evaluation_results = []
    
    # Process each benchmark
    for i, benchmark_dir in enumerate(benchmark_dirs):
        module_name = os.path.basename(benchmark_dir)
        print(f"\n[{i+1}/{len(benchmark_dirs)}] Processing: {module_name}")
        
        # Read design description
        description = read_design_description(benchmark_dir)
        if not description:
            print(f"  No design description found for {module_name}")
            continue
        
        # Extract module name from description
        extracted_name = extract_module_name_from_description(description)
        if extracted_name and extracted_name != module_name:
            print(f"  Warning: Module name mismatch. Expected: {module_name}, Found: {extracted_name}")
        
        # Generate multiple attempts
        generated_files = []
        for attempt in range(1, args.pass_at_k + 1):
            print(f"  Generating attempt {attempt}/{args.pass_at_k}...")
            
            # Add some randomness to the prompt for diversity
            random_seed = random.randint(1, 1000)
            modified_description = f"{description}\n\nRandom seed for this attempt: {random_seed}"
            
            generated_code = generate_rtl_design(chat_model, modified_description, attempt)
            if generated_code:
                filepath = save_generated_design(args.output_dir, module_name, attempt, generated_code)
                generated_files.append(filepath)
                print(f"    Saved to: {filepath}")
            else:
                print(f"    Failed to generate attempt {attempt}")
            
            # Add delay to avoid rate limiting
            time.sleep(1)
        
        if generated_files:
            # Run evaluation
            print(f"  Running pass@{args.pass_at_k} evaluation...")
            eval_result = run_pass_at_k_evaluation(benchmark_dir, generated_files)
            evaluation_results.append(eval_result)
            
            print(f"  Results: {eval_result['passed_attempts']}/{eval_result['total_attempts']} passed "
                  f"(pass@{args.pass_at_k}: {eval_result['pass_at_k']:.2%})")
        else:
            print(f"  No successful generations for {module_name}")
    
    # Compile overall statistics
    print("\n" + "=" * 50)
    print("OVERALL RESULTS")
    print("=" * 50)
    
    total_modules = len(evaluation_results)
    total_attempts = sum(r["total_attempts"] for r in evaluation_results)
    total_passed = sum(r["passed_attempts"] for r in evaluation_results)
    overall_pass_at_k = total_passed / total_attempts if total_attempts > 0 else 0
    
    print(f"Total modules tested: {total_modules}")
    print(f"Total attempts: {total_attempts}")
    print(f"Total passed: {total_passed}")
    print(f"Overall pass@{args.pass_at_k}: {overall_pass_at_k:.2%}")
    
    # Save detailed results
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    results_file = f"rtl_generation_results_{args.provider}_{args.model}_{timestamp}.json"
    
    with open(results_file, 'w') as f:
        json.dump({
            "timestamp": datetime.now().isoformat(),
            "provider": args.provider,
            "model": args.model,
            "temperature": args.temperature,
            "max_tokens": args.max_tokens,
            "pass_at_k": args.pass_at_k,
            "overall_stats": {
                "total_modules": total_modules,
                "total_attempts": total_attempts,
                "total_passed": total_passed,
                "overall_pass_at_k": overall_pass_at_k
            },
            "per_module_results": evaluation_results
        }, f, indent=2)
    
    print(f"\nDetailed results saved to: {results_file}")
    print(f"Generated RTL files saved to: {args.output_dir}/")

if __name__ == "__main__":
    main() 