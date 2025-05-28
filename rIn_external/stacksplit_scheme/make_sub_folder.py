import os
import shutil
import stacksplit_common as comm

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
        
def make_sub_folder(current_path, sub_folder_path, source_folder_item):

    ## copy important file
    copy_source_path = current_path
    copy_file_list = [
        'config_sample_settings.yml',
        'default_pipeline.star'
    ]
    for file in copy_file_list:
        file_name = os.path.join(current_path, file)
        shutil.copy(file_name, sub_folder_path)

    ## copy Schemes/ 060-090 folder
    make_folder_item = 'Schemes/'
    make_folder_path = os.path.join(sub_folder_path, make_folder_item)
    if len(comm.make_folder(make_folder_path)) == 0:
        raise ValueError(f"'{make_folder_item}' folder could not be created.")

    copy_source_path = os.path.join(current_path, source_folder_item)
    copy_folder_list = [
        '060_CSS_Clean_Stack_3D',
        '070_CSS_Init_Refine3D',
        '080_CSS_PPRefine_Cycle',
        '090_CSS_Res_Fish_3D'
    ]

    for copy_folder in copy_folder_list:
        source_path = os.path.join(copy_source_path, copy_folder)
        destination_path = os.path.join(make_folder_path, copy_folder)
#        print(f'Source: {source_path}') 
#        print(f'Destination: {destination_path}')

        shutil.copytree(source_path, destination_path)






def main():

    current_path = os.getcwd()
    current_path = current_path.replace('stacksplit_scheme', '')
    current_path = comm.fix_path_end(current_path)
    sub_folder_path = os.path.join(current_path, '100_particles_split_1/')
    source_folder_item = 'Schemes_Edited/Schemes/'


    make_sub_folder(current_path, sub_folder_path, source_folder_item)

    
    



if __name__ == "__main__":
    main()
    

