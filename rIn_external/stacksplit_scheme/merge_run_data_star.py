import starfile
import pandas as pd
import os
import stacksplit_common as comm

def merge_run_data_star(file_1, file_2, merged_file):
    ## read run_data.star 
    star1 = starfile.read(file_1)
    star2 = starfile.read(file_2)

    ## Create for output
    output_star = star1.copy()
    output_star.pop('optics')
    output_star.pop('particles')
    
    ## Extract 'optics' block (DataFrame)
    op1 = star1['optics']
    op2 = star2['optics']
    
    ## Consistency checks as needed (e.g., column names are the same)
    if not op1.columns.equals(op2.columns):
        raise ValueError("Columns in optics do not match.")

    ## Merge DataFrames vertically(Deduplication with 'rlnOpticsGroup' as key)
    key_column = 'rlnOpticsGroup'
    combined_op = pd.concat([op1, op2]).drop_duplicates(subset=[key_column])
    output_star['optics'] = combined_op
    
    
    
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
    output_star['particles'] = combined_pt
    
    ## Save the combined result as a new STAR file
    if os.path.exists(merged_file):
        os.remove(merged_file)
    starfile.write(output_star, merged_file, overwrite=True)
    print(f'{merged_file}: {len(combined_df)}')





def main():

    current_path = os.getcwd()
    current_path = current_path.replace('stacksplit_scheme', '')
    current_path = comm.fix_path_end(current_path)
    
    
    file_1 = '/fsx/yatabe_stacksplit_test/100_particles_split_1_ended/Refine3D/job092/run_data.star'
    file_2 = '/fsx/yatabe_stacksplit_test/100_particles_split_2_ended/Refine3D/job092/run_data.star'
    merged_file = os.path.join(current_path, 'merged_run_data.star')

    merge_run_data_star(file_1, file_2, merged_file)
    
    
    

    
    



if __name__ == "__main__":
    main()
    

