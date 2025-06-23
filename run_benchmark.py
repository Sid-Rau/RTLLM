import os
import subprocess
import signal
from tqdm import tqdm
from datetime import datetime
from typing import List, Dict, Optional, Any, Union

# =============================================================================
# CONSTANTS AND CONFIGURATION
# =============================================================================

# Directory structure
CATEGORIES = ['Arithmetic', 'Control', 'Memory', 'Miscellaneous']

# Timeout settings (in seconds)
COMPILE_TIMEOUT = 1
SIM_TIMEOUT = 1

# Output control flags
PRINT_DETAILED_RESULTS = False  # Set to True to see detailed results for each module
WRITE_LOG_FILES = False         # Set to True to write results to log files

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

class TimeoutError(Exception):
    """Custom exception for timeout errors."""
    pass

def timeout_handler(signum: int, frame: Any) -> None:
    """Signal handler for timeout."""
    raise TimeoutError("Operation timed out")

def run_with_timeout(cmd: List[str], timeout: int, description: str, cwd: str = None) -> subprocess.CompletedProcess:
    """
    Run a command with a timeout.
    Optionally specify a working directory (cwd).
    
    Args:
        cmd: Command to run
        timeout: Timeout in seconds
        description: Description of the operation for error messages
        cwd: Working directory for the command
        
    Returns:
        subprocess.CompletedProcess object
        
    Raises:
        TimeoutError: If the command times out
    """
    try:
        # Set up the timeout signal
        signal.signal(signal.SIGALRM, timeout_handler)
        signal.alarm(timeout)
        
        # Run the command
        result = subprocess.run(cmd, capture_output=True, text=True, cwd=cwd)
        
        # Cancel the alarm
        signal.alarm(0)
        
        return result
        
    except TimeoutError:
        # Kill any remaining processes
        try:
            subprocess.run(['pkill', '-f', ' '.join(cmd)], capture_output=True)
        except:
            pass
        raise TimeoutError(f"{description} timed out after {timeout} seconds")
    except Exception as e:
        # Cancel the alarm in case of other exceptions
        signal.alarm(0)
        raise e

def find_leaf_directories(root_path: str) -> List[str]:
    """
    Recursively searches through a directory tree to find leaf directories.
    A leaf directory is one that contains files (like testbenches and designs)
    rather than just more subdirectories.
    
    Args:
        root_path: Starting directory to search from
        
    Returns:
        List of full paths to leaf directories
    """
    leaf_dirs: List[str] = []
    if os.path.exists(root_path):
        for item in os.listdir(root_path):
            item_path = os.path.join(root_path, item)
            if os.path.isdir(item_path):
                # Check if this directory has any files in it
                has_files = False
                for subitem in os.listdir(item_path):
                    subitem_path = os.path.join(item_path, subitem)
                    if os.path.isfile(subitem_path):
                        has_files = True
                        break
                
                if has_files:
                    # Found a leaf directory - add it to our list
                    leaf_dirs.append(item_path)
                else:
                    # This directory only has subdirectories, so search deeper
                    leaf_dirs.extend(find_leaf_directories(item_path))
    return leaf_dirs

def build_benchmark_directory_list() -> List[str]:
    """
    Build the list of all benchmark directories by searching through each category.
    
    Returns:
        List of full paths to benchmark directories
    """
    path = os.getcwd()
    dir_list: List[str] = []
    
    for cat in CATEGORIES:
        cat_path = os.path.join(path, cat)
        if os.path.exists(cat_path):
            leaf_dirs = find_leaf_directories(cat_path)
            dir_list.extend(leaf_dirs)
    return dir_list

# =============================================================================
# CORE TESTING FUNCTIONS
# =============================================================================

def test_file(rtl_file_path: str, benchmark_path: str) -> dict:
    """
    Tests a single RTL file against its corresponding testbench.
    Ensures $readmemh and similar file operations can find reference files by running in the benchmark directory.
    
    The function compiles the RTL file with the testbench using Icarus Verilog,
    then runs the simulation and checks if the test passes.
    
    Args:
        rtl_file_path: Path to the RTL file to test
        benchmark_path: Path to the directory containing the testbench
        
    Returns:
        Dictionary containing test results and status information
    """
    result = {
        "status": "unknown",    # Possible values: "compile_error", "simulation_error", "test_failed", "test_passed", "timeout"
        "compile_stdout": "",
        "compile_stderr": "",
        "sim_stdout": "",
        "sim_stderr": "",
        "returncode_compile": None,
        "returncode_sim": None
    }
    module_name = os.path.basename(benchmark_path)
    simv_name = f'simv_{module_name}'

    # Step 1: Compile in the benchmark directory
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

    # If compilation failed, return early with error status
    if compile_result.returncode != 0:
        result["status"] = "compile_error"
        return result

    # Step 2: Run simulation in the benchmark directory
    sim_cmd = ['vvp', simv_name]
    
    try:
        sim_result = run_with_timeout(sim_cmd, SIM_TIMEOUT, "Simulation", cwd=benchmark_path)
        result["sim_stdout"] = sim_result.stdout
        result["sim_stderr"] = sim_result.stderr
        result["returncode_sim"] = sim_result.returncode
    except TimeoutError as e:
        result["sim_stderr"] = str(e)
        result["status"] = "timeout"
        # Clean up the simulator executable even on timeout
        subprocess.run(['rm', os.path.join(benchmark_path, simv_name)], capture_output=True)
        return result
    
    # Clean up the simulator executable
    subprocess.run(['rm', os.path.join(benchmark_path, simv_name)], capture_output=True)

    # If simulation failed, return with error status
    if sim_result.returncode != 0:
        result["status"] = "simulation_error"
        return result

    # Step 3: Check if the test passed by looking for the success message
    if "===========Your Design Passed===========" in sim_result.stdout:
        result["status"] = "test_passed"
    else:
        result["status"] = "test_failed"

    return result

def write_results_to_log(result_dict: dict, rtl_file_dir: str, log_file_path: str = None, filename_prefix: str = None) -> str:
    """
    Write test results to a log file with timestamp and detailed information.
    
    Args:
        result_dict: Dictionary containing test results
        rtl_file_dir: Directory containing the RTL files that were tested
        log_file_path: Optional path for the log file. If None, generates a timestamped filename.
        filename_prefix: Optional prefix for the filename. If None, uses the RTL directory name.
        
    Returns:
        Path to the created log file
    """
    if log_file_path is None:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        if filename_prefix is None:
            filename_prefix = os.path.basename(rtl_file_dir)
        log_file_path = f"benchmark_results_{filename_prefix}_{timestamp}.log"
    
    with open(log_file_path, 'w') as log_file:
        # Write header with timestamp and test information
        log_file.write("=" * 80 + "\n")
        log_file.write("RTL BENCHMARK TEST RESULTS\n")
        log_file.write("=" * 80 + "\n")
        log_file.write(f"Test Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        log_file.write(f"RTL Directory: {rtl_file_dir}\n")
        log_file.write(f"Total Modules Tested: {len(result_dict)}\n")
        log_file.write("\n")
        
        # Calculate summary statistics
        passed = sum(1 for result in result_dict.values() if result["status"] == "test_passed")
        failed = sum(1 for result in result_dict.values() if result["status"] == "test_failed")
        compile_errors = sum(1 for result in result_dict.values() if result["status"] == "compile_error")
        sim_errors = sum(1 for result in result_dict.values() if result["status"] == "simulation_error")
        timeouts = sum(1 for result in result_dict.values() if result["status"] == "timeout")
        
        # Write summary
        log_file.write("SUMMARY STATISTICS\n")
        log_file.write("-" * 40 + "\n")
        log_file.write(f"Passed: {passed}\n")
        log_file.write(f"Failed: {failed}\n")
        log_file.write(f"Compile Errors: {compile_errors}\n")
        log_file.write(f"Simulation Errors: {sim_errors}\n")
        log_file.write(f"Timeouts: {timeouts}\n")
        log_file.write(f"Success Rate: {(passed/len(result_dict)*100):.1f}%\n")
        log_file.write("\n")
        
        # Write detailed results
        log_file.write("DETAILED RESULTS\n")
        log_file.write("-" * 40 + "\n")
        
        # Group results by status for better organization
        status_groups = {
            "test_passed": [],
            "test_failed": [],
            "compile_error": [],
            "simulation_error": [],
            "timeout": []
        }
        
        for module_name, result in result_dict.items():
            status_groups[result["status"]].append((module_name, result))
        
        # Write results grouped by status
        for status, modules in status_groups.items():
            if modules:
                log_file.write(f"\n{status.upper().replace('_', ' ')} ({len(modules)} modules):\n")
                log_file.write("-" * 30 + "\n")
                
                for module_name, result in modules:
                    log_file.write(f"  {module_name}\n")
                    
                    # Write error details for failed tests
                    if result["status"] != "test_passed":
                        if result["compile_stderr"]:
                            log_file.write(f"    Compile Error: {result['compile_stderr'].strip()}\n")
                        if result["sim_stderr"]:
                            log_file.write(f"    Simulation Error: {result['sim_stderr'].strip()}\n")
                        if result["compile_stdout"]:
                            log_file.write(f"    Compile Output: {result['compile_stdout'].strip()}\n")
                        if result["sim_stdout"]:
                            log_file.write(f"    Simulation Output: {result['sim_stdout'].strip()}\n")
        
        # Write footer
        log_file.write("\n" + "=" * 80 + "\n")
        log_file.write("END OF TEST RESULTS\n")
        log_file.write("=" * 80 + "\n")
    
    print(f"Results written to: {log_file_path}")
    return log_file_path

def test_all(
    rtl_file_dir: str,
    print_summary: bool = False,
    print_detailed: bool = False,
    write_log_file: bool = False
) -> dict | None:
    """
    Tests all RTL files in a directory against their corresponding testbenches.
    This function finds all .v and .sv files in the given directory and matches them
    with their corresponding testbench directories. It then runs tests for each
    match and provides a summary of results.
    Args:
        rtl_file_dir: Directory containing RTL files to test
        print_summary: If True, prints summary statistics
        print_detailed: If True, prints detailed results for each module
        write_log_file: If True, writes results to a log file
    Returns:
        Dictionary mapping module names to their test results, or None if directory does not exist
    """
    if not os.path.isdir(rtl_file_dir):
        if print_summary:
            print(f"Directory {rtl_file_dir} does not exist.")
        return None

    # Build the list of benchmark directories internally
    benchmark_dirs: List[str] = build_benchmark_directory_list()

    # First pass: collect all valid RTL files and match them with testbench directories
    rtl_files_to_test: List[Any] = []
    for rtl_file in os.listdir(rtl_file_dir):
        rtl_file_path = os.path.join(rtl_file_dir, rtl_file)
        if not os.path.isfile(rtl_file_path):
            continue
        if not rtl_file.endswith(('.v', '.sv')):
            continue
        # Find the matching testbench directory by comparing module names
        for dir in benchmark_dirs:
            module_name = os.path.basename(dir)
            # Remove both .v and .sv extensions for comparison
            rtl_file_base = os.path.splitext(rtl_file)[0]
            if rtl_file_base == module_name:
                rtl_files_to_test.append((rtl_file_path, dir, module_name))
                break

    result_dict: Dict[str, Dict[str, Union[str, int, None]]] = dict()

    # Second pass: run tests with progress tracking
    with tqdm(total=len(rtl_files_to_test), desc="Testing RTL files", unit="file", disable=not print_summary) as pbar:
        for rtl_file_path, benchmark_dir, module_name in rtl_files_to_test:
            if print_summary:
                pbar.set_description(f"Testing {module_name}")
            result_dict[module_name] = test_file(rtl_file_path, benchmark_dir)
            pbar.update(1)

    # Print summary statistics if enabled
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

    # Print detailed results only if enabled
    if print_detailed:
        print(f"\n=== Detailed Results ===")
        for module_name, result in result_dict.items():
            # Use emojis to make the output more readable
            status_emoji = {
                "test_passed": "✅",
                "test_failed": "❌",
                "compile_error": "🔧",
                "simulation_error": "⚡",
                "timeout": "⏰"
            }.get(result["status"], "❓")
            print(f"{status_emoji} {module_name}: {result['status']}")
            # Show error details for failed tests
            if result["status"] != "test_passed":
                if result["compile_stderr"]:
                    print(f"   Compile error: {result['compile_stderr'].strip()}")
                if result["sim_stderr"]:
                    print(f"   Simulation error: {result['sim_stderr'].strip()}")

    # Write results to log file only if enabled
    if write_log_file:
        write_results_to_log(result_dict, rtl_file_dir)

    return result_dict

def compile_module_stats(results_list: list[dict]) -> dict:
    """
    Compiles statistics for each module tested over multiple runs.

    Args:
        results_list: List of result dicts (as returned by test_all).

    Returns:
        Dictionary mapping module names to their aggregated stats, plus an 'OVERALL' key for global stats.
    """
    stats = {}
    overall = {
        "runs": 0,
        "test_passed": 0,
        "test_failed": 0,
        "compile_error": 0,
        "simulation_error": 0,
        "timeout": 0,
        "functional": 0,      # modules that passed at least once
        "syntax_correct": 0,  # modules that compiled at least once
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
            # If this run was not a compile error, mark as ever compiled
            if status != "compile_error":
                stats[module]["ever_compiled"] = True
            # Update overall stats
            overall["runs"] += 1
            if status in overall:
                overall[status] += 1
    # Calculate pass rate
    for module, s in stats.items():
        s["pass_rate"] = s["test_passed"] / s["runs"] if s["runs"] > 0 else 0.0
    # Calculate overall pass rate
    overall["pass_rate"] = overall["test_passed"] / overall["runs"] if overall["runs"] > 0 else 0.0
    # Calculate functional/anypass modules
    overall["functional"] = sum(1 for s in stats.values() if s["test_passed"] > 0)
    # Calculate syntax correct modules
    overall["syntax_correct"] = sum(1 for s in stats.values() if s.get("ever_compiled", False))
    overall["total_modules"] = len(stats)
    stats["OVERALL"] = overall
    return stats

def pretty_print_module_stats(stats: dict) -> None:
    """
    Nicely prints the per-module statistics compiled by compile_module_stats, and overall stats at the end.

    Args:
        stats: Dictionary as returned by compile_module_stats.
    """
    if not stats:
        print("No statistics to display.")
        return

    # Remove overall from per-module print
    overall = stats.pop("OVERALL", None)

    # Header
    header = (
        f"{'Module':<21}  {'Runs':>5}  {'Passed':>7}  {'Failed':>7}  "
        f"{'CompileErr':>12}  {'SimErr':>9}  {'Timeout':>9}  {'PassRate':>10}   {'Functional':>7}"
    )
    print(header)
    print("-" * len(header))

    # Rows
    for module, s in sorted(stats.items()):
        any_pass = '✅' if s['test_passed'] > 0 else ''
        print(
            f"{module:<21}  {s['runs']:>5}  {s['test_passed']:>7}  {s['test_failed']:>7}  "
            f"{s['compile_error']:>12}  {s['simulation_error']:>9}  {s['timeout']:>9}  {s['pass_rate']*100:9.1f}% {any_pass:>7}"
        )

    # Print overall stats
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
        print(f"Functional modules: {overall['functional']} / {overall['total_modules']}  ({'✅' if overall['functional'] else ''})")
        print(f"Syntax correct:     {overall['syntax_correct']} / {overall['total_modules']}  ({'✅' if overall['syntax_correct'] else ''})")

def write_combined_stats_to_log(results_list: list[dict], rtl_dirs: list[str], stats: dict, filename: str = None, filename_prefix: str = None) -> str:
    """
    Write comprehensive statistics to a log file combining all test results, overall stats, and detailed errors.
    
    Args:
        results_list: List of result dicts from all test runs
        rtl_dirs: List of RTL directories that were tested
        stats: Dictionary as returned by compile_module_stats
        filename: Optional filename. If None, generates a timestamped filename.
        filename_prefix: Optional prefix for the filename. If None, uses 'combined'.
        
    Returns:
        Path to the created log file
    """
    if filename is None:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        if filename_prefix is None:
            filename_prefix = "combined"
        filename = f"{filename_prefix}_benchmark_results_{timestamp}.log"
    
    # Remove overall from per-module stats for processing
    overall = stats.pop("OVERALL", None)
    
    with open(filename, 'w') as log_file:
        # Write header
        log_file.write("=" * 100 + "\n")
        log_file.write("COMBINED RTL BENCHMARK TEST RESULTS\n")
        log_file.write("=" * 100 + "\n")
        log_file.write(f"Test Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        log_file.write(f"Total Test Runs: {len(results_list)}\n")
        log_file.write(f"RTL Directories Tested: {', '.join([os.path.basename(d) for d in rtl_dirs])}\n")
        log_file.write(f"Total Modules Tested: {overall['total_modules'] if overall else 'Unknown'}\n")
        log_file.write("\n")
        
        # Write overall statistics
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
        
        # Write per-module statistics table
        log_file.write("PER-MODULE STATISTICS\n")
        log_file.write("-" * 60 + "\n")
        header = (
            f"{'Module':<25}  {'Runs':>5}  {'Passed':>7}  {'Failed':>7}  "
            f"{'CompileErr':>12}  {'SimErr':>9}  {'Timeout':>9}  {'PassRate':>10}   {'Functional':>7}\n"
        )
        log_file.write(header)
        log_file.write("-" * len(header) + "\n")
        
        for module, s in sorted(stats.items()):
            any_pass = '✅' if s['test_passed'] > 0 else ''
            log_file.write(
                f"{module:<25}  {s['runs']:>5}  {s['test_passed']:>7}  {s['test_failed']:>7}  "
                f"{s['compile_error']:>12}  {s['simulation_error']:>9}  {s['timeout']:>9}  {s['pass_rate']*100:9.1f}% {any_pass:>7}\n"
            )
        
        log_file.write("\n")
        
        # Write detailed results from each test run
        for i, (result_dict, rtl_dir) in enumerate(zip(results_list, rtl_dirs)):
            if result_dict is None:
                continue
                
            log_file.write(f"DETAILED RESULTS - {os.path.basename(rtl_dir)}\n")
            log_file.write("=" * 80 + "\n")
            log_file.write(f"RTL Directory: {rtl_dir}\n")
            log_file.write(f"Total Modules Tested: {len(result_dict)}\n")
            
            # Calculate summary for this run
            passed = sum(1 for result in result_dict.values() if result["status"] == "test_passed")
            failed = sum(1 for result in result_dict.values() if result["status"] == "test_failed")
            compile_errors = sum(1 for result in result_dict.values() if result["status"] == "compile_error")
            sim_errors = sum(1 for result in result_dict.values() if result["status"] == "simulation_error")
            timeouts = sum(1 for result in result_dict.values() if result["status"] == "timeout")
            
            log_file.write(f"Passed: {passed}, Failed: {failed}, Compile Errors: {compile_errors}, "
                          f"Simulation Errors: {sim_errors}, Timeouts: {timeouts}\n")
            log_file.write(f"Success Rate: {(passed/len(result_dict)*100):.1f}%\n\n")
            
            # Group results by status
            status_groups = {
                "test_passed": [],
                "test_failed": [],
                "compile_error": [],
                "simulation_error": [],
                "timeout": []
            }
            
            for module_name, result in result_dict.items():
                status_groups[result["status"]].append((module_name, result))
            
            # Write results grouped by status
            for status, modules in status_groups.items():
                if modules:
                    log_file.write(f"{status.upper().replace('_', ' ')} ({len(modules)} modules):\n")
                    log_file.write("-" * 40 + "\n")
                    
                    for module_name, result in modules:
                        log_file.write(f"  {module_name}\n")
                        
                        # Write error details for failed tests
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
        
        # Write footer
        log_file.write("=" * 100 + "\n")
        log_file.write("END OF COMBINED TEST RESULTS\n")
        log_file.write("=" * 100 + "\n")
    
    print(f"Combined results written to: {filename}")
    return filename

# =============================================================================
# MAIN EXECUTION
# =============================================================================

def main():
    # Example: run on t1 with summary
    test_dir = os.path.join(os.getcwd(), "_chatgpt4")
    result_list = []
    rtl_dirs = []
    for dir in os.listdir(test_dir):
        rtl_dir = os.path.join(test_dir, dir)
        rtl_dirs.append(rtl_dir)
        result_list.append(test_all(rtl_dir, print_summary=True))
    stats = compile_module_stats(result_list)
    pretty_print_module_stats(stats)
    write_combined_stats_to_log(result_list, rtl_dirs, stats, filename_prefix="chatgpt4")
    # You can call test_all with other directories and flags as needed

if __name__ == "__main__":
    main()
    