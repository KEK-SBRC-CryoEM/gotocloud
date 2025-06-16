#!/usr/bin/env python

import os
import sys
import starfile
import argparse
import stacksplit_common as ss_comm
import folderfile_common as ff_comm
import split_particles_star as sp_split
import make_sub_folder as ms_folder
import make_symboliclink_folder as sym_folder
import edit_scheme_star as es_star
import run_sub_schemes as sub_run



LOG_FILE = 'stacksplit.log'
SCHEME_COPY_SOURCE = 'Schemes_Edited/Schemes/'
MERGE_SETTING_FILE = 'merge_setting.yml'
MERGE_SCHEME_NODE = '090050_Refine3D_local'
MERGE_FILE = 'run_data.star'
STACK_SPLIT_SCHEME_YML = 'stack_split_scheme.yml'
SCHEME_NODE_030060 = '030060_Select_rm_bars_xy'






def validate_args(args):
    errors = []
    return_flg = True
    
    #print('--> validate_args')
    if args.yml_file is None:
        ## 
        errors.append('You must be set --yml_file.')
        
    #print(f'Error: {len(errors)}')
    if errors:
        for err in errors:
            print(err)
        return_flg = False
    return return_flg

def write_result_setting_file(current_path, job_name, sub_folder_list, log_file, node_name, merge_file):
    output_path = os.path.join(current_path, job_name)
    output_file_path = os.path.join(output_path, MERGE_SETTING_FILE)
    
    print('-->write_result_setting_file')
    print(f'CurrentPath: {current_path}')
    print(f'JobName: {job_name}')
    print(f'SubFolderList: {sub_folder_list}')
    print(f'LogFile: {log_file}')
    print(f'NodeName: {node_name}')
    print(f'MergeFile: {merge_file}')
    print(f'OutputFilePath: {output_file_path}')
    
    setting_data = {
        'setting': {
            'current_path': current_path,
            'sub_folder_name': sub_folder_list,
            'node_name': node_name,
            'merge_file_name': merge_file
        }
    } 
    print(f'[DEBUG] Setting: {setting_data}')
    ss_comm.write_yaml_file(setting_data, output_file_path)

def main():
    current_path = os.getcwd()
    current_path = current_path.replace('stacksplit_scheme', '')
    current_path = ss_comm.fix_path_end(current_path)

    print(f'[DEBUG] CurrentPath: {current_path}')
    
    star_file = None
    splits_num = None
    particles_num = None
    schemes = []
    scheme_source = None
    merge_scheme_node = None
    merge_file = None
    
    
    parser = argparse.ArgumentParser()
    
    parser.add_argument('-yml', '--yml_file', type=str, default=STACK_SPLIT_SCHEME_YML, help='Configuration YML file.')
    parser.add_argument('-sf', '--star_file', type=str, help='Star file to be split')
    parser.add_argument('-spnum', '--splits_num', type=int, help='Number of file splits')
    parser.add_argument('-ptnum', '--particles_num', type=int, help='Approximate number of particles per file')
    parser.add_argument('-cp', '--scheme_copy_source', type=str, default=SCHEME_COPY_SOURCE, help='CS scheme copy source path')
    

    args, unknown = parser.parse_known_args()
    print("RELION_IT: Stack Split Scheme running...")

    print(f'[DEBUG] Entry YmlFile: {args.yml_file}')
    print(f'[DEBUG] Entry StarFile: {args.star_file}')
    print(f'[DEBUG] Entry SplitsNum: {args.splits_num}')
    print(f'[DEBUG] Entry ParticlesNum: {args.particles_num}')
    print(f'[DEBUG] Entry SchemeCopySource: {args.scheme_copy_source}')
    

    own_job_name = None
    own_job_path = None
    own_job_no = None

    sub_folder_list = []
   

    try:
        own_job_name = ss_comm.get_own_job(current_path)
        ## debug
        #own_job_name = 'External/job200/'
        if own_job_name is not None: 
            own_job_path = os.path.join(current_path, own_job_name)
            own_job_no = own_job_name[-4:-1]
            
        
        print(f'[DEBUG] JobName: {own_job_name}')
        print(f'[DEBUG] JobNo: {own_job_no}')
        

        if args.yml_file is not None:
            if os.path.exists(args.yml_file):
                yml_setting = ss_comm.load_yaml_file(args.yml_file)
                setting_data = yml_setting['setting']
                #print(f'Setting: {setting_data}')
                star_file = setting_data['star_file']
                splits_num = setting_data['splits_num']
                particles_num = setting_data['particles_num']
                schemes = setting_data['schemes']
                scheme_source = setting_data['scheme_copy_source']
                merge_scheme_node = setting_data['merge_scheme_node']
                merge_file = setting_data['merge_file']
            else:
                raise Exception(f"'{args.yml_file}' is not exists.")

        if star_file is None:
            current_schemes_030_path = os.path.join(current_path, 'Schemes/030_GTF_Create_Stack/')
            run_out_030 = os.path.join(current_schemes_030_path, 'run.out')
            target_node_name = SCHEME_NODE_030060
            target_job_name = ss_comm.extract_job_name_from_file(run_out_030, target_node_name)
    
            star_file = os.path.join(current_path, target_job_name)
            star_file = os.path.join(star_file, 'particles.star')
        if scheme_source is None:
            scheme_source = SCHEME_COPY_SOURCE
        if len(schemes) == 0:
            schemes = ['060_CSS_Clean_Stack_3D', '070_CSS_Init_Refine3D', '080_CSS_PPRefine_Cycle', '090_CSS_Res_Fish_3D']
        if merge_scheme_node is None:
            merge_scheme_node = MERGE_SCHEME_NODE
        if merge_file is None:
            merge_file = MERGE_FILE

        flg = validate_args(args)
        if not flg:
            raise Exception
        if splits_num is None and particles_num is None:
            raise Exception(f'You must be set, splits_num or particles_num.')

            
        print(f'[DEBUG] Setting StarFile: {star_file}')
        print(f'[DEBUG] Setting SplitsNum: {splits_num}')
        print(f'[DEBUG] Setting ParticlesNum: {particles_num}')
        print(f'[DEBUG] Setting Schemes: {schemes}')
        print(f'[DEBUG] Setting SchemeCopySource: {scheme_source}')
        print(f'[DEBUG] Setting MergeSchemeNode: {merge_scheme_node}')
        print(f'[DEBUG] Setting MergeFile: {merge_file}')
           

        # Debug
        #sys.exit(0)




        ## split star file
        sub_folder_list = sp_split.split_particles_star(current_path, star_file, own_job_no, splits_num, particles_num)
        
        print(f'[DEBUG] SubFolderList: {sub_folder_list}')
        print(f'[DEBUG] Schemes: {schemes}')
        
        sub_folder_abs_list = []
        
        for sub_folder in sub_folder_list:
            sub_folder_path = os.path.join(current_path, sub_folder)
            sub_folder_abs_list.append(sub_folder_path)
            print(f'[DEBUG] SubFolderPath: {sub_folder_path}')
            ms_folder.make_sub_folder(current_path, sub_folder_path, scheme_source, schemes)
            sym_folder.make_symbolic_folder(current_path, sub_folder_path)
            ## split star file
            split_star_file = os.path.join(sub_folder_path, sub_folder.replace('/', '') + '.star')
            es_star.edit_scheme_star(current_path, sub_folder_path, split_star_file)
                       
        print('Scheme is ready to be activated.')
        
        ## Execute schemes
        sub_run.run_sub_schemes(sub_folder_abs_list, schemes, LOG_FILE)
        
        ## Write result config to YAML file
        write_result_setting_file(current_path, own_job_name, sub_folder_list, LOG_FILE, merge_scheme_node, merge_file)
        
        
        open(os.path.join(own_job_path, 'RELION_JOB_EXIT_SUCCESS'), 'w').close()      
    except Exception as e:
        print(f'Exception: {e}')
        if own_job_path: 
            open(os.path.join(own_job_path, 'RELION_JOB_EXIT_FAILURE'), 'w').close()
            sys.exit(0)



    
    
 
    

    

    


    
    


if __name__ == "__main__":
    main()
