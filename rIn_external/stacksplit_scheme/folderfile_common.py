#!/usr/bin/env python

import os
import shutil
import time
import stacksplit_common as ss_comm


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
            print(f"Failed to create subfolder'{path}'.")

    return return_path

def list_files_folders_recursively(path, files_list, folders_list):
    if os.path.isdir(path):
        ## If it is a directory, execute this function recursively for the files in it.
        folders_list.append(path)
        files = os.listdir(path)
        for file in files:
            new_path = os.path.join(path, file)
            list_files_folders_recursively(new_path, files_list, folders_list)
    else:
        ## If it's a file, add it.
        files_list.append(path)

def make_symboliclink_files(source_path, destination_path, file_list):
    for file in file_list:
        destination = file.replace(source_path, destination_path)
                
        if os.path.exists(destination):
            if os.path.islink(destination):
                ## symboliclink is exists.
                ## -> Change if values are different
                old_link = os.readlink(destination)
                if file != old_link:
                    os.unlink(destination)
                    os.symlink(file, destination)
                    print(f'symbolink {destination}: {old_link} --> {file}')
            else:
                ## file is exists.
                raise Exception(f"'{destination}' file is exists.")
        else:        
            #print(f'Sorce: {file}')
            #print(f'Destination: {destination}')
            os.symlink(file, destination)


