# RTL Generation Benchmark with Multiple LLM Providers

The `generate_rtl_benchmark.py` script has been updated to support multiple language model providers, making it easy to compare different LLMs for RTL generation tasks.

## Supported Providers

### 1. OpenAI
- **Models**: gpt-4o, gpt-4o-mini, gpt-4-turbo, gpt-3.5-turbo
- **API Key**: `OPENAI_API_KEY`
- **Package**: `langchain-community`

### 2. Anthropic
- **Models**: claude-3-5-sonnet-20241022, claude-3-opus-20240229, claude-3-sonnet-20240229
- **API Key**: `ANTHROPIC_API_KEY`
- **Package**: `langchain-community`

### 3. Ollama (Local)
- **Models**: llama3.2, codellama, mistral, qwen2
- **API Key**: None (local installation)
- **Package**: `langchain-community`

## Installation

Install the required packages:

```bash
# Install LangChain dependencies
pip install langchain langchain-community

# Or install from requirements file
pip install -r requirements_llm_providers.txt
```

## Setup

Set up your API keys as environment variables:

```bash
# For OpenAI
export OPENAI_API_KEY="your-openai-api-key"

# For Anthropic
export ANTHROPIC_API_KEY="your-anthropic-api-key"

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

- `--provider`: LLM provider to use (openai, anthropic, ollama)
- `--model`: Model name for the selected provider
- `--temperature`: Temperature for generation (0.0-1.0)
- `--max-tokens`: Maximum tokens for generation
- `--pass-at-k`: Number of attempts per design
- `--output-dir`: Base output directory for generated RTL files (creates t1, t2, etc. subdirectories)
- `--list-providers`: List available providers and their models

## Execution Flow

The script follows a sequential approach for efficiency:

1. **Generate t1**: Creates all modules for the first attempt in `t1/` directory
2. **Test t1**: Immediately tests all generated files in `t1/`
3. **Generate t2**: Creates all modules for the second attempt in `t2/` directory  
4. **Test t2**: Immediately tests all generated files in `t2/`
5. **Continue**: Repeats for t3, t4, etc. until all attempts are complete

This approach is more efficient than generating all attempts for each module separately.

## Output Structure

The script generates files in a directory structure that matches the `_chatgpt4` format:

```
generated_rtl/
├── t1/
│   ├── adder_16bit.sv
│   ├── alu.sv
│   ├── counter_12.sv
│   └── ...
├── t2/
│   ├── adder_16bit.sv
│   ├── alu.sv
│   ├── counter_12.sv
│   └── ...
├── t3/
│   └── ...
└── ...
```

- **Subdirectories**: `t1`, `t2`, `t3`, etc. represent different attempts
- **File Names**: Exactly match the module names (e.g., `adder_16bit.sv`, `alu.sv`)
- **File Extensions**: Use `.sv` extension for SystemVerilog files

## Output

The script generates:
1. **RTL Files**: Generated SystemVerilog files in the output directory
2. **Console Output**: Real-time progress and summary statistics using run_benchmark functions
3. **Log Files**: Comprehensive test results using run_benchmark's logging system

Example output file: `rtl_generation_openai_gpt-4o-mini_20241201_143022.log`

## Example Results

The script uses the same output format as `run_benchmark.py`:

```
Module                  Runs  Passed  Failed  CompileErr    SimErr   Timeout  PassRate   Functional
adder_16bit                5       3       2           0         0         0     60.0% ✅
alu                        5       4       1           0         0         0     80.0% ✅
counter_12                 5       2       3           0         0         0     40.0% ✅
...

Overall statistics across all modules and all runs:
------------------------------------------------------------
Total runs:         125
Total passed:        89
Total failed:        36
Total compile err:    0
Total sim err:       30
Total timeouts:       6
Overall pass rate:  71.2%
Functional modules: 25 / 25  (✅)
Syntax correct:     25 / 25  (✅)
```

## Notes

- The script uses standard LangChain chat models from `langchain_community`
- All testing and result recording uses the proven `run_benchmark.py` functions
- Ollama requires a local installation and running `ollama serve`
- Different providers may have different rate limits and pricing
- The default model is now GPT-4o-mini for cost efficiency
- All generated code is automatically tested against the benchmark testbenches 