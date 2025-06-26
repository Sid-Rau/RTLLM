"""
RTL Benchmark Runner

This script runs benchmarks on generated RTL files and provides comprehensive reporting.
It includes functionality to:
- Test RTL files against benchmark testbenches
- Generate detailed logs of test results
- Compile statistics across multiple test runs
- Generate visual table images of overall statistics

Dependencies:
- iverilog: For RTL compilation and simulation
- tqdm: For progress bars
- matplotlib: For table image generation
"""

import os
import subprocess
import signal
import sys
from tqdm import tqdm
from datetime import datetime
from typing import List, Dict, Optional, Any, Union
import argparse
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.table import Table

# --- Configuration ---
CATEGORIES = ['Arithmetic', 'Control', 'Memory', 'Miscellaneous']
COMPILE_TIMEOUT = 1
SIM_TIMEOUT = 1

# --- Utility Functions ---
class TimeoutError(Exception):
    """Custom exception for timeout errors."""
    pass

def timeout_handler(signum: int, frame: Any) -> None:
    """
    Signal handler for timeout events.
    
    Args:
        signum: Signal number
        frame: Current stack frame
        
    Raises:
        TimeoutError: When timeout signal is received
    """
    raise TimeoutError("Operation timed out")

def run_with_timeout(cmd: List[str], timeout: int, description: str, cwd: Optional[str] = None) -> subprocess.CompletedProcess:
    """
    Run a command with a timeout limit.
    
    Args:
        cmd: Command to run as a list of strings
        timeout: Timeout in seconds
        description: Description of the operation for error messages
        cwd: Working directory for the command (optional)
        
    Returns:
        subprocess.CompletedProcess: Result of the command execution
        
    Raises:
        TimeoutError: If the command times out
        Exception: If any other error occurs during execution
    """
    try:
        signal.signal(signal.SIGALRM, timeout_handler)
        signal.alarm(timeout)
        result = subprocess.run(cmd, capture_output=True, text=True, cwd=cwd)
        signal.alarm(0)
        return result
    except TimeoutError:
        try:
            subprocess.run(['pkill', '-f', ' '.join(cmd)], capture_output=True)
        except:
            pass
        raise TimeoutError(f"{description} timed out after {timeout} seconds")
    except Exception as e:
        signal.alarm(0)
        raise e

def find_leaf_directories(root_path: str) -> List[str]:
    """
    Find all leaf directories (directories containing files) in a directory tree.
    
    Args:
        root_path: Root directory to search from
        
    Returns:
        List[str]: List of paths to leaf directories
    """
    leaf_dirs: List[str] = []
    if os.path.exists(root_path):
        for item in os.listdir(root_path):
            item_path = os.path.join(root_path, item)
            if os.path.isdir(item_path):
                has_files = any(os.path.isfile(os.path.join(item_path, subitem)) for subitem in os.listdir(item_path))
                if has_files:
                    leaf_dirs.append(item_path)
                else:
                    leaf_dirs.extend(find_leaf_directories(item_path))
    return leaf_dirs

def build_benchmark_directory_list() -> List[str]:
    """
    Build a list of all benchmark directories by searching through categories.
    
    Returns:
        List[str]: List of paths to benchmark directories
    """
    path = os.path.join(os.getcwd(), "benchmark")
    dir_list: List[str] = []
    for cat in CATEGORIES:
        cat_path = os.path.join(path, cat)
        if os.path.exists(cat_path):
            dir_list.extend(find_leaf_directories(cat_path))
    return dir_list

def test_file(rtl_file_path: str, benchmark_path: str) -> dict:
    """
    Test a single RTL file against its corresponding benchmark testbench.
    
    Args:
        rtl_file_path: Path to the RTL file to test
        benchmark_path: Path to the benchmark directory containing testbench
        
    Returns:
        dict: Test results containing status, stdout, stderr, and return codes
    """
    result = {
        "status": "unknown",
        "compile_stdout": "",
        "compile_stderr": "",
        "sim_stdout": "",
        "sim_stderr": "",
        "returncode_compile": None,
        "returncode_sim": None
    }
    module_name = os.path.basename(benchmark_path)
    simv_name = f'simv_{module_name}'
    compile_cmd = ['iverilog', '-o', simv_name, '-g2012', os.path.join(benchmark_path, 'testbench.v'), rtl_file_path]
    try:
        compile_result = run_with_timeout(compile_cmd, COMPILE_TIMEOUT, "Compilation", cwd=benchmark_path)
        result["compile_stdout"] = compile_result.stdout
        result["compile_stderr"] = compile_result.stderr
        result["returncode_compile"] = compile_result.returncode
    except TimeoutError as e:
        result["compile_stderr"] = str(e)
        result["status"] = "timeout"
        return result
    if compile_result.returncode != 0:
        result["status"] = "compile_error"
        return result
    sim_cmd = ['vvp', simv_name]
    try:
        sim_result = run_with_timeout(sim_cmd, SIM_TIMEOUT, "Simulation", cwd=benchmark_path)
        result["sim_stdout"] = sim_result.stdout
        result["sim_stderr"] = sim_result.stderr
        result["returncode_sim"] = sim_result.returncode
    except TimeoutError as e:
        result["sim_stderr"] = str(e)
        result["status"] = "timeout"
        subprocess.run(['rm', os.path.join(benchmark_path, simv_name)], capture_output=True)
        return result
    subprocess.run(['rm', os.path.join(benchmark_path, simv_name)], capture_output=True)
    if sim_result.returncode != 0:
        result["status"] = "simulation_error"
        return result
    success_patterns = [
        "===========Your Design Passed===========",
        "=========== Your Design Passed ==========="
    ]
    test_passed = any(pattern in sim_result.stdout for pattern in success_patterns)
    result["status"] = "test_passed" if test_passed else "test_failed"
    return result

def write_results_to_log(result_dict: dict, rtl_file_dir: str, log_file_path: Optional[str] = None, filename_prefix: Optional[str] = None, logs_dir: str = "logs") -> str:
    """
    Write test results to a log file with detailed statistics and error information.
    
    Args:
        result_dict: Dictionary containing test results for each module
        rtl_file_dir: Directory containing the RTL files that were tested
        log_file_path: Path for the log file (optional, auto-generated if not provided)
        filename_prefix: Prefix for the log filename (optional)
        logs_dir: Directory to store log files
        
    Returns:
        str: Path to the created log file
    """
    if filename_prefix is None:
        filename_prefix = os.path.basename(os.path.dirname(rtl_file_dir))
    model_logs_dir = os.path.join(logs_dir, filename_prefix)
    os.makedirs(model_logs_dir, exist_ok=True)
    attempt = os.path.basename(rtl_file_dir)
    if log_file_path is None:
        log_file_path = f"{attempt}.log"
    if not os.path.dirname(log_file_path):
        log_file_path = os.path.join(model_logs_dir, log_file_path)
    with open(log_file_path, 'w') as log_file:
        log_file.write("=" * 80 + "\n")
        log_file.write("RTL BENCHMARK TEST RESULTS\n")
        log_file.write("=" * 80 + "\n")
        log_file.write(f"Test Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        log_file.write(f"RTL Directory: {rtl_file_dir}\n")
        log_file.write(f"Total Modules Tested: {len(result_dict)}\n")
        log_file.write("\n")
        passed = sum(1 for result in result_dict.values() if result["status"] == "test_passed")
        failed = sum(1 for result in result_dict.values() if result["status"] == "test_failed")
        compile_errors = sum(1 for result in result_dict.values() if result["status"] == "compile_error")
        sim_errors = sum(1 for result in result_dict.values() if result["status"] == "simulation_error")
        timeouts = sum(1 for result in result_dict.values() if result["status"] == "timeout")
        log_file.write("SUMMARY STATISTICS\n")
        log_file.write("-" * 40 + "\n")
        log_file.write(f"Passed: {passed}\n")
        log_file.write(f"Failed: {failed}\n")
        log_file.write(f"Compile Errors: {compile_errors}\n")
        log_file.write(f"Simulation Errors: {sim_errors}\n")
        log_file.write(f"Timeouts: {timeouts}\n")
        log_file.write(f"Success Rate: {(passed/len(result_dict)*100):.1f}%\n")
        log_file.write("\n")
        log_file.write("DETAILED RESULTS\n")
        log_file.write("-" * 40 + "\n")
        status_groups = {
            "test_passed": [],
            "test_failed": [],
            "compile_error": [],
            "simulation_error": [],
            "timeout": []
        }
        for module_name, result in result_dict.items():
            status_groups[result["status"]].append((module_name, result))
        for status, modules in status_groups.items():
            if modules:
                log_file.write(f"\n{status.upper().replace('_', ' ')} ({len(modules)} modules):\n")
                log_file.write("-" * 30 + "\n")
                for module_name, result in modules:
                    log_file.write(f"  {module_name}\n")
                    if result["status"] != "test_passed":
                        if result["compile_stderr"]:
                            log_file.write(f"    Compile Error: {result['compile_stderr'].strip()}\n")
                        if result["sim_stderr"]:
                            log_file.write(f"    Simulation Error: {result['sim_stderr'].strip()}\n")
                        if result["compile_stdout"]:
                            log_file.write(f"    Compile Output: {result['compile_stdout'].strip()}\n")
                        if result["sim_stdout"]:
                            log_file.write(f"    Simulation Output: {result['sim_stdout'].strip()}\n")
        log_file.write("\n" + "=" * 80 + "\n")
        log_file.write("END OF TEST RESULTS\n")
        log_file.write("=" * 80 + "\n")
    print(f"Results written to: {log_file_path}")
    return log_file_path

def test_all(
    rtl_file_dir: str,
    print_summary: bool = False,
    print_detailed: bool = False,
    write_log_file: bool = False,
    logs_dir: str = "logs"
) -> dict | None:
    """
    Test all RTL files in a directory against their corresponding benchmarks.
    
    Args:
        rtl_file_dir: Directory containing RTL files to test
        print_summary: Whether to print summary statistics to console
        print_detailed: Whether to print detailed results to console
        write_log_file: Whether to write results to a log file
        logs_dir: Directory to store log files
        
    Returns:
        dict | None: Dictionary containing test results for each module, or None if directory doesn't exist
    """
    if not os.path.isdir(rtl_file_dir):
        if print_summary:
            print(f"Directory {rtl_file_dir} does not exist.")
        return None
    benchmark_dirs: List[str] = build_benchmark_directory_list()
    rtl_files_to_test: List[Any] = []
    for rtl_file in os.listdir(rtl_file_dir):
        rtl_file_path = os.path.join(rtl_file_dir, rtl_file)
        if not os.path.isfile(rtl_file_path):
            continue
        if not rtl_file.endswith(('.v', '.sv')):
            continue
        for dir in benchmark_dirs:
            module_name = os.path.basename(dir)
            rtl_file_base = os.path.splitext(rtl_file)[0]
            if rtl_file_base == module_name:
                rtl_files_to_test.append((rtl_file_path, dir, module_name))
                break
    result_dict: Dict[str, Dict[str, Union[str, int, None]]] = dict()
    with tqdm(total=len(rtl_files_to_test), desc="Testing RTL files", unit="file", disable=not print_summary) as pbar:
        for rtl_file_path, benchmark_dir, module_name in rtl_files_to_test:
            if print_summary:
                pbar.set_description(f"Testing {module_name}")
            result_dict[module_name] = test_file(rtl_file_path, benchmark_dir)
            pbar.update(1)
    if print_summary:
        print(f"\n=== Test Results Summary ===")
        print(f"Total modules tested: {len(result_dict)}")
        passed = sum(1 for result in result_dict.values() if result["status"] == "test_passed")
        failed = sum(1 for result in result_dict.values() if result["status"] == "test_failed")
        compile_errors = sum(1 for result in result_dict.values() if result["status"] == "compile_error")
        sim_errors = sum(1 for result in result_dict.values() if result["status"] == "simulation_error")
        timeouts = sum(1 for result in result_dict.values() if result["status"] == "timeout")
        print(f"Passed: {passed}")
        print(f"Failed: {failed}")
        print(f"Compile errors: {compile_errors}")
        print(f"Simulation errors: {sim_errors}")
        print(f"Timeouts: {timeouts}")
    if print_detailed:
        print(f"\n=== Detailed Results ===")
        for module_name, result in result_dict.items():
            status_emoji = {
                "test_passed": "✅",
                "test_failed": "❌",
                "compile_error": "🔧",
                "simulation_error": "⚡",
                "timeout": "⏰"
            }.get(str(result["status"]), "❓")
            print(f"{status_emoji} {module_name}: {result['status']}")
            if result["status"] != "test_passed":
                if result["compile_stderr"]:
                    print(f"   Compile error: {str(result['compile_stderr']).strip()}")
                if result["sim_stderr"]:
                    print(f"   Simulation error: {str(result['sim_stderr']).strip()}")
    if write_log_file:
        write_results_to_log(result_dict, rtl_file_dir, filename_prefix=os.path.basename(os.path.dirname(rtl_file_dir)), logs_dir=logs_dir)
    return result_dict

def compile_module_stats(results_list: list[dict]) -> dict:
    """
    Compile statistics across multiple test runs for all modules.
    
    Args:
        results_list: List of result dictionaries from multiple test runs
        
    Returns:
        dict: Compiled statistics including per-module and overall statistics
    """
    stats = {}
    overall: Dict[str, Union[int, float]] = {
        "runs": 0,
        "test_passed": 0,
        "test_failed": 0,
        "compile_error": 0,
        "simulation_error": 0,
        "timeout": 0,
        "functional": 0,
        "syntax_correct": 0,
        "total_modules": 0
    }
    for result_dict in results_list:
        for module, result in result_dict.items():
            if module not in stats:
                stats[module] = {
                    "runs": 0,
                    "test_passed": 0,
                    "test_failed": 0,
                    "compile_error": 0,
                    "simulation_error": 0,
                    "timeout": 0,
                    "ever_compiled": False
                }
            stats[module]["runs"] += 1
            status = result.get("status")
            if status in stats[module]:
                stats[module][status] += 1
            if status != "compile_error":
                stats[module]["ever_compiled"] = True
            overall["runs"] += 1
            if status in overall:
                overall[status] += 1
    for module, s in stats.items():
        s["pass_rate"] = s["test_passed"] / s["runs"] if s["runs"] > 0 else 0.0
    overall["pass_rate"] = overall["test_passed"] / overall["runs"] if overall["runs"] > 0 else 0.0
    overall["functional"] = sum(1 for s in stats.values() if s["test_passed"] > 0)
    overall["syntax_correct"] = sum(1 for s in stats.values() if s.get("ever_compiled", False))
    overall["total_modules"] = len(stats)
    stats["OVERALL"] = overall
    return stats

def pretty_print_module_stats(stats: dict) -> None:
    """
    Print module statistics in a formatted table to the console.
    
    Args:
        stats: Dictionary containing compiled statistics
    """
    if not stats:
        print("No statistics to display.")
        return
    stats_copy = stats.copy()
    overall = stats_copy.pop("OVERALL", None)
    header = (
        f"{'Module':<20}  {'':<2}  {'Passed':>8}  {'Syntax':>6}  {'Failed':>6}  "
        f"{'Compile':>8}  {'Sim':>5}  {'Timeout':>7}"
    )
    print(header)
    print("-" * len(header))
    for module, s in sorted(stats_copy.items()):
        functional = '✓' if s['test_passed'] > 0 else '✗'
        passed_ratio = f"{s['test_passed']}/{s['runs']}"
        syntax_correct = '✓' if s.get('ever_compiled', False) else '✗'
        print(
            f"{module:<20}  {functional:<2}  {passed_ratio:>8}  {syntax_correct:>6}  {s['test_failed']:>6}  "
            f"{s['compile_error']:>8}  {s['simulation_error']:>5}  {s['timeout']:>7}"
        )
    if overall:
        print("\nOverall statistics across all modules and all runs:")
        print("-" * 60)
        print(f"Total runs:         {overall['runs']}")
        print(f"Total passed:       {overall['test_passed']}")
        print(f"Total failed:       {overall['test_failed']}")
        print(f"Total compile err:  {overall['compile_error']}")
        print(f"Total sim err:      {overall['simulation_error']}")
        print(f"Total timeouts:     {overall['timeout']}")
        print(f"Overall pass rate:  {overall['pass_rate']*100:.1f}%")
        print(f"Functional modules: {overall['functional']} / {overall['total_modules']}")
        print(f"Syntax correct:     {overall['syntax_correct']} / {overall['total_modules']}")

def write_combined_stats_to_log(results_list: list[dict], rtl_dirs: list[str], stats: dict, filename: Optional[str] = None, filename_prefix: Optional[str] = None, logs_dir: str = "logs") -> str:
    """
    Write combined statistics from multiple test runs to a comprehensive log file.
    
    Args:
        results_list: List of result dictionaries from multiple test runs
        rtl_dirs: List of RTL directories that were tested
        stats: Compiled statistics dictionary
        filename: Name for the log file (optional, auto-generated if not provided)
        filename_prefix: Prefix for the log filename (optional)
        logs_dir: Directory to store log files
        
    Returns:
        str: Path to the created log file
    """
    if filename_prefix is None:
        filename_prefix = "combined"
    model_logs_dir = os.path.join(logs_dir, filename_prefix)
    os.makedirs(model_logs_dir, exist_ok=True)
    if filename is None:
        filename = "combined.log"
    if not os.path.dirname(filename):
        filename = os.path.join(model_logs_dir, filename)
    stats_copy = stats.copy()
    overall = stats_copy.pop("OVERALL", None)
    total_modules = overall["total_modules"] if overall and "total_modules" in overall else len(stats_copy)
    with open(filename, 'w') as log_file:
        log_file.write("=" * 100 + "\n")
        log_file.write("COMBINED RTL BENCHMARK TEST RESULTS\n")
        log_file.write("=" * 100 + "\n")
        log_file.write(f"Test Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        log_file.write(f"Total Test Runs: {len(results_list)}\n")
        log_file.write(f"RTL Directories Tested: {', '.join([os.path.basename(d) for d in rtl_dirs])}\n")
        log_file.write(f"Total Modules Tested: {total_modules}\n")
        log_file.write("\n")
        if overall:
            log_file.write("SUMMARY STATISTICS\n")
            log_file.write("-" * 40 + "\n")
            log_file.write(f"Passed: {overall['test_passed']}\n")
            log_file.write(f"Failed: {overall['test_failed']}\n")
            log_file.write(f"Compile Errors: {overall['compile_error']}\n")
            log_file.write(f"Simulation Errors: {overall['simulation_error']}\n")
            log_file.write(f"Timeouts: {overall['timeout']}\n")
            log_file.write(f"Success Rate: {overall['pass_rate']*100:.1f}%\n")
            log_file.write("\n")
        if overall:
            log_file.write("OVERALL STATISTICS ACROSS ALL RUNS\n")
            log_file.write("-" * 60 + "\n")
            log_file.write(f"Total runs:         {overall['runs']}\n")
            log_file.write(f"Total passed:       {overall['test_passed']}\n")
            log_file.write(f"Total failed:       {overall['test_failed']}\n")
            log_file.write(f"Total compile err:  {overall['compile_error']}\n")
            log_file.write(f"Total sim err:      {overall['simulation_error']}\n")
            log_file.write(f"Total timeouts:     {overall['timeout']}\n")
            log_file.write(f"Overall pass rate:  {overall['pass_rate']*100:.1f}%\n")
            log_file.write(f"Functional modules: {overall['functional']} / {overall['total_modules']}\n")
            log_file.write(f"Syntax correct:     {overall['syntax_correct']} / {overall['total_modules']}\n")
            log_file.write("\n")
        log_file.write("PER-MODULE STATISTICS\n")
        log_file.write("-" * 60 + "\n")
        header = (
            f"{'Module':<20}  {'':<2}  {'Passed':>8}  {'Syntax':>6}  {'Failed':>6}  "
            f"{'Compile':>8}  {'Sim':>5}  {'Timeout':>7}\n"
        )
        log_file.write(header)
        log_file.write("-" * len(header) + "\n")
        for module, s in sorted(stats_copy.items()):
            functional = '✓' if s['test_passed'] > 0 else '✗'
            passed_ratio = f"{s['test_passed']}/{s['runs']}"
            syntax_correct = '✓' if s.get('ever_compiled', False) else '✗'
            log_file.write(
                f"{module:<20}  {functional:<2}  {passed_ratio:>8}  {syntax_correct:>6}  {s['test_failed']:>6}  "
                f"{s['compile_error']:>8}  {s['simulation_error']:>5}  {s['timeout']:>7}\n"
            )
        log_file.write("\n")
        for i, (result_dict, rtl_dir) in enumerate(zip(results_list, rtl_dirs)):
            if result_dict is None:
                continue
            log_file.write(f"DETAILED RESULTS - {os.path.basename(rtl_dir)}\n")
            log_file.write("=" * 80 + "\n")
            log_file.write(f"RTL Directory: {rtl_dir}\n")
            log_file.write(f"Total Modules Tested: {len(result_dict)}\n")
            passed = sum(1 for result in result_dict.values() if result["status"] == "test_passed")
            failed = sum(1 for result in result_dict.values() if result["status"] == "test_failed")
            compile_errors = sum(1 for result in result_dict.values() if result["status"] == "compile_error")
            sim_errors = sum(1 for result in result_dict.values() if result["status"] == "simulation_error")
            timeouts = sum(1 for result in result_dict.values() if result["status"] == "timeout")
            log_file.write(f"Passed: {passed}, Failed: {failed}, Compile Errors: {compile_errors}, "
                          f"Simulation Errors: {sim_errors}, Timeouts: {timeouts}\n")
            log_file.write(f"Success Rate: {(passed/len(result_dict)*100):.1f}%\n\n")
            status_groups = {
                "test_passed": [],
                "test_failed": [],
                "compile_error": [],
                "simulation_error": [],
                "timeout": []
            }
            for module_name, result in result_dict.items():
                status_groups[result["status"]].append((module_name, result))
            for status, modules in status_groups.items():
                if modules:
                    log_file.write(f"{status.upper().replace('_', ' ')} ({len(modules)} modules):\n")
                    log_file.write("-" * 40 + "\n")
                    for module_name, result in modules:
                        log_file.write(f"  {module_name}\n")
                        if result["status"] != "test_passed":
                            if result["compile_stderr"]:
                                log_file.write(f"    Compile Error: {result['compile_stderr'].strip()}\n")
                            if result["sim_stderr"]:
                                log_file.write(f"    Simulation Error: {result['sim_stderr'].strip()}\n")
                            if result["compile_stdout"]:
                                log_file.write(f"    Compile Output: {result['compile_stdout'].strip()}\n")
                            if result["sim_stdout"]:
                                log_file.write(f"    Simulation Output: {result['sim_stdout'].strip()}\n")
            log_file.write("\n" + "=" * 80 + "\n\n")
        log_file.write("=" * 100 + "\n")
        log_file.write("END OF COMBINED TEST RESULTS\n")
        log_file.write("=" * 100 + "\n")
    print(f"Combined results written to: {filename}")
    return filename

def generate_overall_stats_table_image(stats: dict, filename_prefix: str, logs_dir: str = "logs") -> str:
    """
    Generate a table image of overall statistics and save it to the model's log folder.
    
    Args:
        stats: Dictionary containing module statistics
        filename_prefix: Prefix for the output filename
        logs_dir: Directory to save the image
        
    Returns:
        str: Path to the generated image file, or empty string if no statistics available
    """
    if not stats or "OVERALL" not in stats:
        print("No overall statistics available for table generation.")
        return ""
    
    overall = stats["OVERALL"]
    
    # Create figure and axis
    fig, ax = plt.subplots(figsize=(12, 8))
    ax.axis('tight')
    ax.axis('off')
    
    # Prepare data for the table
    table_data = [
        ['Metric', 'Value', 'Percentage'],
        ['Total Runs', f"{overall['runs']:,}", '100%'],
        ['Test Passed', f"{overall['test_passed']:,}", f"{overall['pass_rate']*100:.1f}%"],
        ['Test Failed', f"{overall['test_failed']:,}", f"{overall['test_failed']/overall['runs']*100:.1f}%"],
        ['Compile Errors', f"{overall['compile_error']:,}", f"{overall['compile_error']/overall['runs']*100:.1f}%"],
        ['Simulation Errors', f"{overall['simulation_error']:,}", f"{overall['simulation_error']/overall['runs']*100:.1f}%"],
        ['Timeouts', f"{overall['timeout']:,}", f"{overall['timeout']/overall['runs']*100:.1f}%"],
        ['', '', ''],
        ['Functional Modules', f"{overall['functional']}/{overall['total_modules']}", f"{overall['functional']/overall['total_modules']*100:.1f}%"],
        ['Syntax Correct', f"{overall['syntax_correct']}/{overall['total_modules']}", f"{overall['syntax_correct']/overall['total_modules']*100:.1f}%"]
    ]
    
    # Create table
    table = ax.table(cellText=table_data, cellLoc='center', loc='center')
    table.auto_set_font_size(False)
    table.set_fontsize(12)
    table.scale(1.2, 2)
    
    # Style the table
    for i in range(len(table_data)):
        for j in range(len(table_data[0])):
            cell = table[(i, j)]
            if i == 0:  # Header row
                cell.set_facecolor('#2E86AB')
                cell.set_text_props(weight='bold', color='white')
            elif i == 7:  # Empty row for spacing
                cell.set_facecolor('#f0f0f0')
                cell.set_text_props(color='#f0f0f0')
            else:
                if j == 1:  # Value column
                    cell.set_facecolor('#E8F5E8')
                elif j == 2:  # Percentage column
                    if i == 2:  # Test Passed row
                        cell.set_facecolor('#90EE90')  # Light green for passed
                    elif i in [3, 4, 5]:  # Failed, Compile Error, Simulation Error, Timeout rows
                        cell.set_facecolor('#FFB6C1')  # Light red for errors
                    else:
                        cell.set_facecolor('#F0F8FF')
                else:  # Metric column
                    cell.set_facecolor('#f9f9f9')
            
            # Add borders
            cell.set_edgecolor('#CCCCCC')
            cell.set_linewidth(0.5)
    
    # Add title
    plt.title(f'Overall RTL Benchmark Results - {filename_prefix}\n{datetime.now().strftime("%Y-%m-%d %H:%M:%S")}', 
              fontsize=16, fontweight='bold', pad=20)
    
    # Save the image
    model_logs_dir = os.path.join(logs_dir, filename_prefix)
    os.makedirs(model_logs_dir, exist_ok=True)
    image_path = os.path.join(model_logs_dir, f"{filename_prefix}_overall_stats_table.png")
    plt.tight_layout()
    plt.savefig(image_path, dpi=300, bbox_inches='tight', facecolor='white')
    plt.close()
    
    print(f"Overall statistics table image saved to: {image_path}")
    return image_path

def generate_stats_table_image(stats: dict, filename_prefix: str, logs_dir: str = "logs") -> str:
    """
    Generate a table image of per-module statistics and save it to the model's log folder.
    
    Args:
        stats: Dictionary containing module statistics
        filename_prefix: Prefix for the output filename
        logs_dir: Directory to save the image
        
    Returns:
        str: Path to the generated image file, or empty string if no statistics available
    """
    if not stats or "OVERALL" not in stats:
        print("No statistics available for table generation.")
        return ""
    
    # Remove OVERALL from stats for per-module display
    module_stats = {k: v for k, v in stats.items() if k != "OVERALL"}
    if not module_stats:
        print("No module statistics available for table generation.")
        return ""
    
    # Sort modules by pass rate (descending)
    sorted_modules = sorted(module_stats.items(), key=lambda x: x[1]['pass_rate'], reverse=True)
    
    # Create figure and axis with reduced height
    fig, ax = plt.subplots(figsize=(16, max(6, len(module_stats) * 0.3)))
    ax.axis('tight')
    ax.axis('off')
    
    # Prepare data for the table with reorganized columns
    table_data = [
        ['Module', '', 'Passed', 'Syntax', 'Failed', 'Compile', 'Sim', 'Timeout']
    ]
    
    for module_name, module_data in sorted_modules:
        functional = '✓' if module_data['test_passed'] > 0 else '✗'
        passed_ratio = f"{module_data['test_passed']}/{module_data['runs']}"
        syntax_correct = '✓' if module_data.get('ever_compiled', False) else '✗'
        table_data.append([
            module_name,
            functional,
            passed_ratio,
            syntax_correct,
            str(module_data['test_failed']),
            str(module_data['compile_error']),
            str(module_data['simulation_error']),
            str(module_data['timeout'])
        ])
    
    # Create table with reduced spacing
    table = ax.table(cellText=table_data, cellLoc='center', loc='center')
    table.auto_set_font_size(False)
    table.set_fontsize(9)
    table.scale(1.0, 1.2)
    
    # Style the table
    for i in range(len(table_data)):
        for j in range(len(table_data[0])):
            cell = table[(i, j)]
            if i == 0:  # Header row
                cell.set_facecolor('#2E86AB')
                cell.set_text_props(weight='bold', color='white')
            else:
                # Color code based on pass rate
                pass_rate = module_stats[sorted_modules[i-1][0]]['pass_rate']
                if pass_rate >= 0.8:
                    row_color = '#E8F5E8'  # Light green for high pass rate
                elif pass_rate >= 0.5:
                    row_color = '#FFF8DC'  # Light yellow for medium pass rate
                else:
                    row_color = '#FFE4E1'  # Light red for low pass rate
                
                cell.set_facecolor(row_color)
                
                # Special styling for functional column (second column)
                if j == 1:  # Functional column
                    if module_stats[sorted_modules[i-1][0]]['test_passed'] > 0:
                        cell.set_facecolor('#90EE90')  # Green
                        cell.set_text_props(weight='bold')
                    else:
                        cell.set_facecolor('#FFB6C1')  # Light red
                
                # Special styling for passed ratio column
                elif j == 2:  # Passed ratio column
                    if pass_rate >= 0.8:
                        cell.set_facecolor('#90EE90')  # Green
                    elif pass_rate >= 0.5:
                        cell.set_facecolor('#FFD700')  # Gold
                    else:
                        cell.set_facecolor('#FFB6C1')  # Light red
                
                # Special styling for syntax column
                elif j == 3:  # Syntax column
                    if module_stats[sorted_modules[i-1][0]].get('ever_compiled', False):
                        cell.set_facecolor('#90EE90')  # Green
                        cell.set_text_props(weight='bold')
                    else:
                        cell.set_facecolor('#FFB6C1')  # Light red
            
            # Add borders with reduced linewidth
            cell.set_edgecolor('#CCCCCC')
            cell.set_linewidth(0.3)
    
    # Add title with overall stats
    overall = stats["OVERALL"]
    title_text = f'Per-Module RTL Benchmark Results - {filename_prefix}\n'
    title_text += f'Overall: {overall["test_passed"]}/{overall["runs"]} passed ({overall["pass_rate"]*100:.1f}%) | '
    title_text += f'Functional: {overall["functional"]}/{overall["total_modules"]} modules | '
    title_text += f'Date: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}'
    
    plt.title(title_text, fontsize=12, fontweight='bold', pad=15)
    
    # Save the image
    model_logs_dir = os.path.join(logs_dir, filename_prefix)
    os.makedirs(model_logs_dir, exist_ok=True)
    image_path = os.path.join(model_logs_dir, f"{filename_prefix}_per_module_stats_table.png")
    plt.tight_layout()
    plt.savefig(image_path, dpi=300, bbox_inches='tight', facecolor='white')
    plt.close()
    
    print(f"Per-module statistics table image saved to: {image_path}")
    return image_path

def run_benchmark(test_dir: str, print_summary: bool = True, print_detailed: bool = True, write_log_file: bool = True, logs_dir: str = "logs", generate_overall_table: bool = True, generate_per_module_table: bool = True) -> tuple[list[dict], dict]:
    """
    Run comprehensive benchmarks on all RTL directories within a test directory.
    
    Args:
        test_dir: Directory containing subdirectories with RTL files to test
        print_summary: Whether to print summary statistics to console
        print_detailed: Whether to print detailed results to console
        write_log_file: Whether to write results to log files
        logs_dir: Directory to store log files
        generate_overall_table: Whether to generate overall statistics table image
        generate_per_module_table: Whether to generate per-module statistics table image
        
    Returns:
        tuple[list[dict], dict]: Tuple containing (list of result dictionaries, compiled statistics)
    """
    result_list = []
    rtl_dirs = []
    folder_name = os.path.basename(test_dir.rstrip('/'))
    for item in os.listdir(test_dir):
        item_path = os.path.join(test_dir, item)
        if not os.path.isdir(item_path):
            continue
        result = test_all(item_path, print_summary=print_summary, print_detailed=print_detailed, write_log_file=write_log_file, logs_dir=logs_dir)
        if result is not None:
            rtl_dirs.append(item_path)
            result_list.append(result)
    if not result_list:
        print("No valid test results found.")
        return [], {}
    stats = compile_module_stats(result_list)
    pretty_print_module_stats(stats)
    write_combined_stats_to_log(result_list, rtl_dirs, stats, filename_prefix=folder_name, logs_dir=logs_dir)
    
    # Generate statistics tables based on options
    if generate_overall_table:
        generate_overall_stats_table_image(stats, folder_name, logs_dir)
    if generate_per_module_table:
        generate_stats_table_image(stats, folder_name, logs_dir)
    
    return result_list, stats

def main(args: list[str]):
    """
    Main entry point for the RTL benchmark runner.
    
    Parses command line arguments and runs the benchmark with specified options.
    
    Args:
        args: Command line arguments (excluding script name)
    """
    parser = argparse.ArgumentParser(description="Run RTL benchmark and write logs grouped by model.")
    parser.add_argument("test_dir", help="Directory containing generated RTL attempts (t1, t2, ...)")
    parser.add_argument("--no-overall-table", action="store_true", help="Skip generation of overall statistics table")
    parser.add_argument("--no-per-module-table", action="store_true", help="Skip generation of per-module statistics table")
    parser.add_argument("--no-logs", action="store_true", help="Skip writing log files")
    parser.add_argument("--no-printing", action="store_true", help="Skip printing results to console")
    parser.add_argument("--detailed", action="store_true", help="Print detailed results for each module")
    parsed = parser.parse_args(args)
    
    generate_overall_table = not parsed.no_overall_table
    generate_per_module_table = not parsed.no_per_module_table
    write_log_file = not parsed.no_logs
    print_summary = not parsed.no_printing
    print_detailed = not parsed.no_printing and parsed.detailed
    
    run_benchmark(
        os.path.join(os.getcwd(), parsed.test_dir), 
        print_summary=print_summary, 
        print_detailed=print_detailed, 
        write_log_file=write_log_file,
        generate_overall_table=generate_overall_table,
        generate_per_module_table=generate_per_module_table
    )


if __name__ == "__main__":
    main(sys.argv[1:])
    