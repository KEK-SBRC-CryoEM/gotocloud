#!/usr/bin/env python

import os
import re
import yaml
import starfile
import folderfile_common as ff_comm

PIPELINE_STAR = 'default_pipeline.star'


def load_yaml_file(file_path):
    yaml_dict = {}
    with open(file_path, 'r') as yaml_file:
        yaml_dict = yaml.safe_load(yaml_file)
    return yaml_dict


def write_yaml_file(yaml_dict, file_path):
    print('--> write_yaml_file')
    print(f'YamlDict: {yaml_dict}')
    print(f'FilePath: {file_path}')
    with open(file_path, 'w') as output_file:
        yaml.dump(yaml_dict, output_file, default_flow_style=False)


def extract_job_name_from_line(line, node_name):
    pattern = re.compile(rf"Creating new Job:\s+(\S+)\s+from Node:\s+{re.escape(node_name)}")
    match = pattern.search(line)
    if match:
        return match.group(1)
    return None


def extract_job_name_from_lines(lines, node_name):
    # Search from the last line
    for line in lines:
        job_name = extract_job_name_from_line(line, node_name)
        if job_name is not None:
            return job_name

    return None  # If not found, return with None.


def extract_job_name_from_file(file_name, node_name):
    # pattern = re.compile(rf"Creating new Job:\s+(\S+)\s+from Node:\s+{re.escape(node_name)}")

    with open(file_name, 'r') as file:
        lines = file.readlines()

    # Search from the last line
    return extract_job_name_from_lines_reversed(lines, node_name)


def extract_job_name_from_lines_reversed(lines, node_name):
    # Search from the last line
    for line in reversed(lines):
        job_name = extract_job_name_from_line(line, node_name)
        if job_name is not None:
            return job_name

    return None  # If not found, return with None.


def get_own_jobname(current_path):
    print(f'-->get_own_jobname')
    jobname = None
    pipeline_path = os.path.join(current_path, PIPELINE_STAR)
    print(pipeline_path)
    pipeline_data = starfile.read(pipeline_path)
    pipeline_processes = pipeline_data['pipeline_processes']
    jobname = pipeline_processes['rlnPipeLineProcessName'][len(pipeline_processes) - 1]
    # print(jobname)
    return jobname


def get_own_job(current_path):
    print('--> get_own_job')
    jobname = get_own_jobname(current_path)
    job_path = os.path.join(current_path, jobname)
    print(f'JobPath: {job_path}')

    if os.path.exists(job_path):

        if os.path.exists(os.path.join(job_path, 'RELION_JOB_EXIT_SUCCESS')):
            print(f"'{job_path}' is already done.")
            # raise ValueError("'{job_path}' is already done.")
            jobname = None
    else:
        ff_comm.make_folder(job_path)

    print(f'Return: {jobname}')
    return jobname


def fix_path_end(path):
    fix_path = path
    if fix_path[len(fix_path) - 1] != '/':
        fix_path += '/'
    return fix_path