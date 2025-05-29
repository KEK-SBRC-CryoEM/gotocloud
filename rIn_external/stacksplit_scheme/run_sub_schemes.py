import os
import stacksplit_common as comm
import time
import subprocess

        
def run_sub_schemes(sub_folder_path_list):
    scheme_list = [
        '060_CSS_Clean_Stack_3D',
        '070_CSS_Init_Refine3D',
        '080_CSS_PPRefine_Cycle',
        '090_CSS_Res_Fish_3D'
#        '060_CSS_Clean_Stack_3D'
    ]

    log_file = 'stacksplit.log'
    for sub_folder_path in sub_folder_path_list:
    
        if os.path.exists(sub_folder_path) == False:
            raise ValueError(f"'{sub_folder_path}' is not exists.")
            
        ## Set the path to the current path 
        os.chdir(sub_folder_path)
        print(f'Current: {sub_folder_path}')
        
        for scheme in scheme_list:
            scheme_path = f'Schemes/{scheme}/'
            
            command = f'relion_schemer --scheme {scheme} --run --pipeline_control {scheme_path} >> {log_file} 2>&1 &'
            
            print(f'Command: {command}')                       
            os.system(command)
            
    count = 0
    time_interval = 60
    while True:
        check_str = check_scheme_end(sub_folder_path_list, scheme_list[len(scheme_list) - 1])
        print(f'[{count}]...{check_str}')

        if check_str == 'Success' or check_str == 'Failure':
            break
        count += 1
        time.sleep(time_interval)
        
    job_name = None
    #node_name = '060080_Refine3D_global'
    node_name = '090050_Refine3D_local'
    job_name_list = []
    for sub_folder_path in sub_folder_path_list:
        job_name = None  
        log_path = os.path.join(sub_folder_path, log_file)
        print(f'LogPath: {log_path}')
        job_name = comm.extract_job_name_from_file(log_path, node_name)
        print(f'[{sub_folder_path}] {node_name}: {job_name}')
        job_name_list.append(job_name)
        

def extract_result_job_name(lines, node_name):
    job_name = comm.extract_job_name_from_lines(lines, node_name)
    return job_name

def check_scheme_end(sub_folder_path_list, last_scheme):
    return_flg = 'Success'
    for sub_folder in sub_folder_path_list:
        check_path = os.path.join(sub_folder, 'Schemes/' + last_scheme)
        if os.path.exists(check_path):
            check_success = os.path.join(check_path, 'RELION_JOB_EXIT_SUCCESS')
            check_failure = os.path.join(check_path, 'RELION_JOB_EXIT_FAILURE')
            if os.path.exists(check_failure):
                print(f"'{check_failure}' is exists.")
                return_flg = 'Failure'
                break
            elif os.path.exists(check_success):
                pass
            else:
                return_flg = 'Wait'
                break
            
        else:
            print(f"'{check_path}' is not exists.")
            return_flg = 'Failure'            
            break
    return return_flg







def main():

    current_path = os.getcwd()
    current_path = current_path.replace('stacksplit_scheme', '')
    current_path = comm.fix_path_end(current_path)

    sub_folder_path_list = [
        f'{current_path}100_particles_split_1/',
        f'{current_path}100_particles_split_2/'          
    ]
    
    run_sub_schemes(sub_folder_path_list)

    
    



if __name__ == "__main__":
    main()
    

