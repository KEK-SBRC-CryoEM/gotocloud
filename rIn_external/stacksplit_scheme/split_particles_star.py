#!/usr/bin/env python

import os
import starfile
import pandas as pd
import stacksplit_common as ss_comm
import folderfile_common as ff_comm

def extract_particles_by_micrograph(data, micrograph_name):  

    # Detects names registered in micrograph columns
    col_name = None
    for col in data.columns:
        if 'rlnMicrographName' in col:
            col_name = col
            break

    if col_name is None:
        raise Exception("Not found column name 'rlnMicrographName'.")

    # Extracts only the rows of a given micrograph
    filtered_data = data[data[col_name] == micrograph_name]

    return filtered_data
        


    
    
def split_micrographs_list(micrograph_list, split_num):
    print('--> split_micrographs_list')
    print(f'MicrographsList: {len(micrograph_list)} ')
    print(f'SplitNum: {split_num}')


    one_list = []
    total_lists = []
    micrograph_count = len(micrograph_list)
    
    file_num = int(micrograph_count / split_num)
    print(f'FileNum: {str(file_num)}')
    surplus = int(micrograph_count % split_num)
    print(f'Surplus: {str(surplus)}')

    if surplus > 0:
        file_num += 1
    
   
    for i in range(len(micrograph_list)):

        if len(one_list) >= file_num:
            print('1')        
            total_lists.append(one_list)
            one_list = []
            if surplus > 0:
                print('2')
                surplus += -1
                if surplus == 0:
                    print("3")
                    file_num += -1

        one_list.append(micrograph_list.index[i])     

    if len(one_list) > 0:        
        total_lists.append(one_list)
    
    print(f'TotalLists: {total_lists}')
    return total_lists


def count_particles_par_micrograph(data):

    # micrograph列名の確認（_rInMicrographName）
    col_name = None

    
    
    for col in data.columns:
        if 'rlnMicrographName' in col:
            col_name = col
            break

    if col_name is None:
        raise Exception("Not found column name 'rlnMicrographName'.")

    # Aggregate the number of data for each micrograph
    total_count = len(data)
    
        
    
    counts = data[col_name].value_counts().sort_index()
    
    micrograph_count = len(counts)
    
    return total_count, micrograph_count, counts


def count_micrographs_from_star(data):
  
    # Automatic detection of micrograph columns
    micrograph_col = next((col for col in data.columns if 'rlnMicrographName' in col), None)
    if micrograph_col is None:
        raise Exception("Not found column name 'rlnMicrographName'.")

    total_count = len(data)   
   
    counts_data = data[micrograph_col].value_counts().sort_index()

    micrograph_count = len(counts_data)
    
    return total_count, micrograph_count, counts_data


def get_split_star_name(job_no, index):
    split_star = f'{job_no}_particles_split_{index}.star'
    return split_star


def move_split_substack_file(current_path, file_list):

    print('-->move_split_substack_file')
    #print(f'Current:{current_path}')
    sub_folder_list = []
    
    for file in file_list:        
        sub_folder_name = os.path.splitext(os.path.basename(file))[0]

        sub_folder_name = ss_comm.fix_path_end(sub_folder_name)

        sub_folder_list.append(sub_folder_name)

        print(f'SubFolderName:{sub_folder_name}')
        sub_folder_path = os.path.join(current_path, sub_folder_name)
        print(f'SubFolderPath:{sub_folder_path}')
        
        
        
        if os.path.exists(sub_folder_path):
            print(f"'{sub_folder_path}' is exists.")
            raise Exception(f"'{sub_folder_path}' is exists.")

        if len(ff_comm.make_folder(sub_folder_path)) == 0:
            print(f"'{sub_folder_path}' is exists.")
            raise Exception(f"'{sub_folder_path}' folder could not be created.")

        ## Check if a folder exists and output the result.
        if os.path.exists(sub_folder_path):
            destination_file = os.path.join(sub_folder_path, os.path.basename(file))
#            print(f'temp:{file}')
#            print(f'destination:{destination_file}')
            os.rename(file, destination_file)
        else:
            print(f"Failed to create subfolder'{sub_folder_path}'.")
    return sub_folder_list


def split_particles_star(current_path, star_file, job_no, split_num, particles_num):
    print('--> split_particles_star')
    print(f'JobNo: {job_no}')
    print(f'StarFile: {star_file}')
    print(f'SplitNum: {split_num}/ ParticesNum: {particles_num}')
    temp_folder = 'temp/'
    output_path = os.path.join(current_path, temp_folder)
    print(f'TempPath:{output_path}')

    file_lists = []
    sub_folder_list = []

    ## If the temp folder does not exist, create it.
    if not os.path.exists(output_path):
        if len(ff_comm.make_folder(output_path)) == 0:
            raise Exception(f"'{output_path}' folder could not be created.")


    ## read star file
    star_data = starfile.read(star_file)
    print(f'StarData: {len(star_data)}')
    
    ## Extract 'particles' block data
    particles_data = star_data['particles']
    print(f'ParticlesData: {len(particles_data)}')
    
    ## output
    ## ...omit 'particles' block data
    base_dict = star_data.copy()
    base_dict.pop('particles')
    #print(base_dict)

    ## Total number of data, number of micrographs, number of data per micrograph
    total_count, micrograph_count, count_list = count_micrographs_from_star(particles_data)
    print(f'Total:{total_count}')
    print(f'Micrograph:{micrograph_count}')
    print(count_list)

    ## If the number of divisions is not specified, 
    ## the number of divisions is calculated from the number of particles.
    if split_num == 0:
        print(f'split_num == 0')
        split_num = None
    
    if split_num is None:
        print(f'split_num is None')
        split_num = int(total_count / particles_num)  
    
    print(f'split_num:{split_num}')

    

    

    #print(count_list.index)
    #print(count_list[0])

    split_file_list = []
    if len(count_list) == 0:
        raise Exception('No micrographic data were available.')

    ## List of files for creating split files
    file_lists = split_micrographs_list(count_list, split_num)
    print(f'[DEBUG] FileLists: {file_lists}')


    index = 0    
    for file_list in file_lists:
        index += 1
        merge_data = []
        for file in file_list:
            extracted = extract_particles_by_micrograph(particles_data, file)
            merge_data.append(extracted)

        merged = {}

        ## pandas              
        merged = pd.concat(merge_data, ignore_index=True)

    #    print(marged)


        ## create output data
        split_star = base_dict.copy()
        split_star['particles'] = merged

    #    print(split_star)              
        
        output_star = get_split_star_name(job_no, index)
        output_file = os.path.join(output_path, output_star)
        print(output_file)

        ## output split file 
        starfile.write(split_star, output_file)
        split_file_list.append(output_file)

    ## make sub folder
    sub_folder_list = move_split_substack_file(current_path, split_file_list)

    ## If there is nothing in the temp folder, delete it.
    try:
        os.rmdir(output_path)
    except OSError as e:
        pass
    
    return sub_folder_list
    
    
    
def main():

    current_path = os.getcwd()
    current_path = current_path.replace('stacksplit_scheme', '')
    current_path = ss_comm.fix_path_end(current_path)
    
    star_file = '/fsx/yatabe_stacksplit_test/Select/job009/particles.star'
    split_num = 4
    particles_num = 0
    job_no = '100'

    split_particles_star(current_path, star_file, job_no, split_num, particles_num)
    
    



if __name__ == "__main__":
    main()

