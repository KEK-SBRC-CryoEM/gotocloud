import os
import starfile
import stacksplit_common as comm

def extract_path_from_line(line):
    index = line.find('@')
    path = line[index + 1:]
    #print(path)
    return path


    
def extract_path_list(star_particles, folder_path):
    image_name_col = next((col for col in star_particles.columns if 'rlnImageName' in col), None)
    if image_name_col is None:
        raise ValueError("Not found column name 'rlnMicrographName'.")
    path_list = []
    for i in range(len(star_particles[image_name_col])):
        line = star_particles[image_name_col][i]
        
        path = extract_path_from_line(line)
        ## ABS path
        path = os.path.join(folder_path, path)
        #print(f'Extract: {path}')
        if not path in path_list:
            path_list.append(path)
        
    return path_list


def get_folder_list(path_list):
    folder_list = []
    for path in path_list:
        folder_path = os.path.dirname(path)
        folder_path = comm.fix_path_end(folder_path)
        if not folder_path in folder_list:
            folder_list.append(folder_path)
    return folder_list  




def make_result_symboliclink_folder(current_path, sub_folder_list, merge_file_list):

    index = 0
    for sub_folder in sub_folder_list:
    
        source_path = os.path.join(current_path, sub_folder) 
        print(f'Source: {source_path}')
        print(f'Destination: {current_path}')
        merge_file = merge_file_list[index]
        print(f'Merge: {merge_file}')
        
        merge_data = starfile.read(merge_file)
        merge_particles = merge_data['particles']
        
        file_list = extract_path_list(merge_particles, source_path)
        folder_list = get_folder_list(file_list)
        
        #print(f'file:[{len(file_list)}]')
        #print(file_list)

        ## make folder
        for folder_path in folder_list:
            #print(f'folder_path: {folder_path}')
            make_folder_path = folder_path.replace(source_path, '')
            make_folder_path = os.path.join(current_path, make_folder_path)
            #print(f'MakeFolder: {make_folder_path}')
            comm.make_folder(make_folder_path)

        ## make symboliclink
        comm.make_symboliclink_files(source_path, current_path, file_list)
        index += 1







def main():

    current_path = os.getcwd()
    current_path = current_path.replace('stacksplit_scheme', '')
    current_path = comm.fix_path_end(current_path)
    
    sub_folder_list = [
    '100_particles_split_1/',
    '100_particles_split_2/',
    '100_particles_split_3/',
    '100_particles_split_4/'
    ]
    
    merge_file_list = [
    '/fsx/yatabe_stacksplit_test/100_particles_split_1/Refine3D/job092/run_data.star', 
    '/fsx/yatabe_stacksplit_test/100_particles_split_2/Refine3D/job092/run_data.star', 
    '/fsx/yatabe_stacksplit_test/100_particles_split_3/Refine3D/job092/run_data.star', 
    '/fsx/yatabe_stacksplit_test/100_particles_split_4/Refine3D/job092/run_data.star' 
    ]

    make_result_symboliclink_folder(current_path, sub_folder_list, merge_file_list)

    
    



if __name__ == "__main__":
    main()
    
    
    
    
    

