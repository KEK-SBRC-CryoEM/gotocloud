#!/usr/bin/env python

import os
import shutil
import stacksplit_common as ss_comm
import folderfile_common as ff_comm


def make_sub_folder(current_path, sub_folder_path, source_folder_item, copy_folder_list):
    print('--> make_sub_folder')
    print(f'CurrentPath: {current_path}')
    print(f'SubFolderPath: {sub_folder_path}')
    print(f'SourceFolderItem: {source_folder_item}')
    print(f'CopyFolderList: {copy_folder_list}')

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
    if len(ff_comm.make_folder(make_folder_path)) == 0:
        raise ValueError(f"'{make_folder_item}' folder could not be created.")

    copy_source_path = os.path.join(current_path, source_folder_item)

    for copy_folder in copy_folder_list:
        source_path = os.path.join(copy_source_path, copy_folder)
        destination_path = os.path.join(make_folder_path, copy_folder)
        #        print(f'Source: {source_path}')
        #        print(f'Destination: {destination_path}')

        shutil.copytree(source_path, destination_path)


def main():
    current_path = os.getcwd()
    current_path = current_path.replace('stacksplit_scheme', '')
    current_path = ss_comm.fix_path_end(current_path)

    source_folder_item = 'Schemes_Edited/Schemes/'
    copy_folder_list = [
        '060_CSS_Clean_Stack_3D'
    ]

    sub_folder_list = [
        '100_particles_split_1/',
        '100_particles_split_2/',
        '100_particles_split_3/',
        '100_particles_split_4/'
    ]

    for sub_folder in sub_folder_list:
        sub_folder_path = os.path.join(current_path, sub_folder)
        make_sub_folder(current_path, sub_folder_path, source_folder_item, copy_folder_list)


if __name__ == "__main__":
    main()


