#!/usr/bin/env python

import os
import shutil
import stacksplit_common as ss_comm
import folderfile_common as ff_comm




def make_link_folders(source_path, destination_path, folder_list, symbolic_link):

    for folder_item in folder_list:

        target_path = os.path.join(source_path, folder_item)

        if os.path.exists(target_path):

            file_list = []
            folder_list = []
            target_path = os.path.join(source_path, folder_item)
#            print(f'TargetPath: {target_path}')

            ff_comm.list_files_folders_recursively(target_path, file_list, folder_list)

#            print('Folder:')
#            print(folder_list)
#            print(f'File: {len(file_list)}')


            ## make folder
            for one in folder_list:
                target_path = one.replace(source_path, destination_path)
                result = ff_comm.make_folder(target_path)
                #print(result)

            ## create link
            ff_comm.make_link_files(source_path, destination_path, file_list, symbolic_link)
            


def make_link_folder(current_path, sub_folder_path, symbolick_link):
    folder_list = [
        'Movies',
        'Micrographs',
        'MotionCorr',
        'Inputs',
        'Select',
        'Extract'
    ]

    make_link_folders(current_path, sub_folder_path, folder_list, symbolick_link)


def main():

    current_path = os.getcwd()
    current_path = current_path.replace('stacksplit_scheme', '')
    current_path = ss_comm.fix_path_end(current_path)

    sub_folder_list = [
        '100_particles_split_1/',
        '100_particles_split_2/', 
        '100_particles_split_3/', 
        '100_particles_split_4/'  
    ]
    
    for sub_folder in sub_folder_list:
        sub_folder_path = os.path.join(current_path, sub_folder)
        make_link_folder(current_path, sub_folder_path, True)

    
    



if __name__ == "__main__":
    main()





