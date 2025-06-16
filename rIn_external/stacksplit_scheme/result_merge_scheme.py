#!/usr/bin/env python

import os
import sys
import argparse
import stacksplit_common as ss_comm
import merge_run_data_star as mrd_star
import make_result_symboliclink_folder as mrs_folder

LOG_FILE = 'stacksplit.log'

def get_result_file(current_path, sub_folder_list, node_name, result_file):

    result_list = []
    for sub_folder in sub_folder_list:
        sub_folder_path = os.path.join(current_path, sub_folder)
        log_file_path = os.path.join(sub_folder_path, LOG_FILE)
        job_name = ss_comm.extract_job_name_from_file(log_file_path, node_name)
        result_file_path = os.path.join(sub_folder_path, job_name)
        result_file_path = os.path.join(result_file_path, result_file)
        
        result_list.append(result_file_path)
        
    return result_list


def main():
    
    own_job_path = None
    
    try:
        parser = argparse.ArgumentParser()
   
        parser.add_argument('-f', '--setting_file', type=str, default='', help='')

        args, unknown = parser.parse_known_args()
        print("RELION_IT: Result Merge Scheme running...")
   
        print(f'[DEBUG] Entry SettingFile: {args.setting_file}')
   
   
        ## Setting file load
        yml_data = ss_comm.load_yaml_file(args.setting_file)
        setting_data = yml_data['setting']
        print(f'[DEBUG] SettingData: {setting_data}')
    
        result_list = get_result_file(setting_data['current_path'], setting_data['sub_folder_name'], setting_data['node_name'], setting_data['merge_file_name'])
        print(f'[DEBUG] ResultList: {result_list}')
    
        own_job_name = ss_comm.get_own_job(setting_data['current_path'])
        #own_job_name = 'External/job100/'
        print(f'[DEBUG] OwnJobName: {own_job_name}')
        own_job_path = os.path.join(setting_data['current_path'], own_job_name)

        mrd_star.merge_run_data_star(setting_data['current_path'], own_job_name, result_list)
        mrs_folder.make_result_symboliclink_folder(setting_data['current_path'], setting_data['sub_folder_name'], result_list) 
    
    
    
        open(os.path.join(own_job_path, 'RELION_JOB_EXIT_SUCCESS'), 'w').close() 
    
    except Exception as e:
        print(f'except: {e.message}')
        if own_job_path: 
            open(os.path.join(own_job_path, 'RELION_JOB_EXIT_FAILURE'), 'w').close()
            sys.exit(0)
    
    

if __name__ == "__main__":
    main()
