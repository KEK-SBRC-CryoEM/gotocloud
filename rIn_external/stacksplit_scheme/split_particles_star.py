import os
import starfile
import pandas as pd
import stacksplit_common as comm

def extract_particles_by_micrograph(data, micrograph_name):  

    # Detects names registered in micrograph columns
    col_name = None
    for col in data.columns:
        if 'rlnMicrographName' in col:
            col_name = col
            break

    if col_name is None:
        raise ValueError("Not found column name 'rlnMicrographName'.")

    # Extracts only the rows of a given micrograph
    filtered_data = data[data[col_name] == micrograph_name]

    return filtered_data
        


    
    
def split_micrographs_list(micrograph_list, split_num):

    one_list = []
    total_lists = []
    micrograph_count = len(micrograph_list)
    file_num = int(micrograph_count / split_num)
    surplus = int(micrograph_count % split_num)

    if surplus > 0:
        file_num += 1
    
    for i in range(len(micrograph_list)):

        if len(one_list) >= file_num:        
            total_lists.append(one_list)
            one_list = []
            if surplus > 0:
                surplus += -1
                if surplus == 0:
                    file_num += -1

        one_list.append(micrograph_list.index[i])     

    if len(one_list) > 0:
        total_lists.append(one_list)
    

    return total_lists


def count_particles_par_micrograph(data):

    # micrograph列名の確認（_rInMicrographName）
    col_name = None

    
    
    for col in data.columns:
        if 'rlnMicrographName' in col:
            col_name = col;
            break

    if col_name is None:
        raise ValueError("Not found column name 'rlnMicrographName'.")

    # Aggregate the number of data for each micrograph
    total_count = len(data)
    
        
    
    counts = data[col_name].value_counts().sort_index()
    
    micrograph_count = len(counts)
    
    return total_count, micrograph_count, counts


def count_micrographs_from_star(data):
  
    # Automatic detection of micrograph columns
    micrograph_col = next((col for col in data.columns if 'rlnMicrographName' in col), None)
    if micrograph_col is None:
        raise ValueError("Not found column name 'rlnMicrographName'.")

    total_count = len(data)   
   
    counts_data = data[micrograph_col].value_counts().sort_index()

    micrograph_count = len(counts_data)
    
    return total_count, micrograph_count, counts_data


def get_split_star_name(job_no, index):
    split_star = f'{job_no:03}_particles_split_{index}.star'
    return split_star


def move_split_substack_file(current_path, file_list):

    #print(f'Current:{current_path}')
    
    for file in file_list:        
        sub_folder_name = os.path.splitext(os.path.basename(file))[0]
        print(f'SubFolderName:{sub_folder_name}')
        sub_folder_path = os.path.join(current_path, sub_folder_name)
        print(f'SubFolderPath:{sub_folder_path}')
        
        
        
        if os.path.exists(sub_folder_path):
            raise ValueError(f"'{sub_folder_path}' is exists.")

        if len(comm.make_folder(sub_folder_path)) == 0:
            raise ValueError(f"'{sub_folder_path}' folder could not be created.")

        ## Check if a folder exists and output the result.
        if os.path.exists(sub_folder_path):
            destination_file = os.path.join(sub_folder_path, os.path.basename(file))
#            print(f'temp:{file}')
#            print(f'destination:{destination_file}')
            os.rename(file, destination_file)
        else:
            print(f"Failed to create subfolder'{sub_folder_path}'.")



def split_particles_star(current_path, job_no, split_num, particles_num):
    current_schemes_030_path = os.path.join(current_path, 'Schemes/030_GTF_Create_Stack/')
    run_out_030 = os.path.join(current_schemes_030_path, 'run.out')
    target_node_name = '030060_Select_rm_bars_xy'
    target_job_name = comm.extract_job_name_from_file(run_out_030, target_node_name)
    
    star_file = os.path.join(current_path, target_job_name)
    star_file = os.path.join(star_file, 'particles.star')
    print(f'StarFil: {star_file}')
    temp_folder = 'temp/'
    output_path = os.path.join(current_path, temp_folder)
    #print(f'TempPath:{output_path}')

    file_lists = []

    ## If the temp folder does not exist, create it.
    if os.path.exists(output_path) is False:
        if len(comm.make_folder(output_path)) == 0:
            raise ValueError(f"'{output_path}' folder could not be created.")


    ## read star file
    star_data = starfile.read(star_file)
    ## Extract 'particles' block data
    particles_data = star_data['particles']
    ## output
    ## ...omit 'particles' block data
    base_dict = star_data.copy()
    base_dict.pop('particles')
    #print(base_dict)

    ## Total number of data, number of micrographs, number of data per micrograph
    total_count, micrograph_count, count_list = count_micrographs_from_star(particles_data)

    ## If the number of divisions is not specified, 
    ## the number of divisions is calculated from the number of particles.
    if split_num == 0:
        split_num = int(total_count / particle_num)

    #print(f'total:{total_count}')
    #print(f'micrograph:{micrograph_count}')
    #print(f'split_num:{split_num}')

    #print(count_list)

    #print(file_lists)

    #print(count_list.index)
    #print(count_list[0])

    split_file_list = []
    if len(count_list) == 0:
        raise ValueError('No micrographic data were available.')

    ## List of files for creating split files
    file_lists = split_micrographs_list(count_list, split_num)

    index = 0    
    for file_list in file_lists:
        index += 1
        marge_data = []
        for file in file_list:
            extracted = extract_particles_by_micrograph(particles_data, file)
            marge_data.append(extracted)

        marged = {}

        ## pandas              
        marged = pd.concat(marge_data, ignore_index=True)

    #    print(marged)

        ## create output data
        split_star = base_dict.copy()
        split_star['particles'] = marged

    #    print(split_star)
        
        output_star = get_split_star_name(job_no, index)
        output_file = os.path.join(output_path, output_star)
    #    print(output_file)

        ## output split file 
        starfile.write(split_star, output_file)
        split_file_list.append(output_file)

    ## make sub folder
    move_split_substack_file(current_path, split_file_list)

    ## If there is nothing in the temp folder, delete it.
    try:
        os.rmdir(output_path)
    except OSError as e:
        pass
    
    
    
    
    
def main():

    current_path = os.getcwd()
    if current_path[len(current_path)-1] != '/':
        current_path += '/'
    job_no = 100
    split_num = 4
    particles_num = 0

    split_particles_star(current_path, job_no, split_num, particles_num)
    
    



if __name__ == "__main__":
    main()
