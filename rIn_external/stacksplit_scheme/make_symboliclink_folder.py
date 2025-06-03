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



def make_symboliclink_folders(source_path, destination_path, folder_list):

    for folder_item in folder_list:

        target_path = os.path.join(source_path, folder_item)

        if os.path.exists(target_path):

            file_list = []
            folder_list = []
            target_path = os.path.join(source_path, folder_item)
#            print(f'TargetPath: {target_path}')

            list_files_folders_recursively(target_path, file_list, folder_list)

#            print('Folder:')
#            print(folder_list)
#            print(f'File: {len(file_list)}')


            ## make folder
            for one in folder_list:
                target_path = one.replace(source_path, destination_path)
                result = comm.make_folder(target_path)
                #print(result)

            ## create symboliclink
            comm.make_symboliclink_files(source_path, destination_path, file_list)
            


def make_symbolic_folder(current_path, sub_folder_path):
    folder_list = [
        'Movies',
        'Micrographs',
        'MotionCorr',
        'Inputs',
        'Select',
        'Extract'
    ]

    make_symboliclink_folders(current_path, sub_folder_path, folder_list)


def main():

    current_path = os.getcwd()
    current_path = current_path.replace('stacksplit_scheme', '')
    current_path = comm.fix_path_end(current_path)

    sub_folder_path = os.path.join(current_path, '100_particles_split_4/')

    make_symbolic_folder(current_path, sub_folder_path)

    
    



if __name__ == "__main__":
    main()




