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
#            list_files_folders_recursively(path + "\\" + file, files_list, folders_list)
            list_files_folders_recursively(new_path, files_list, folders_list)
    else:
        ## If it's a file, add it.
        files_list.append(path)



def make_symboliclink_folders(current_path, sub_folder_path, folder_list):

    for folder_item in folder_list:

        target_path = os.path.join(current_path, folder_item)

        if os.path.exists(target_path):

            file_list = []
            folder_list = []
            target_path = os.path.join(current_path, folder_item)
#            print(f'TargetPath: {target_path}')

            list_files_folders_recursively(target_path, file_list, folder_list)

#            print('Folder:')
#            print(folder_list)
#            print(f'File: {len(file_list)}')


            ## make folder
            for one in folder_list:
                target_path = one.replace(current_path, sub_folder_path)
                result = comm.make_folder(target_path)
                #print(result)

            ## create symboliclink
            for one in file_list:
                destination = one.replace(current_path, sub_folder_path)
                
                if os.path.exists(destination):
                    if os.path.islink(destination):
                        ## symboliclink is exists.
                        ## -> Change if values are different
                        old_link = os.readlink(destination)
                        if one != old_link:
                            os.unlink(destination)
                            os.symlink(one, destination)
                            print(f'symbolink {destination}: {old_link} --> {one}')
                    else:
                        ## file is exists.
                        raise ValueError(f"'{destination}' file is exists.")
                else:        
                    #print(f'Sorce: {one}')
                    #print(f'Destination: {destination}')
                    os.symlink(one, destination)

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
    if current_path[len(current_path)-1] != '/':
        current_path += '/'

    sub_folder_path = os.path.join(current_path, '100_particles_split_1/')

    make_symbolic_folder(current_path, sub_folder_path)

    
    



if __name__ == "__main__":
    main()




