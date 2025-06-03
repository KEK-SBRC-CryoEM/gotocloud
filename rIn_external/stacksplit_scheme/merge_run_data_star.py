import starfile
import pandas as pd
import os
import shutil
import stacksplit_common as comm

def merge_run_data_star(current_path, job_name, run_data_list):
    
    job_path = os.path.join(current_path, job_name)
    if not os.path.exists(job_path):
        comm.make_folder(job_path)
    merged_star_file = os.path.join(job_path, 'merged_run_data.star')

    if len(run_data_list) == 1:
        shutil.copy(run_data_list[0], merged_star_file)
    else:
        merge_star_file(run_data_list[0], run_data_list[1], merged_star_file)
        if len(run_data_list) > 2:
            for i in range(2, len(run_data_list)):
                merge_star_file(merged_star_file, run_data_list[i], merged_star_file)
    
    


def merge_star_file(file_1, file_2, merged_file):
    ## read run_data.star 
    star1 = starfile.read(file_1)
    star2 = starfile.read(file_2)

    ## Create for output
    merged_star = star1.copy()
    merged_star.pop('optics')
    merged_star.pop('particles')
    
    ## Extract 'optics' block (DataFrame)
    op1 = star1['optics']
    op2 = star2['optics']
    
    ## Consistency checks as needed (e.g., column names are the same)
    if not op1.columns.equals(op2.columns):
        raise ValueError("Columns in optics do not match.")

    ## Merge DataFrames vertically(Deduplication with 'rlnOpticsGroup' as key)
    key_column = 'rlnOpticsGroup'
    combined_op = pd.concat([op1, op2]).drop_duplicates(subset=[key_column])
    merged_star['optics'] = combined_op
    
    
    
    ## Extract 'particles' block (DataFrame)
    pt1 = star1['particles']
    #print(f'star1:{len(df1)}')
    pt2 = star2['particles']
    #print(f'star1:{len(df2)}')

    ## Consistency checks as needed (e.g., column names are the same)
    if not pt1.columns.equals(pt2.columns):
        raise ValueError("Columns in particles do not match.")

    ## Merge DataFrames vertically(Deduplication with 'rlnImageName' as key)
    key_column = 'rlnImageName'
    combined_pt = pd.concat([pt1, pt2]).drop_duplicates(subset=[key_column])
    merged_star['particles'] = combined_pt
    
    
    ## Save the combined result as a new STAR file
    if os.path.exists(merged_file):
        os.remove(merged_file)
    starfile.write(merged_star, merged_file, overwrite=True)
    print(f'{merged_file}: Optics:{len(combined_op)} Particles:{len(combined_pt)}')





def main():

    current_path = os.getcwd()
    current_path = current_path.replace('stacksplit_scheme', '')
    current_path = comm.fix_path_end(current_path)
    job_name = 'External/job100/'
    file_list = [
        '/fsx/yatabe_stacksplit_test/100_particles_split_1/Refine3D/job092/run_data.star',
        '/fsx/yatabe_stacksplit_test/100_particles_split_2/Refine3D/job092/run_data.star',
        '/fsx/yatabe_stacksplit_test/100_particles_split_3/Refine3D/job092/run_data.star',
        '/fsx/yatabe_stacksplit_test/100_particles_split_4/Refine3D/job092/run_data.star'
    ]
    
    

    merge_run_data_star(current_path, job_name, file_list)
    
    
    

    
    



if __name__ == "__main__":
    main()
    

