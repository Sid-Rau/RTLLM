# RTL Generation Benchmark with Multiple LLM Providers

The `generate_rtl_benchmark.py` script has been updated to support multiple language model providers, making it easy to compare different LLMs for RTL generation tasks.

## Supported Providers

### 1. OpenAI
- **Models**: gpt-4o, gpt-4o-mini, gpt-4-turbo, gpt-3.5-turbo
- **API Key**: `OPENAI_API_KEY`
- **Package**: `langchain-openai`

### 2. Anthropic
- **Models**: claude-3-5-sonnet-20241022, claude-3-opus-20240229, claude-3-sonnet-20240229
- **API Key**: `ANTHROPIC_API_KEY`
- **Package**: `langchain-anthropic`

### 3. Google
- **Models**: gemini-1.5-pro, gemini-1.5-flash, gemini-pro
- **API Key**: `GOOGLE_API_KEY`
- **Package**: `langchain-google-genai`

### 4. Ollama (Local)
- **Models**: llama3.2, codellama, mistral, qwen2
- **API Key**: None (local installation)
- **Package**: `langchain-community`

## Installation

Install the required packages for your desired providers:

```bash
# For OpenAI
pip install langchain-openai

# For Anthropic
pip install langchain-anthropic

# For Google
pip install langchain-google-genai

# For Ollama
pip install langchain-community

# Or install all
pip install -r requirements_llm_providers.txt
```

## Setup

Set up your API keys as environment variables:

```bash
# For OpenAI
export OPENAI_API_KEY="your-openai-api-key"

# For Anthropic
export ANTHROPIC_API_KEY="your-anthropic-api-key"

# For Google
export GOOGLE_API_KEY="your-google-api-key"

# For Ollama (no API key needed, but ensure Ollama is running)
# ollama serve
```

## Usage

### Basic Usage (Default: OpenAI GPT-4o-mini)

```bash
python generate_rtl_benchmark.py
```

### Specify Provider and Model

```bash
# Use OpenAI GPT-4o
python generate_rtl_benchmark.py --provider openai --model gpt-4o

# Use Anthropic Claude
python generate_rtl_benchmark.py --provider anthropic --model claude-3-5-sonnet-20241022

# Use Google Gemini
python generate_rtl_benchmark.py --provider google --model gemini-1.5-pro

# Use Ollama (local)
python generate_rtl_benchmark.py --provider ollama --model codellama
```

### Customize Parameters

```bash
python generate_rtl_benchmark.py \
    --provider openai \
    --model gpt-4o-mini \
    --temperature 0.3 \
    --max-tokens 2000 \
    --pass-at-k 3 \
    --output-dir my_generated_rtl
```

### List Available Providers

```bash
python generate_rtl_benchmark.py --list-providers
```

## Command Line Options

- `--provider`: LLM provider to use (openai, anthropic, google, ollama)
- `--model`: Model name for the selected provider
- `--temperature`: Temperature for generation (0.0-1.0)
- `--max-tokens`: Maximum tokens for generation
- `--pass-at-k`: Number of attempts per design
- `--output-dir`: Output directory for generated RTL files
- `--list-providers`: List available providers and their models

## Output

The script generates:
1. **RTL Files**: Generated Verilog/SystemVerilog files in the output directory
2. **Results JSON**: Detailed results with pass@k statistics
3. **Console Output**: Real-time progress and summary statistics

Example output file: `rtl_generation_results_openai_gpt-4o-mini_20241201_143022.json`

## Example Results

```json
{
  "timestamp": "2024-12-01T14:30:22",
  "provider": "openai",
  "model": "gpt-4o-mini",
  "temperature": 0.5,
  "max_tokens": 4000,
  "pass_at_k": 5,
  "overall_stats": {
    "total_modules": 25,
    "total_attempts": 125,
    "total_passed": 89,
    "overall_pass_at_k": 0.712
  },
  "per_module_results": [...]
}
```

## Notes

- The script automatically handles provider-specific API calls and response formats
- Ollama requires a local installation and running `ollama serve`
- Different providers may have different rate limits and pricing
- The default model is now GPT-4o-mini for cost efficiency
- All generated code is automatically tested against the benchmark testbenches 