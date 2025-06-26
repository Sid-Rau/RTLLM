import os
import time
import argparse
import threading
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import Optional
from dotenv import load_dotenv
from langchain.chat_models import init_chat_model
from langchain.prompts import PromptTemplate
from langchain.schema import HumanMessage, SystemMessage
from run_benchmark import build_benchmark_directory_list

# Load environment variables from .env file
load_dotenv()

# Model/provider configuration
PROVIDER = "openai"
MODEL_NAME = "gpt-4o-mini"
TEMPERATURE = 0.5
MAX_TOKENS = 4000

PROVIDER_CONFIGS = {
    "openai": {
        "api_key_env": "OPENAI_API_KEY",
        "provider": "openai",
        "models": ["gpt-4o", "gpt-4o-mini", "gpt-4-turbo", "gpt-3.5-turbo"]
    },
    "anthropic": {
        "api_key_env": "ANTHROPIC_API_KEY",
        "provider": "anthropic",
        "models": ["claude-3-5-sonnet-20241022", "claude-3-opus-20240229", "claude-3-sonnet-20240229"]
    },
    "ollama": {
        "api_key_env": None,
        "provider": "ollama",
        "models": ["llama3.2", "codellama", "mistral", "qwen2"]
    },
    "google": {
        "api_key_env": "GOOGLE_API_KEY",
        "provider": "google_genai",
        "models": ["gemini-2.0-pro", "gemini-2.0-flash", "gemini-2.5-pro", "gemini-2.5-flash"]
    },
    "deepseek": {
        "api_key_env": "DEEPSEEK_API_KEY",
        "provider": "deepseek",
        "models": ["deepseek-r1-0528", "deepseek-chat-v3-0324", "deepseek-chat"]
    },
    "openrouter": {
        "api_key_env": "OPENROUTER_API_KEY",
        "provider": "openai",
        "models": [
            "deepseek/deepseek-r1-0528:free",
            "deepseek/deepseek-chat-v3-0324:free",
            "deepseek/deepseek-chat:free",
            "openai/gpt-4o",
            "openai/gpt-4o-mini",
            "openai/gpt-3.5-turbo",
            "anthropic/claude-3-5-sonnet-20241022",
            "google/gemini-2.5-pro",
            "google/gemini-2.5-flash"
        ]
    }
}

PASS_AT_K = 5
OUTPUT_DIR = "generated_rtl"

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

SYSTEM_MESSAGE = "You are a professional Verilog designer. Provide only the Verilog code without any explanations, comments, or markdown formatting. The code should be ready to compile and test immediately."

# --- Utility Functions ---
def validate_provider_config(provider: str, model_name: str) -> None:
    if provider not in PROVIDER_CONFIGS:
        raise ValueError(f"Unsupported provider: {provider}. Available: {list(PROVIDER_CONFIGS.keys())}")
    config = PROVIDER_CONFIGS[provider]
    if config["api_key_env"] and not os.getenv(config["api_key_env"]):
        raise ValueError(f"{config['api_key_env']} environment variable not set for provider {provider}")
    if model_name not in config["models"]:
        print(f"Warning: Model {model_name} not in known models for {provider}. Available: {config['models']}")

def setup_langchain_client(provider: Optional[str] = None, model_name: Optional[str] = None, temperature: Optional[float] = None, max_tokens: Optional[int] = None):
    provider = provider or PROVIDER
    model_name = model_name or MODEL_NAME
    temperature = temperature if temperature is not None else TEMPERATURE
    max_tokens = max_tokens if max_tokens is not None else MAX_TOKENS
    validate_provider_config(provider, model_name)
    config = PROVIDER_CONFIGS[provider]
    kwargs = {"temperature": temperature, "max_tokens": max_tokens}
    if config["api_key_env"]:
        api_key = os.getenv(config["api_key_env"])
        if provider == "openai":
            kwargs["openai_api_key"] = api_key
        elif provider == "anthropic":
            kwargs["anthropic_api_key"] = api_key
        elif provider == "google":
            kwargs["google_api_key"] = api_key
        elif provider == "deepseek":
            kwargs["api_key"] = api_key
        elif provider == "openrouter":
            kwargs["openai_api_key"] = api_key
            kwargs["base_url"] = "https://openrouter.ai/api/v1"
    return init_chat_model(model_name, model_provider=config["provider"], **kwargs)

def read_design_description(benchmark_dir: str) -> Optional[str]:
    """Read the design description from a benchmark directory."""
    description_file = os.path.join(benchmark_dir, "design_description.txt")
    if os.path.exists(description_file):
        with open(description_file, 'r', encoding='utf-8') as f:
            return f.read().strip()
    return None

def extract_module_name_from_description(description: str) -> Optional[str]:
    """Extract the module name from the design description."""
    for line in description.split('\n'):
        if 'module name:' in line.lower() or 'module:' in line.lower():
            parts = line.split(':')
            if len(parts) >= 2:
                return parts[1].strip()
    return None

def generate_rtl_design(client, design_description: str, attempt: int = 1) -> Optional[str]:
    """Generate RTL design using the specified provider."""
    try:
        formatted_prompt = DESIGN_PROMPT_TEMPLATE.format(design_description=design_description)
        messages = [SystemMessage(content=SYSTEM_MESSAGE), HumanMessage(content=formatted_prompt)]
        response = client.invoke(messages)
        generated_code = response.content.strip()
        if generated_code.startswith('```'):
            lines = generated_code.split('\n')
            if len(lines) > 2:
                generated_code = '\n'.join(lines[1:-1])
        return generated_code
    except Exception as e:
        print(f"Error generating design (attempt {attempt}): {e}")
        return None

def save_generated_design(base_output_dir: str, module_name: str, attempt: int, code: str) -> str:
    """Save generated RTL design to file in the correct directory structure."""
    subdir = f"t{attempt}"
    output_dir = os.path.join(base_output_dir, subdir)
    os.makedirs(output_dir, exist_ok=True)
    filename = f"{module_name}.sv"
    filepath = os.path.join(output_dir, filename)
    with open(filepath, 'w') as f:
        f.write(code)
    return filepath

def generate_single_module(client, benchmark_dir: str, base_output_dir: str, attempt: int, module_index: int, total_modules: int) -> tuple[str, bool, str]:
    """
    Generate RTL for a single module. This function is designed to be used with threading.
    
    Args:
        client: LangChain client
        benchmark_dir: Path to benchmark directory
        base_output_dir: Base output directory
        attempt: Current attempt number
        module_index: Index of the module (for progress tracking)
        total_modules: Total number of modules
        
    Returns:
        tuple: (module_name, success, filepath_or_error)
    """
    module_name = os.path.basename(benchmark_dir)
    print(f"\n[{module_index}/{total_modules}] Processing: {module_name}")
    
    description = read_design_description(benchmark_dir)
    if not description:
        error_msg = f"No design description found for {module_name}"
        print(f"  {error_msg}")
        return module_name, False, error_msg
    
    extracted_name = extract_module_name_from_description(description)
    if extracted_name and extracted_name != module_name:
        print(f"  Warning: Module name mismatch. Expected: {module_name}, Found: {extracted_name}")
    
    print(f"  Generating {module_name}...")
    generated_code = generate_rtl_design(client, description, attempt)
    
    if generated_code:
        try:
            filepath = save_generated_design(base_output_dir, module_name, attempt, generated_code)
            print(f"    Saved to: {filepath}")
            return module_name, True, filepath
        except Exception as e:
            error_msg = f"Failed to save {module_name}: {e}"
            print(f"    {error_msg}")
            return module_name, False, error_msg
    else:
        error_msg = f"Failed to generate {module_name}"
        print(f"    {error_msg}")
        return module_name, False, error_msg

def test_client_connection(client, provider: str, model_name: str) -> bool:
    """
    Test the client connection with a simple prompt to ensure it's working.
    
    Args:
        client: LangChain client to test
        provider: Provider name for error messages
        model_name: Model name for error messages
        
    Returns:
        bool: True if connection is successful, False otherwise
    """
    try:
        print(f"Testing connection to {provider} with model {model_name}...")
        test_prompt = "Please respond with 'OK' if you can see this message."
        messages = [HumanMessage(content=test_prompt)]
        response = client.invoke(messages)
        
        if response and response.content:
            print(f"✓ Connection successful! Model responded: {response.content[:50]}...")
            return True
        else:
            print(f"✗ Connection failed: No response from model")
            return False
            
    except Exception as e:
        print(f"✗ Connection failed: {e}")
        return False

# --- Main Execution ---
def main():
    parser = argparse.ArgumentParser(description="RTL Generation Benchmark with Multiple LLM Providers")
    parser.add_argument("--provider", choices=list(PROVIDER_CONFIGS.keys()), default=PROVIDER, help=f"LLM provider to use (default: {PROVIDER})")
    parser.add_argument("--model", default=MODEL_NAME, help=f"Model name to use (default: {MODEL_NAME})")
    parser.add_argument("--temperature", type=float, default=TEMPERATURE, help=f"Temperature for generation (default: {TEMPERATURE})")
    parser.add_argument("--max-tokens", type=int, default=MAX_TOKENS, help=f"Maximum tokens for generation (default: {MAX_TOKENS})")
    parser.add_argument("--pass-at-k", type=int, default=PASS_AT_K, help=f"Number of attempts per design (default: {PASS_AT_K})")
    parser.add_argument("--output-dir", default=None, help=f"Base output directory for generated RTL (creates t1, t2, etc. subdirectories). If not set, uses the model name.")
    parser.add_argument("--detailed", action="store_true", help="Enable detailed output and log file generation")
    parser.add_argument("--list", action="store_true", help="List available providers and their models")
    parser.add_argument("--skip-generation", action="store_true", help="Skip RTL generation and only run the benchmark on the output directory.")
    parser.add_argument("--workers", type=int, default=4, help="Number of worker threads for concurrent generation (default: 4)")
    args = parser.parse_args()

    if args.list:
        print("Available providers and models:")
        print("=" * 50)
        for provider, config in PROVIDER_CONFIGS.items():
            print(f"\n{provider.upper()}:")
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

    if args.output_dir is None:
        args.output_dir = args.model

    if args.skip_generation:
        print(f"Skipping RTL generation. Running benchmark on: {args.output_dir}")
        from run_benchmark import run_benchmark
        run_benchmark(os.path.abspath(args.output_dir), print_summary=True, print_detailed=args.detailed, write_log_file=args.detailed)
        if args.detailed:
            print(f"\nBenchmark completed. Detailed results and logs written to logs/ directory.")
        else:
            print(f"\nBenchmark completed. Use --detailed flag for detailed output and log files.")
        print(f"Generated RTL files saved to: {args.output_dir}/ (in t1, t2, etc. subdirectories)")
        return

    # Validate configuration and connection before starting generation
    print("\n" + "="*60)
    print("VALIDATION PHASE")
    print("="*60)
    
    # Test client connection
    try:
        client = setup_langchain_client(
            provider=args.provider,
            model_name=args.model,
            temperature=args.temperature,
            max_tokens=args.max_tokens
        )
        print(f"LangChain client initialized with provider: {args.provider}, model: {args.model}")
    except Exception as e:
        print(f"\n✗ Failed to setup LangChain client: {e}")
        print("Please check your API keys and provider configuration.")
        return
    
    if not test_client_connection(client, args.provider, args.model):
        print("\n✗ Connection test failed! Please check your API keys and network connection.")
        return
    
    print("\n✓ Connection validation passed! Starting RTL generation...")

    benchmark_dirs = build_benchmark_directory_list()
    print(f"Found {len(benchmark_dirs)} benchmark directories")
    os.makedirs(args.output_dir, exist_ok=True)

    for attempt in range(1, args.pass_at_k + 1):
        print(f"\n{'='*60}")
        print(f"GENERATING ATTEMPT {attempt} (t{attempt})")
        print(f"{'='*60}")
        subdir = f"t{attempt}"
        attempt_output_dir = os.path.join(args.output_dir, subdir)
        os.makedirs(attempt_output_dir, exist_ok=True)
        
        # Use ThreadPoolExecutor for concurrent generation
        with ThreadPoolExecutor(max_workers=args.workers) as executor:
            # Submit all tasks
            future_to_module = {}
            for i, benchmark_dir in enumerate(benchmark_dirs):
                future = executor.submit(
                    generate_single_module,
                    client,
                    benchmark_dir,
                    args.output_dir,
                    attempt,
                    i + 1,
                    len(benchmark_dirs)
                )
                future_to_module[future] = benchmark_dir
            
            # Collect results as they complete
            successful_generations = 0
            failed_generations = 0
            
            for future in as_completed(future_to_module):
                module_name, success, result = future.result()
                if success:
                    successful_generations += 1
                else:
                    failed_generations += 1
                
                # Print progress
                completed = successful_generations + failed_generations
                print(f"\nProgress: {completed}/{len(benchmark_dirs)} completed "
                      f"(✓ {successful_generations}, ✗ {failed_generations})")
        
        print(f"\nAttempt {attempt} completed: {successful_generations} successful, {failed_generations} failed")
        time.sleep(1)  # Brief pause between attempts

    print(f"\n{'='*60}")
    print("RUNNING BENCHMARK ON ALL ATTEMPTS")
    print(f"{'='*60}")
    from run_benchmark import run_benchmark
    run_benchmark(os.path.abspath(args.output_dir), print_summary=True, print_detailed=args.detailed, write_log_file=args.detailed)
    if args.detailed:
        print(f"\nBenchmark completed. Detailed results and logs written to logs/ directory.")
    else:
        print(f"\nBenchmark completed. Use --detailed flag for detailed output and log files.")
    print(f"Generated RTL files saved to: {args.output_dir}/ (in t1, t2, etc. subdirectories)")

if __name__ == "__main__":
    main() 