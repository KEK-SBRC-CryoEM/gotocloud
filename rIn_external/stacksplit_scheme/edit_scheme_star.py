#!/usr/bin/env python

import starfile
import os
import shutil
import pandas as pd
import stacksplit_common as ss_comm


def edit_nocheck_complete_prev_process(bool_data):
    scheme_bool_columns = [
        'rlnSchemeBooleanVariableName',
        'rlnSchemeBooleanVariableValue',
        'rlnSchemeBooleanVariableResetValue'
    ]

    target_items = [
        'CSS_lbin_center3d_do_limit_parts',
        'CSS_lbin_center3d_wait_prev_proc'
    ]

    for item in target_items:
        # print(f'item: {item}')
        mask = bool_data[scheme_bool_columns[0]] == item
        # print(f'mask: {mask}')

        ## Change value 0
        bool_data.loc[mask, scheme_bool_columns[1]] = 0
        bool_data.loc[mask, scheme_bool_columns[2]] = 0

    # print(bool_data)


def change_string_of_item(string_data, item_name, change_string):
    scheme_string_columns = [
        'rlnSchemeStringVariableName',
        'rlnSchemeStringVariableValue',
        'rlnSchemeStringVariableResetValue'
    ]

    mask = string_data[scheme_string_columns[0]] == item_name

    # Change string
    string_data.loc[mask, scheme_string_columns[1]] = change_string
    string_data.loc[mask, scheme_string_columns[2]] = change_string


def write_star_file(data_dict, star_file):
    temp_file = star_file + '.temp'
    starfile.write(data_dict, temp_file, overwrite=True)

    ## <NA> -> "" convert
    with open(temp_file, 'r') as infile, open(star_file, 'w') as outfile:
        for line in infile:
            line = line.replace('<NA>', '""')
            outfile.write(line)

    ## Delete temp file
    os.remove(temp_file)

    ##
    if fix_current_node_name(star_file) == False:
        raise ValueError(f'{star_file} fix error.')


def fix_current_node_name(file_name):
    SCHEME_NAME = '_rlnSchemeName'
    SCHEME_CURRENT_NODE_NAME = '_rlnSchemeCurrentNodeName'
    BLOCK_GENERAL = 'data_scheme_general'
    BLOCK_SCHEME_FLOAT = 'data_scheme_floats'
    target_string = ''
    index = 0

    with open(file_name, 'r') as infile:
        find_flg = False
        for line in infile:
            if find_flg:
                target_string = line
                break
            if SCHEME_CURRENT_NODE_NAME in line:
                find_flg = True
            index += 1

    if len(target_string) > 0:
        split_list = target_string.split('\t')
        if len(split_list) != 2:
            return False

        scheme_name = split_list[0]
        scheme_current_node_name = split_list[1]

        fix_scheme_name = f'{SCHEME_NAME}\t{scheme_name}\n'
        fix_scheme_current_node_name = f'{SCHEME_CURRENT_NODE_NAME}\t{scheme_current_node_name}\n'

        new_file = file_name + '.new'
        shutil.copy(file_name, new_file)
        with open(file_name, 'r') as infile, open(new_file, 'w') as outfile:
            edit_flg = False

            for line in infile:
                write_flg = True
                # print(f'[{len(line)}]: {line}')
                if edit_flg:
                    if BLOCK_SCHEME_FLOAT in line:
                        # print(f'{BLOCK_SCHEME_FLOAT} in {line}')
                        # print(f'**edit off**')
                        write_flg = True
                        edit_flg = False
                    else:

                        if SCHEME_NAME in line:
                            #           print(f'{line} -> {fix_scheme_name}')
                            line = fix_scheme_name
                        elif SCHEME_CURRENT_NODE_NAME in line:
                            #          print(f'{line} -> {fix_scheme_current_node_name}')
                            line = fix_scheme_current_node_name
                        elif len(line) > 0:
                            line = f'\n'

                else:
                    if BLOCK_GENERAL in line:
                        #     print(f'**edit on**')
                        edit_flg = True

                if write_flg:
                    # print(f'out: {line}')
                    outfile.write(line)

        os.remove(file_name)
        shutil.copy(new_file, file_name)
        os.remove(new_file)
        return True
    else:
        print('Not found current_node_name.')
        return False


def edit_scheme_star_file(star_file, item_string, change_string):
    SCHEME_STRINGS = 'scheme_strings'
    if os.path.exists(star_file):

        data_dict = starfile.read(star_file)
        # print(data_dict)

        ## Change string
        string_data = data_dict[SCHEME_STRINGS]
        change_string_of_item(string_data, item_string, change_string)

        data_dict[SCHEME_STRINGS] = string_data

        write_star_file(data_dict, star_file)
    else:
        print(f'"{star_file}" is not exists.')
        pass


def edit_060_scheme_star_file(star_file, split_file):
    SCHEME_BOOLS = 'scheme_bools'
    SCHEME_STRINGS = 'scheme_strings'

    PARTICLES_STAR_ITEM = "CSS_lbin_center3d_parts_star"

    ##scheme_string_columns = [
    ##    'rlnSchemeStringVariableName',
    ##    'rlnSchemeStringVariableValue',
    ##    'rlnSchemeStringVariableResetValue'
    ##]

    ### [Debug]
    # if  os.path.exists(target_path):
    #    # delete
    #    os.remove(target_path)
    # shutil.copy(base_file, target_path)

    if os.path.exists(star_file):

        data_dict = starfile.read(star_file)
        # print(data_dict)

        ## Extract 'data_scheme_bools' block data
        bool_data = data_dict[SCHEME_BOOLS]
        # print(bool_data)

        edit_nocheck_complete_prev_process(bool_data)
        # change 'data_scheme_bools' block data
        data_dict[SCHEME_BOOLS] = bool_data

        ## change string
        string_data = data_dict[SCHEME_STRINGS]
        change_string_of_item(string_data, PARTICLES_STAR_ITEM, split_file)
        data_dict[SCHEME_STRINGS] = string_data

        write_star_file(data_dict, star_file)
    else:
        print(f'"{star_file}" is not exists.')
        pass


def edit_scheme_star(current_path, sub_folder_path, split_file):
    current_schemes_010_path = os.path.join(current_path, 'Schemes/010_GTF_MotionCorr/')
    current_schemes_020_path = os.path.join(current_path, 'Schemes/020_GTF_CtfFind/')

    print(f'CurrentSchemes010: {current_schemes_010_path}')
    schemes_060_path = os.path.join(sub_folder_path, 'Schemes/060_CSS_Clean_Stack_3D/')
    schemes_070_path = os.path.join(sub_folder_path, 'Schemes/070_CSS_Init_Refine3D/')
    schemes_080_path = os.path.join(sub_folder_path, 'Schemes/080_CSS_PPRefine_Cycle/')
    print(f'Schemes060Path: {schemes_060_path}')
    run_out_010 = os.path.join(current_schemes_010_path, 'run.out')
    run_out_020 = os.path.join(current_schemes_020_path, 'run.out')

    star_file_060 = os.path.join(schemes_060_path, 'scheme.star')
    star_file_070 = os.path.join(schemes_070_path, 'scheme.star')
    star_file_080 = os.path.join(schemes_080_path, 'scheme.star')

    print(f'010/run.out: {run_out_010}')
    print(f'020/run.out: {run_out_020}')
    print(f'060/scheme.star: {star_file_060}')
    print(f'070/scheme.star: {star_file_070}')
    print(f'080/scheme.star: {star_file_080}')

    item_070 = 'SS_comm_ctf_mics_star'
    item_080 = 'SS_comm_motioncorr_mics_star'

    ## Edit 060/scheme.star
    edit_060_scheme_star_file(star_file_060, split_file)

    ## Edit 070/scheme.star
    job_name = ss_comm.extract_job_name_from_file(run_out_020, '020020_Select_mics')
    change_file = os.path.join(job_name, 'micrographs.star')
    print(f'070/020020_Select_mics/: {change_file}')
    edit_scheme_star_file(star_file_070, item_070, change_file)

    ## Edit 080/scheme.star
    job_name = ss_comm.extract_job_name_from_file(run_out_010, '010030_Select_mics')
    change_file = os.path.join(job_name, 'micrographs.star')
    print(f'080/010030_Select_mics/: {change_file}')
    edit_scheme_star_file(star_file_080, item_080, change_file)


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

    star_file_list = [
        '100_particles_split_1.star',
        '100_particles_split_2.star',
        '100_particles_split_3.star',
        '100_particles_split_4.star'
    ]

    index = 0
    for sub_folder in sub_folder_list:
        sub_folder_path = os.path.join(current_path, sub_folder)
        split_file = os.path.join(sub_folder_path, star_file_list[index])

        edit_scheme_star(current_path, sub_folder_path, split_file)
        index += 1


if __name__ == "__main__":
    main()







