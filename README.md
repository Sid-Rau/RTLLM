# RTLLM: An Open-Source Benchmark for Design RTL Generation with Large Language Model

```
  _____    _______   _        _        __  __    __      __  ___         ___  
 |  __ \  |__   __| | |      | |      |  \/  |   \ \    / / |__ \       / _ \ 
 | |__) |    | |    | |      | |      | \  / |    \ \  / /     ) |     | | | |
 |  _  /     | |    | |      | |      | |\/| |     \ \/ /     / /      | | | |
 | | \ \     | |    | |____  | |____  | |  | |      \  /     / /_   _  | |_| |
 |_|  \_\    |_|    |______| |______| |_|  |_|       \/     |____| (_)  \___/ 
```

## About This Project

This project builds upon the original **RTLLM** benchmark by Yao Lu, Shang Liu, Qijun Zhang, and Zhiyao Xie from their paper "RTLLM: An Open-Source Benchmark for Design RTL Generation with Large Language Model" presented at ASP-DAC 2024.

### Original RTLLM Project

The original RTLLM benchmark provides:
- **50 carefully categorized RTL designs** across Arithmetic, Memory, Control, and Miscellaneous modules
- **Natural language descriptions** for each design
- **Comprehensive testbenches** for functional verification
- **Reference implementations** for quality comparison

**Citation for the original work:**
```
@inproceedings{lu2024rtllm,
  author={Lu, Yao and Liu, Shang and Zhang, Qijun and Xie, Zhiyao},
  booktitle={2024 29th Asia and South Pacific Design Automation Conference (ASP-DAC)}, 
  title={RTLLM: An Open-Source Benchmark for Design RTL Generation with Large Language Model}, 
  year={2024},
  pages={722-727},
  organization={IEEE}
}
```

### What This Project Adds

This enhanced version extends the original RTLLM benchmark with:

1. **Multi-LLM Support**: Automated RTL generation using various LLM providers (OpenAI, Anthropic, Ollama, Google, DeepSeek)
2. **Automated Benchmarking**: Comprehensive testing and evaluation pipeline
3. **Visual Reporting**: Automatic generation of statistics tables and detailed logs
4. **Easy Setup**: Virtual environment and dependency management
5. **Flexible Configuration**: Command-line options for different use cases

## Quick Start

### 1. Setup Environment

```bash
# Clone the repository
git clone https://github.com/Sid-Rau/RTLLM.git
cd RTLLM

# Install Icarus Verilog (required for RTL compilation and simulation)
# Ubuntu/Debian:
sudo apt-get install iverilog

# macOS:
brew install icarus-verilog

# Windows:
# Download from http://bleyer.org/icarus/

# Create and activate virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install Python dependencies
pip install -r requirements.txt
```

### 2. Set Up API Keys

You can set up API keys in two ways:

**Option 1: Using .env file (Recommended)**
```bash
# Copy the template and edit with your API keys
cp env_template.txt .env

# Edit .env file with your actual API keys
# OPENAI_API_KEY=your-actual-openai-key
# ANTHROPIC_API_KEY=your-actual-anthropic-key
# GOOGLE_API_KEY=your-actual-google-key
# DEEPSEEK_API_KEY=your-actual-deepseek-key
```

**Option 2: Using environment variables**
```bash
# For OpenAI
export OPENAI_API_KEY="your-openai-api-key"

# For Anthropic
export ANTHROPIC_API_KEY="your-anthropic-api-key"

# For Google
export GOOGLE_API_KEY="your-google-api-key"

# For DeepSeek
export DEEPSEEK_API_KEY="your-deepseek-api-key"

# For Ollama (no API key needed, but ensure Ollama is running)
ollama serve
```

### 3. Generate and Test RTL

```bash
# Run benchmark on existing generated RTL
python run_benchmark.py gpt-4o

# Generate RTL using default settings (OpenAI GPT-4o-mini)
python generate_rtl_benchmark.py

# Or specify a different model
python generate_rtl_benchmark.py --provider openai --model gpt-4o

# Get help for available options
python generate_rtl_benchmark.py --help
python run_benchmark.py --help
```

## Detailed Usage

### Benchmark Testing (`run_benchmark.py`)

Test generated RTL designs against the benchmark:

```bash
# Test all attempts in a directory
python run_benchmark.py gpt-4o

# Generate only per-module statistics table
python run_benchmark.py gpt-4o --no-overall-table

# Generate only overall statistics table
python run_benchmark.py gpt-4o --no-per-module-table
```

**Important**: The testbench files are located in the `benchmark/` folder. For testing to work correctly, your RTL files must follow the proper directory structure:

```
your_test_directory/
├── t1/
│   ├── adder_16bit.sv    # Must match module name exactly
│   ├── alu.sv
│   ├── counter_12.sv
│   └── ...
├── t2/
│   ├── adder_16bit.sv
│   ├── alu.sv
│   ├── counter_12.sv
│   └── ...
└── ...
```

Each RTL file must have the same name as its corresponding module (e.g., `adder_16bit.sv` contains the `adder_16bit` module) to match the testbench expectations.

### RTL Generation (`generate_rtl_benchmark.py`)

Generate RTL designs using various LLM providers:

```bash
# Basic usage with default settings
python generate_rtl_benchmark.py

# Specify provider and model
python generate_rtl_benchmark.py --provider anthropic --model claude-3-5-sonnet-20241022

# Customize generation parameters
python generate_rtl_benchmark.py \
    --provider openai \
    --model gpt-4o \
    --temperature 0.3 \
    --max-tokens 2000 \
    --pass-at-k 5 \
    --output-dir my_results

# List available providers and models
python generate_rtl_benchmark.py --list-providers

# Skip generation and only run benchmark
python generate_rtl_benchmark.py --skip-generation --output-dir existing_results
```

**Supported Providers:**
- **OpenAI**: gpt-4o, gpt-4o-mini, gpt-4-turbo, gpt-3.5-turbo
- **Anthropic**: claude-3-5-sonnet-20241022, claude-3-opus-20240229, claude-3-sonnet-20240229
- **Ollama**: llama3.2, codellama, mistral, qwen2
- **Google**: gemini-2.0-pro, gemini-2.0-flash, gemini-2.5-pro, gemini-2.5-flash
- **DeepSeek**: deepseek-chat, deepseek-coder

## Output and Results

### Generated Files Structure

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
└── ...
```

### Log Files and Reports

The system generates comprehensive logs and visual reports:

- **Console Output**: Real-time progress and summary statistics
- **Detailed Logs**: `logs/{model}/combined.log` - Complete test results
- **Visual Tables**: 
  - `logs/{model}/{model}_overall_stats_table.png` - Overall statistics
  - `logs/{model}/{model}_per_module_stats_table.png` - Per-module breakdown

### Example Results

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

## Benchmark Design Categories

The RTLLM benchmark includes 50 designs across four categories:

### 1. Arithmetic Modules
- Adders (8-bit, 16-bit, 32-bit, 64-bit pipelined)
- Multipliers (8-bit, 16-bit, Booth algorithm, pipelined)
- Dividers (16-bit, radix-2)
- Comparators (3-bit, 4-bit)
- Fixed-point arithmetic
- Floating-point multiplication

### 2. Control Modules
- Counters (12-bit, Johnson, ring, up-down)
- Finite State Machines
- Sequence detectors

### 3. Memory Modules
- FIFO (asynchronous)
- LIFO buffer
- RAM, ROM
- Shifters (barrel, right, LFSR)

### 4. Miscellaneous Modules
- Frequency dividers
- Edge detectors
- Pulse detectors
- Parallel/serial converters
- Synchronizers
- Traffic light controller
- RISC-V components (ALU, PE, instruction register)

## Dependencies

### Required System Tools
- **Python 3.8+**
- **Icarus Verilog** (for RTL compilation and simulation)
- **Make** (for running individual tests)

### Python Dependencies
- **langchain** - LLM integration framework
- **langchain-core** - Core langchain functionality
- **langchain-community** - Community integrations
- **tqdm** - Progress bars
- **matplotlib** - Table image generation (optional)

Install dependencies:
```bash
pip install -r requirements.txt
```

## Manual Testing (Original RTLLM Method)

You can still use the original RTLLM testing method:

1. **Replace design name** in the makefile:
   ```makefile
   TEST_DESIGN = adder_16bit
   ```

2. **Compile and test**:
   ```bash
   make vcs    # Compile
   make sim    # Run simulation
   make clean  # Clean up
   ```

3. **Check results**:
   ```
   ===========Your Design Passed===========
   ```

## Citation

If you use this enhanced RTLLM benchmark in your research, please cite both the original work and this project:

```bibtex
@inproceedings{lu2024rtllm,
  author={Lu, Yao and Liu, Shang and Zhang, Qijun and Xie, Zhiyao},
  booktitle={2024 29th Asia and South Pacific Design Automation Conference (ASP-DAC)}, 
  title={RTLLM: An Open-Source Benchmark for Design RTL Generation with Large Language Model}, 
  year={2024},
  pages={722-727},
  organization={IEEE}
}

@inproceedings{liu2024openllm,
  title={OpenLLM-RTL: Open Dataset and Benchmark for LLM-Aided Design RTL Generation(Invited)},
  author={Liu, Shang and Lu, Yao and Fang, Wenji and Li, Mengming and Xie, Zhiyao},
  booktitle={Proceedings of 2024 IEEE/ACM International Conference on Computer-Aided Design (ICCAD)},
  year={2024},
  organization={ACM}
}
```

## License

This project is licensed under the same terms as the original RTLLM benchmark. Please refer to the LICENSE file for details.

## Acknowledgments

This project builds upon the excellent work of the original RTLLM team from HKUST. We extend our gratitude to Yao Lu, Shang Liu, Qijun Zhang, and Zhiyao Xie for creating this comprehensive benchmark for LLM-aided RTL generation.
