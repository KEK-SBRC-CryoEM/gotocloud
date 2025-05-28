import os
import time
import re

def make_folder(path):
    return_path = ''
    max_wait = 5  # s
    
    if os.path.exists(path):
        return_path = os.path.abspath(path)
    else:
        os.makedirs(path)

        # Wait until the folder is created (retry up to 5 seconds)
        waited = 0
        while not os.path.exists(path) and waited < max_wait:
            time.sleep(0.1)
            waited += 0.1

        # Check if the folder exists
        if os.path.exists(path):
            return_path = os.path.abspath(path)
        else:
            print(f"Failed to create subfolder'{sub_folder_path}'.")

    return return_path

def extract_job_name_from_line(line, node_name):
    pattern = re.compile(rf"Creating new Job:\s+(\S+)\s+from Node:\s+{re.escape(node_name)}")
    match = pattern.search(line)
    if match:
        return match.group(1)
    return None

def extract_job_name_from_file(file_name, node_name):
    #pattern = re.compile(rf"Creating new Job:\s+(\S+)\s+from Node:\s+{re.escape(node_name)}")
    
    with open(file_name, 'r') as file:
        lines = file.readlines()

    # Search from the last line
    return extract_job_name_from_lines_reversed(lines, node_name)
    
    #for line in reversed(lines):
    #    job_name = extract_job_name_from_line(line, node_name)
    #    if job_name is not None:
    #        return job_name
        
        
    #    #match = pattern.search(line)
    #    #if match:
    #    #    return match.group(1)
    
    #return None  # If not found, return with None.

def extract_job_name_from_lines_reversed(lines, node_name):
    # Search from the last line
    for line in reversed(lines):
        job_name = extract_job_name_from_line(line, node_name)
        if job_name is not None:
            return job_name
        
        
        #match = pattern.search(line)
        #if match:
        #    return match.group(1)
    
    return None  # If not found, return with None.
    
def extract_job_name_from_lines(lines, node_name):
    # Search from the last line
    for line in lines:
        job_name = extract_job_name_from_line(line, node_name)
        if job_name is not None:
            return job_name
        
        
        #match = pattern.search(line)
        #if match:
        #    return match.group(1)
    
    return None  # If not found, return with None.    

def fix_path_end(path):
    fix_path = path
    if fix_path[len(fix_path)-1] != '/':
        fix_path += '/'
    return fix_path