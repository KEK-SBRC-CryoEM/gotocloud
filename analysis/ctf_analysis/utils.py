# todo: this should be a standalone library installed when setting up gotocloud

import os
import sys
import time
import logging
import argparse

from pathlib import Path

import json
import yaml

### logging functions ###
def configure_logging(verbose=False, output_directory=None, capture_warnings=False):
    """
    Configure application-wide logging behavior.

    This function initializes the root logger. 
    Logs are emitted to stderr by default and 
        can optionally be written to a file.

    Parameters
    ----------
    verbose : bool, optional
        If True, set logging level to INFO. Otherwise, use WARNING level.
        Default is False.

    output_directory : str or None, optional
        Path to where the logs should also be written. If None, logs
        are only emitted to stderr. Default is None.

    capture_warnings : bool, optional
        If True, redirect Python warnings (from the warnings module)
        into the logging system. If False, warnings use the default
        behavior. Default is False.

    Notes
    -----
    This function should be called once at the application entry point
    (e.g., inside a `if __name__ == "__main__"` block). Library modules
    should not configure logging themselves, but instead obtain loggers
    using `logging.getLogger(__name__)`.

    Example
    -------
    >>> from utils import configure_logging
    >>> configure_logging(verbose=True, output_directory="results", capture_warnings=True)
    >>> logger = logging.getLogger(__name__)
    >>> logger.info("Logging initialized.")
    """
    level = logging.INFO if verbose else logging.WARNING

    handlers = []

    # terminal handler
    terminal_handler = logging.StreamHandler(sys.stderr)
    terminal_handler.setLevel(level)
    handlers.append(terminal_handler)

    # file handler
    if output_directory:
        log_file = os.path.join(output_directory, "run.log")
        file_handler = logging.FileHandler(log_file)
        file_handler.setLevel(level)
        handlers.append(file_handler)

    # config
    logging.basicConfig(
        level=level,
        format="%(name)s | %(levelname)s: %(message)s",
        handlers=handlers,
        # force=True,
    )

    # redirect warning to the logger
    logging.captureWarnings(capture_warnings)

### setup functions ###
def add_common_cli_arguments(parser):
    """
    Add shared command-line arguments related to input/output behavior.

    This function extends an existing ``argparse.ArgumentParser`` with
    standardized flags used across scripts in the project. 
    
    Example
    -------
    >>> parser = argparse.ArgumentParser()
    >>> parser.add_argument(...)
    >>> add_common_cli_arguments(parser)
    >>> args = parser.parse_args()
    """
    parser.add_argument("--json", action="store_true", help="Output results as JSON. Useful for the automation pipeline. If not provided, output will be shown in a human-friendly manner.")
    parser.add_argument("--output-dir", type=str, help="Directory path where all outputs and logs will be saved. If not provided, results are printed to stdout and logs to stderr only.")
    parser.add_argument("--verbose", action="store_true", help="Enable debug logging.")
    return parser

def prepare_output_environment(output_dir):
    if not output_dir:
        return None

    final_dir = os.path.join(output_dir, gtf_get_timestamp(True))
    Path(final_dir).mkdir(parents=True, exist_ok=True)

    return final_dir

### handling output ###
def handle_output(result, to_json=False, output_directory=None):
    """
    Print results to stdout (pretty or JSON) and optionally save to a file.

    Parameters
    ----------
    result : dict
        The result data to output.
    to_json : bool, optional
        If True, serialize output as JSON. Otherwise, use YAML for a more human-friendly format.
    output_directory : str, optional
        File path where the output will also be saved. If None, output is
        only printed to stdout.

    Example
    -------
    >>> result = {"accuracy": 0.92}
    >>> handle_output(result, to_json=True)
    >>> handle_output(result, to_json=False, output_directory="result")
    """

    if to_json:
        output = json.dumps(result, indent=2)
        ext = "json"
    else:
        output = yaml.safe_dump(result, sort_keys=False)
        ext = "yaml"

    print(output)

    if output_directory:
        filepath = os.path.join(output_directory, f"output.{ext}")
        with open(filepath, "w") as file:
            file.write(output)

### output directory related functions ###
def create_numbered_folder(base_path):
    """
    created a numbered folder '000' at base_path
    if base_path/'000' already exists, increments one and try again
    """
    n = 0
    while True:
        folder_name = f"{n:03d}"
        full_path = os.path.join(base_path, folder_name)
        
        if not os.path.exists(full_path):
            os.makedirs(full_path)
            return full_path
        
        n += 1

def gtf_get_timestamp(file_format=False):
	"""
	Utility function to get a properly formatted timestamp. 

	Args:
		file_format (bool): If true, timestamp will not include ':' characters
			for a more OS-friendly string that can be used in less risky file 
			names [default: False ]
	"""
	if file_format:
		return time.strftime("%Y-%m-%d_%H-%M-%S", time.localtime())
	else:
		return time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())

### file reading ###
def load_yaml(filepath):
    """
    Receives a filepath of a .yaml file and loads it as a dictionary
    """
    if filepath is not None and filepath.strip()!="":
        parameters = yaml.safe_load(filepath)
        with open(filepath, 'r') as yaml_file:
            yaml_dict = yaml.safe_load(yaml_file)
        return yaml_dict
    return None