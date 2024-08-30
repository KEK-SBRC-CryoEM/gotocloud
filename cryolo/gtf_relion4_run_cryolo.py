#!/usr/bin/env python2.7

# Author: Toshio Moriya 2021-Current (toshio.moriya@kek.jp)
#
# Copyright (c) 2021 KEK IMMS SBRC
# 
# gtf_relion4_run_cryolo_aws.py
# This is to run crYOLO picker from Relion as an External job type for AWS GoToCloud Enviroment
# Create: 2021/10/08 Toshio Moriya (KEK, SBRC)
# Modified: 2022/01/07 Toshio Moriya (KEK, SBRC)
#   - Added AWS GoToCloud support
#   - Added option to choose low-pass filter or JANNI denoise versions
#   - Repository Path
#     PF-GPFS       : /gpfs/data/EM/software/crYOLO
#     AWS-GoToCloud : /efs/em/crYOLO/#.#.# -> Currently /efs/em/crYOLO/1.8.0 (2022/01/07)
# 
# Run with Relion external job
# Provide executable in the gui: gtf_relion4_run_cryolo_aws.py
# Input micrographs.star
# Provide extra parameters in the parameters tab (scalefactor, trained_model, pick_threshold, select_threshold, skip_pick)

# IMPORTANT NOTE (2021/10/19 Toshio Moriya)
# Following RELION convension
# crYOLO should make directy under Exteranl/job###
# Inputs/Outputs of crYOLO
# - crYOLO/MOVIE_DIR/MOVIE_SUB_DIR/Hardlinks
# - crYOLO/MOVIE_DIR/MOVIE_SUB_DIR/Predict
# - crYOLO/MOVIE_DIR/MOVIE_SUB_DIR/Filtered
# - crYOLO/MOVIE_DIR/MOVIE_SUB_DIR/gmodel_janni.h5               <<<<< Use hardlink to avoid duplication!
# - crYOLO/MOVIE_DIR/MOVIE_SUB_DIR/gmodel_phosnet_denoise.h5     <<<<< Use hardlink to avoid duplication!
# - crYOLO/MOVIE_DIR/MOVIE_SUB_DIR/config_cryolo.json            <<<<< Use hardlink to avoid duplication!
# - crYOLO/MOVIE_DIR/MOVIE_SUB_DIR/logs
# - crYOLO/gmodel_janni.h5
# - crYOLO/gmodel_phosnet_denoise.h5
# - crYOLO/config_cryolo.json
# 
# Outputs for RELION
# - MOVIE_DIR/MOVIE_SUB_DIR/MIC_ROOT_NAME_autopick.star
# - autopick.star
# ### - summary.star
# ### - logfile.pdf (histogram_FOMs.eps, histogram_nrparts.eps)
# - RELION_JOB_EXIT_SUCCESS
# - job_pipeline.star 
# Append
# ++++++++++++++++++++++++++++++
# # version 30001
# 
# data_pipeline_output_edges
# 
# loop_ 
# _rlnPipeLineEdgeProcess #1 
# _rlnPipeLineEdgeToNode #2 
# Exteranl/job###/ Exteranl/job###/autopick.star 
### # Exteranl/job###/ Exteranl/job###/logfile.pdf 
# ++++++++++++++++++++++++++++++


"""Import >>>"""
import argparse
import os
import shutil  # copyfile
import sys
import pprint
import pathlib
"""<<< Import"""

"""USAGE >>>"""
print("This wrapper runs SPHIRE-crYOLO in AWS GoToCloud Enviroment")
"""<<< USAGE"""

"""VARIABLES >>>"""
print('running ...')
parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input", "--in_mics",  type=str,                                              help = "RELION requirement! Input micrographs star file Path (relative)")
parser.add_argument("-o", "--output",              type=str,                                              help = "RELION requirement! Output job directory path (relative)")
parser.add_argument("-r", "--cryolo_repo",         type=str,                                              help = "crYOLO repository directory path (full).")
parser.add_argument("-t", "--threshold",           type=float,           default=0.3,                     help = "Particle selection threshold.")
parser.add_argument("-g", "--device",              type=str,             default='0',                     help = "GPU device. To use multiple device, use camma like relion (e.g. 0,1,2,3)")
parser.add_argument("-n", "--denoise",             action="store_true",  default=False,                   help = "Use JANNI denoising instead of low-pass filtering (default False)")
parser.add_argument("-j", "--j", "--threads",      type=str,             default='1',                     help = "Number of threads (Input from RELION. Not used here).")
args, unknown = parser.parse_known_args()

inargs_mics = args.input
outargs_rpath = args.output
cryolo_work_rpath = "crYOLO"
cryolo_repo_fpath = str(args.cryolo_repo)
threshold = args.threshold
device = str(args.device)
denoise = args.denoise
threads =  args.j
invalid_str = "GTF_INVALID_STR" 

print('[GTF_DEBUG] inargs_mics       : %s' % inargs_mics)
print('[GTF_DEBUG] outargs_rpath     : %s' % outargs_rpath)
print('[GTF_DEBUG] cryolo_work_rpath : %s' % cryolo_work_rpath)
print('[GTF_DEBUG] cryolo_repo_fpath : %s' % cryolo_repo_fpath)
print('[GTF_DEBUG] threshold         : %f' % threshold)
print('[GTF_DEBUG] device            : %s' % device)
print('[GTF_DEBUG] denoise           : %s' % denoise)
print('[GTF_DEBUG] threads           : %s' % threads)

# Define constants 
cryolo_predict_exe = 'cryolo_predict.py'

cryolo_repo_model_file_rpath = os.path.join(cryolo_repo_fpath, "gmodel_phosnet_lpf_link.h5")
cryolo_repo_janni_file_rpath = invalid_str
model_file_name = "gmodel_phosnet_lpf.h5"
janni_file_name = invalid_str
if denoise:
	cryolo_repo_model_file_rpath = os.path.join(cryolo_repo_fpath, "gmodel_phosnet_denoise_link.h5")
	cryolo_repo_janni_file_rpath = os.path.join(cryolo_repo_fpath, "gmodel_janni_link.h5")
	model_file_name    = "gmodel_phosnet_denoise.h5"
	janni_file_name    = "gmodel_janni.h5"

filtered_dir_name  = "Filtered/"
log_dir_name       = "Logs/"
config_file_name   = "config_cryolo.json"
motioncor_dir_name = "MotionCor/"
predict_dir_name   = "Predict/"

print('[GTF_DEBUG] cryolo_predict_exe             : %s' % cryolo_predict_exe)
print('[GTF_DEBUG] cryolo_repo_model_file_rpath   : %s' % cryolo_repo_model_file_rpath)
print('[GTF_DEBUG] cryolo_repo_janni_file_rpath   : %s' % cryolo_repo_janni_file_rpath)
print('[GTF_DEBUG] model_file_name                : %s' % model_file_name)
print('[GTF_DEBUG] janni_file_name                : %s' % janni_file_name)
print('[GTF_DEBUG] filtered_dir_name              : %s' % filtered_dir_name)
print('[GTF_DEBUG] log_dir_name                   : %s' % log_dir_name)
print('[GTF_DEBUG] config_file_name               : %s' % config_file_name)
print('[GTF_DEBUG] motioncor_dir_name             : %s' % motioncor_dir_name)
print('[GTF_DEBUG] predict_dir_name               : %s' % predict_dir_name)
"""<<< VARIABLES"""

"""Preparation >>>"""
# pprint.pprint(sys.path)
sys.path.append(cryolo_repo_fpath)
# pprint.pprint(sys.path)
import gtf_relion4_prep_cryolo
micrographs_dict = gtf_relion4_prep_cryolo.run(inargs_mics, outargs_rpath, cryolo_work_rpath)
"""<<< Preparation"""

autopick_star_file_path = os.path.join(outargs_rpath, "autopick.star")
autopick_star_file = open(autopick_star_file_path,'w')
autopick_star_file.write("\n")
autopick_star_file.write("# version 30001\n")
autopick_star_file.write("\n")
autopick_star_file.write("data_coordinate_files\n")
autopick_star_file.write("\n")
autopick_star_file.write("loop_\n")
autopick_star_file.write("_rlnMicrographName #1 \n")
autopick_star_file.write("_rlnMicrographCoordinates #2 \n")

for micrograph_dir_name in sorted(micrographs_dict):
	print('[GTF_DEBUG] ')
	print('[GTF_DEBUG] micrograph_dir_name : %s' % micrograph_dir_name)
	# Remove first two directories (i.e. MotionCor/job###) from the path
	relion_movie_dirname_tuple = pathlib.Path(micrograph_dir_name).parts[2:]
	# print('[GTF_DEBUG] relion_movie_dirname_tuple : %s' % relion_movie_dirname_tuple)
	assert len(relion_movie_dirname_tuple) > 0, '# Logical Error: relion_movie_dirname_tuple should have at least one elements.'
	relion_movie_dir_rpath = str(pathlib.Path(*relion_movie_dirname_tuple))
	print('[GTF_DEBUG] relion_movie_dir_rpath : %s' % relion_movie_dir_rpath)
	
	# current_work_rpath = os.path.join(cryolo_work_rpath, relion_movie_dir_rpath)
	current_work_rpath = os.path.join(outargs_rpath, cryolo_work_rpath, relion_movie_dir_rpath)
	assert os.path.exists(current_work_rpath), '# Logical Error: Current work directory {} should exist at this point of code.'.format(current_work_rpath)
	
	"""picking >>>"""
	# NOTE 2021/10/10: Toshio Moriya 
	# Change the current directory to the specified output directory
	# It is because of the poor implementation of crYOLO,
	# the config file does not support path deeper than one level
	# for filter janni file, filtered_tmp directory, and log directory... 
	# print('[GTF_DEBUG] current_path  : %s' % os.getcwd())
	original_path = os.getcwd()
	os.chdir(current_work_rpath)
	# print('[GTF_DEBUG] original_path : %s' % original_path)
	# print('[GTF_DEBUG] current_path  : %s' % os.getcwd())

	shutil.copyfile(cryolo_repo_model_file_rpath, model_file_name)
	if denoise:
		shutil.copyfile(cryolo_repo_janni_file_rpath, janni_file_name)
	
	# Using "with" statement, we don't need to call config_file.close()
	# Using print we don't need to add "\n" at the end of each line
	with open(config_file_name, 'w') as config_file:
		if not denoise:
			print('{',                                             file=config_file)
			print('    "model": {',                                file=config_file)
			print('        "architecture": "PhosaurusNet",',       file=config_file)
			print('        "input_size": 1024,',                   file=config_file)
			print('        "max_box_per_image": 700,',             file=config_file)
			print('        "norm": "STANDARD",',                   file=config_file)
			print('        "filter": [',                           file=config_file)
			print('            0.1,',                              file=config_file)
			print('            "{}"'.format(filtered_dir_name),    file=config_file)
			print('        ]',                                     file=config_file)
			print('    },',                                        file=config_file)
			print('    "other": {',                                file=config_file)
			print('        "log_path": "{}"'.format(log_dir_name), file=config_file)
			print('    }',                                         file=config_file)
			print('}',                                             file=config_file)
		else:
			assert denoise, '# Logical Error: denoise should be true.'
			print('{',                                             file=config_file)
			print('    "model": {',                                file=config_file)
			print('        "architecture": "PhosaurusNet",',       file=config_file)
			print('        "input_size": 1024,',                   file=config_file)
			print('        "max_box_per_image": 700,',             file=config_file)
			print('        "norm": "STANDARD",',                   file=config_file)
			print('        "filter": [',                           file=config_file)
			print('            "{}",'.format(janni_file_name),     file=config_file)
			print('            24,',                               file=config_file)
			print('            3,',                                file=config_file)
			print('            "{}"'.format(filtered_dir_name),    file=config_file)
			print('        ]',                                     file=config_file)
			print('    },',                                        file=config_file)
			print('    "other": {',                                file=config_file)
			print('        "log_path": "{}"'.format(log_dir_name), file=config_file)
			print('    }',                                         file=config_file)
			print('}',                                             file=config_file)

	cmd_cryolo_predict = cryolo_predict_exe
	cmd_cryolo_predict += str(' -c ') + config_file_name
	cmd_cryolo_predict += str(' -w ') + model_file_name
	cmd_cryolo_predict += str(' -i ') + motioncor_dir_name
	cmd_cryolo_predict += str(' -o ') + predict_dir_name
	cmd_cryolo_predict += str(' -t ') + str(threshold)
	cmd_cryolo_predict += str(' -g ') + device.replace(',', ' ')
	print('[GTF_DEBUG] Running command: %s' % cmd_cryolo_predict)
	os.system(cmd_cryolo_predict)
	
	# print('[GTF_DEBUG] current_path  : %s' % os.getcwd())
	os.chdir(original_path)
	# print('[GTF_DEBUG] current_path  : %s' % os.getcwd())

	"""<<< picking"""
	
	"""Make star files >>>"""
	
	# Create star files in the right folder
	print('Creating star files...')
	# 2021/11/11 To support Relion's continue functions
	if not os.path.exists(os.path.join(outargs_rpath, relion_movie_dir_rpath)):
		print('[GTF_DEBUG] Making relion movie directory under this job folder : %s' % os.path.join(outargs_rpath, relion_movie_dir_rpath))
		os.makedirs(os.path.join(outargs_rpath, relion_movie_dir_rpath))
	
#	mic_filenames=list(set([x.split('\t')[0] for x in open(outargs_results2).readlines()[1:]]))
#	cryolo_picks=[x.split('\t') for x in open(outargs_results2).readlines()[1:]]
#	for name in mic_filenames:
#		star_file=cryolo_cbox_dir_rpath+name+'_cryolopicks.star'
#		with open(star_file, 'w') as f:
#			f.write('# version 30001\n\ndata_\n\nloop_\n_rlnCoordinateX #1\n_rlnCoordinateY #2\n_rlnAutopickFigureOfMerit #3\n')
#			for line in cryolo_picks:
#				if name == line[0]:
#					f.write(line[1]+'\t'+ line[2]+'\t'+ line[3])
#	#make coords_suffix_extract.star file
#	f=open(outargs_rpath+"coords_suffix_cryolopicks.star","w+")
#	f.write(inargs_mics)
#	f.close()
#	print('star files done')

	import glob
	cryolo_cbox_dir_rpath = os.path.join(current_work_rpath, predict_dir_name, "CBOX", "*.cbox")
	print('[GTF_DEBUG] cryolo_cbox_dir_rpath : %s' % cryolo_cbox_dir_rpath)
	cbox_file_rpath_list = glob.glob(cryolo_cbox_dir_rpath)
	# print('[GTF_DEBUG] cbox_file_rpath_list : %s' % cbox_file_rpath_list)
	if len(cbox_file_rpath_list) == 0:
		print ("ERROR")
		exit

	### # ------------------------------------------------------------------------------------
	### # 2022/01/08: Old format before crYOLO 1.8.0
	### # The definition of CBOX format
	### # $ find /gpfs/data/EM/software/pyenv/versions/anaconda3-5.3.1/envs/cryolo -name \*utils.py -type f
	### # /gpfs/data/EM/software/pyenv/versions/anaconda3-5.3.1/envs/cryolo/lib/python3.6/site-packages/cryolo/utils.py
	### # => class BoundBox: def __init__(self, x, y, w, h, c=None, classes=None):
	### #        Creates a BoundBox
	### #        :param x: x coordinate of the center <=> box[0]
	### #        :param y: y coordinate of the center <=> box[1]
	### #        :param w: width of box               <=> box[2]
	### #        :param h: height of the box          <=> box[3]
	### #        :param c: confidence of the box      <=> box[4]
	### #        :param classes: Class of the BoundBox object
	### 
	### i_enum = -1
	### i_enum += 1; idx_cbox_x_coordinate     = i_enum
	### i_enum += 1; idx_cbox_y_coordinate     = i_enum
	### i_enum += 1; idx_cbox_with             = i_enum
	### i_enum += 1; idx_cbox_height           = i_enum
	### i_enum += 1; idx_cbox_confidence       = i_enum
	### i_enum += 1; idx_cbox_estimated_width  = i_enum
	### i_enum += 1; idx_cbox_estimated_heght  = i_enum
	### i_enum += 1; n_idx_cbox                = i_enum
	### 
	### # print('[GTF_DEBUG] idx_cbox_x_coordinate    : %i' % idx_cbox_x_coordinate)
	### # print('[GTF_DEBUG] idx_cbox_y_coordinate    : %i' % idx_cbox_y_coordinate)
	### # print('[GTF_DEBUG] idx_cbox_with            : %i' % idx_cbox_with)
	### # print('[GTF_DEBUG] idx_cbox_height          : %i' % idx_cbox_height)
	### # print('[GTF_DEBUG] idx_cbox_confidence      : %i' % idx_cbox_confidence)
	### # print('[GTF_DEBUG] idx_cbox_estimated_width : %i' % idx_cbox_estimated_width)
	### # print('[GTF_DEBUG] idx_cbox_estimated_heght : %i' % idx_cbox_estimated_heght)
	### # print('[GTF_DEBUG] n_idx_cbox               : %i' % n_idx_cbox)
	### # ------------------------------------------------------------------------------------

	# ------------------------------------------------------------------------------------
	# 2022/01/08: New format since crYOLO 1.8.0
	# The definition of CBOX format
	# $ find /efs/em/pyenv/versions/anaconda3-5.3.1/envs/cryolo-1.8.0 -name \*utils.py -type f
	# /efs/em/pyenv/versions/anaconda3-5.3.1/envs/cryolo-1.8.0/lib/python3.8/site-packages/cryolo/utils.py
	# => class BoundBox: def __init__(self, x, y, w, h, c=None, classes=None, z=None, depth=None):
	#        """
	#        Creates a BoundBox
	#        :param x: x coordinate of the center    <=> box[0] <= _CoordinateX #1
	#        :param y: y coordinate of the center    <=> box[1] <= _CoordinateY #2
	#        :param z: z coordinate of the center    <=> box[2] <= _CoordinateZ #3
	#        :param w: width of box                  <=> box[3] <= _Width #4
	#        :param h: height of the box             <=> box[4] <= _Height #5
	#        :param depth: depth of the box          <=> box[5] <= _Depth #6
	#        :param c: confidence of the box         <=> box[8] <= _Confidence #9
	#        :param classes: Class of the BoundBox object
	#        """
	
	i_enum = -1
	i_enum += 1; idx_cbox_x_coordinate     = i_enum  # <= _CoordinateX #1
	i_enum += 1; idx_cbox_y_coordinate     = i_enum  # <= _CoordinateY #2
	i_enum += 1; idx_cbox_z_coordinate     = i_enum  # <= _CoordinateZ #3 >>> <NA> for SPA
	i_enum += 1; idx_cbox_with             = i_enum  # <= _Width #4
	i_enum += 1; idx_cbox_height           = i_enum  # <= _Height #5
	i_enum += 1; idx_cbox_depth            = i_enum  # <= _Depth #6  >>> <NA> for SPA
	i_enum += 1; idx_cbox_estimated_width  = i_enum  # <= _EstWidth #7
	i_enum += 1; idx_cbox_estimated_heght  = i_enum  # <= _EstHeight #8
	i_enum += 1; idx_cbox_confidence       = i_enum  # <= _Confidence #9
	i_enum += 1; idx_cbox_num_boxes        = i_enum  # <= _NumBoxes #10  >>> <NA> for SPA
	i_enum += 1; idx_cbox_angle            = i_enum  # <= _Angle #11  >>> <NA> for SPA
	i_enum += 1; n_idx_cbox                = i_enum
	
	# print('[GTF_DEBUG] idx_cbox_x_coordinate    : %i' % idx_cbox_x_coordinate)
	# print('[GTF_DEBUG] idx_cbox_y_coordinate    : %i' % idx_cbox_y_coordinate)
	# print('[GTF_DEBUG] idx_cbox_z_coordinate    : %i' % idx_cbox_z_coordinate)
	# print('[GTF_DEBUG] idx_cbox_with            : %i' % idx_cbox_with)
	# print('[GTF_DEBUG] idx_cbox_height          : %i' % idx_cbox_height)
	# print('[GTF_DEBUG] idx_cbox_depth           : %i' % idx_cbox_depth)
	# print('[GTF_DEBUG] idx_cbox_estimated_width : %i' % idx_cbox_estimated_width)
	# print('[GTF_DEBUG] idx_cbox_estimated_heght : %i' % idx_cbox_estimated_heght)
	# print('[GTF_DEBUG] idx_cbox_confidence      : %i' % idx_cbox_confidence)
	# print('[GTF_DEBUG] idx_cbox_num_boxes       : %i' % idx_cbox_num_boxes)
	# print('[GTF_DEBUG] idx_cbox_angle           : %i' % idx_cbox_angle)
	# print('[GTF_DEBUG] n_idx_cbox               : %i' % n_idx_cbox)
	# ------------------------------------------------------------------------------------

	i_enum = -1
	i_enum += 1; idx_mic_coords_star_CoordinateX  = i_enum
	i_enum += 1; idx_mic_coords_star_CoordinateY  = i_enum
	i_enum += 1; idx_mic_coords_star_AutopickFOM  = i_enum
	i_enum += 1; idx_mic_coords_star_ClassNumber  = i_enum  # Always "0"
	i_enum += 1; idx_mic_coords_star_AnglePsi     = i_enum  # Always "0.000000"
	i_enum += 1; n_idx_idx_mic_coords_star        = i_enum

	# print('[GTF_DEBUG] idx_mic_coords_star_CoordinateX  : %i' % idx_mic_coords_star_CoordinateX)
	# print('[GTF_DEBUG] idx_mic_coords_star_CoordinateY  : %i' % idx_mic_coords_star_CoordinateY)
	# print('[GTF_DEBUG] idx_mic_coords_star_AutopickFOM  : %i' % idx_mic_coords_star_AutopickFOM)
	# print('[GTF_DEBUG] idx_mic_coords_star_ClassNumber  : %i' % idx_mic_coords_star_ClassNumber)
	# print('[GTF_DEBUG] idx_mic_coords_star_AnglePsi     : %i' % idx_mic_coords_star_AnglePsi)
	# print('[GTF_DEBUG] n_idx_idx_mic_coords_star        : %i' % n_idx_idx_mic_coords_star)

	i_enum = -1
	i_enum += 1; idx_autopick_star_MicrographName        = i_enum
	i_enum += 1; idx_autopick_star_MicrographCoordinates = i_enum
	i_enum += 1; n_idx_autopick_star                     = i_enum

	# print('[GTF_DEBUG] idx_autopick_star_MicrographName         : %i' % idx_autopick_star_MicrographName)
	# print('[GTF_DEBUG] idx_autopick_star_MicrographCoordinates  : %i' % idx_autopick_star_MicrographCoordinates)
	# print('[GTF_DEBUG] n_idx_autopick_star                      : %i' % n_idx_autopick_star)


	# Register micrograph id substrings to the global entry dictionary
	print('[GTF_DEBUG] Staring looping through all CBOX files in the current directory...' )
	for cbox_file_path in cbox_file_rpath_list:
		print('[GTF_DEBUG] cbox_file_path : %s' % cbox_file_path)
		cbox_file_basename = os.path.basename(cbox_file_path)
		# print('[GTF_DEBUG] cbox_file_basename : %s' % cbox_file_basename)
		mic_coords_star_file_basename = os.path.splitext(cbox_file_basename)[0]+"_autopick.star"
		# print('[GTF_DEBUG] mic_coords_star_file_basename : %s' % mic_coords_star_file_basename)
		mic_coords_star_file_path = os.path.join(outargs_rpath, relion_movie_dir_rpath, mic_coords_star_file_basename)
		# print('[GTF_DEBUG] mic_coords_star_file_path : %s' % mic_coords_star_file_path)
		
		autopick_star_line_tokens = [0] * n_idx_autopick_star
		autopick_star_line_tokens[idx_autopick_star_MicrographName]        = os.path.join(micrograph_dir_name, os.path.splitext(cbox_file_basename)[0]+".mrc")
		autopick_star_line_tokens[idx_autopick_star_MicrographCoordinates] = mic_coords_star_file_path
		autopick_star_line_str =  "{} ".format(autopick_star_line_tokens[idx_autopick_star_MicrographName])
		autopick_star_line_str += "{} ".format(autopick_star_line_tokens[idx_autopick_star_MicrographCoordinates])
		autopick_star_line_str += "\n"
		autopick_star_file.write(autopick_star_line_str)
		
		# 2021/11/11 To support Relion's continue functions
		if not os.path.exists(mic_coords_star_file_path):
			# Open cbox files
			assert os.path.exists(cbox_file_path), '# Logical Error: Input CBOX file must exits at this point of code.'
			cbox_file = open(cbox_file_path,'r')
			mic_coords_star_file = open(mic_coords_star_file_path,'w')
			mic_coords_star_file.write("\n")
			mic_coords_star_file.write("# version 30001\n")
			mic_coords_star_file.write("\n")
			mic_coords_star_file.write("data_\n")
			mic_coords_star_file.write("\n")
			mic_coords_star_file.write("loop_\n")
			mic_coords_star_file.write("_rlnCoordinateX #1 \n")
			mic_coords_star_file.write("_rlnCoordinateY #2 \n")
			mic_coords_star_file.write("_rlnAutopickFigureOfMerit #3 \n")
			mic_coords_star_file.write("_rlnClassNumber #4 \n")
			mic_coords_star_file.write("_rlnAnglePsi #5 \n")
	
			for cbox_line_id, cbox_line_str in enumerate(cbox_file):
				# if cbox_line_id == 1:
				# 	print('[GTF_DEBUG] cbox_line_id  : %i' % cbox_line_id)
				# 	print('[GTF_DEBUG] cbox_line_str : %s' % cbox_line_str)
		
				cbox_line_tokens = cbox_line_str.split() # print cbox_line_tokens
				n_cbox_line_tokens = len(cbox_line_tokens)
				### # ------------------------------------------------------------------------------------
				### # 2022/01/08: Old format before crYOLO 1.8.0
				### # if cbox_line_id == 1:
				### # 	print('[GTF_DEBUG] cbox_line_tokens : %s' % cbox_line_str)
				### # 	print('[GTF_DEBUG]   cbox_line_tokens[idx_cbox_x_coordinate]    : %s' % cbox_line_tokens[idx_cbox_x_coordinate])
				### # 	print('[GTF_DEBUG]   cbox_line_tokens[idx_cbox_y_coordinate]    : %s' % cbox_line_tokens[idx_cbox_y_coordinate])
				### # 	print('[GTF_DEBUG]   cbox_line_tokens[idx_cbox_with]            : %s' % cbox_line_tokens[idx_cbox_with])
				### # 	print('[GTF_DEBUG]   cbox_line_tokens[idx_cbox_height]          : %s' % cbox_line_tokens[idx_cbox_height])
				### # 	print('[GTF_DEBUG]   cbox_line_tokens[idx_cbox_confidence]      : %s' % cbox_line_tokens[idx_cbox_confidence])
				### # 	print('[GTF_DEBUG]   cbox_line_tokens[idx_cbox_estimated_width] : %s' % cbox_line_tokens[idx_cbox_estimated_width])
				### # 	print('[GTF_DEBUG]   cbox_line_tokens[idx_cbox_estimated_heght] : %s' % cbox_line_tokens[idx_cbox_estimated_heght])
				### # 	print('[GTF_DEBUG] n_cbox_line_tokens : %s' % n_cbox_line_tokens)
				### # ------------------------------------------------------------------------------------
				
				# ------------------------------------------------------------------------------------
				# 2022/01/08: New format since crYOLO 1.8.0
				# if cbox_line_id == 1:
				# 	print('[GTF_DEBUG] cbox_line_tokens : %s' % cbox_line_str)
				# 	print('[GTF_DEBUG]   cbox_line_tokens[idx_cbox_x_coordinate]    : %s' % cbox_line_tokens[idx_cbox_x_coordinate])
				# 	print('[GTF_DEBUG]   cbox_line_tokens[idx_cbox_y_coordinate]    : %s' % cbox_line_tokens[idx_cbox_y_coordinate])
				# 	print('[GTF_DEBUG]   cbox_line_tokens[idx_cbox_z_coordinate]    : %s' % cbox_line_tokens[idx_cbox_z_coordinate])
				# 	print('[GTF_DEBUG]   cbox_line_tokens[idx_cbox_with]            : %s' % cbox_line_tokens[idx_cbox_with])
				# 	print('[GTF_DEBUG]   cbox_line_tokens[idx_cbox_height]          : %s' % cbox_line_tokens[idx_cbox_height])
				# 	print('[GTF_DEBUG]   cbox_line_tokens[idx_cbox_depth]           : %s' % cbox_line_tokens[idx_cbox_depth])
				# 	print('[GTF_DEBUG]   cbox_line_tokens[idx_cbox_estimated_width] : %s' % cbox_line_tokens[idx_cbox_estimated_width])
				# 	print('[GTF_DEBUG]   cbox_line_tokens[idx_cbox_estimated_heght] : %s' % cbox_line_tokens[idx_cbox_estimated_heght])
				# 	print('[GTF_DEBUG]   cbox_line_tokens[idx_cbox_confidence]      : %s' % cbox_line_tokens[idx_cbox_confidence])
				# 	print('[GTF_DEBUG]   cbox_line_tokens[idx_cbox_num_boxes]       : %s' % cbox_line_tokens[idx_cbox_num_boxes])
				# 	print('[GTF_DEBUG]   cbox_line_tokens[idx_cbox_angle]           : %s' % cbox_line_tokens[idx_cbox_angle])
				# 	print('[GTF_DEBUG] n_cbox_line_tokens : %s' % n_cbox_line_tokens)
				# ------------------------------------------------------------------------------------
				
				# 2022/01/08: With new format since crYOLO 1.8.0,
				# check if the number of entries of each line match with n_cbox_line_tokens
				if n_cbox_line_tokens == n_idx_cbox:
					mic_coords_star_line_tokens = [0] * n_idx_idx_mic_coords_star
					mic_coords_star_line_tokens[idx_mic_coords_star_CoordinateX] = float(cbox_line_tokens[idx_cbox_x_coordinate])
					mic_coords_star_line_tokens[idx_mic_coords_star_CoordinateY] = float(cbox_line_tokens[idx_cbox_y_coordinate])
					mic_coords_star_line_tokens[idx_mic_coords_star_AutopickFOM] = float(cbox_line_tokens[idx_cbox_confidence])
					mic_coords_star_line_tokens[idx_mic_coords_star_ClassNumber] = 0 # Always "0" 
					mic_coords_star_line_tokens[idx_mic_coords_star_AnglePsi]    = 0.000000 # Always "0.000000"
					
					# if cbox_line_id == 1:
					# 	print('[GTF_DEBUG] mic_coords_star_line_tokens : %s' % mic_coords_star_line_tokens)
					# 	print('[GTF_DEBUG]   mic_coords_star_line_tokens[idx_mic_coords_star_CoordinateX] : %s' % mic_coords_star_line_tokens[idx_mic_coords_star_CoordinateX])
					# 	print('[GTF_DEBUG]   mic_coords_star_line_tokens[idx_mic_coords_star_CoordinateY] : %s' % mic_coords_star_line_tokens[idx_mic_coords_star_CoordinateY])
					# 	print('[GTF_DEBUG]   mic_coords_star_line_tokens[idx_mic_coords_star_AutopickFOM] : %s' % mic_coords_star_line_tokens[idx_mic_coords_star_AutopickFOM])
					# 	print('[GTF_DEBUG]   mic_coords_star_line_tokens[idx_mic_coords_star_ClassNumber] : %s' % mic_coords_star_line_tokens[idx_mic_coords_star_ClassNumber])
					# 	print('[GTF_DEBUG]   mic_coords_star_line_tokens[idx_mic_coords_star_AnglePsi]    : %s' % mic_coords_star_line_tokens[idx_mic_coords_star_AnglePsi])
					
					mic_coords_star_line_str =  "{:12.6f} ".format(mic_coords_star_line_tokens[idx_mic_coords_star_CoordinateX])
					mic_coords_star_line_str += "{:12.6f} ".format(mic_coords_star_line_tokens[idx_mic_coords_star_CoordinateY])
					mic_coords_star_line_str += "{:12.6f} ".format(mic_coords_star_line_tokens[idx_mic_coords_star_AutopickFOM])
					mic_coords_star_line_str += "{:12d} ".format(mic_coords_star_line_tokens[idx_mic_coords_star_ClassNumber])
					mic_coords_star_line_str += "{:12.6f} ".format(mic_coords_star_line_tokens[idx_mic_coords_star_AnglePsi])
					mic_coords_star_line_str += "\n"
					# if cbox_line_id == 1:
					# 	print('[GTF_DEBUG] mic_coords_star_line_str : %s' % mic_coords_star_line_str)
					mic_coords_star_file.write(mic_coords_star_line_str)
				# else:
					# assert n_cbox_line_tokens != n_idx_cbox, '# Logical Error: This should not happen.'
					# print('[GTF_DEBUG] cbox_line_id  : %i' % cbox_line_id)
					# print('[GTF_DEBUG] cbox_line_str : %s' % cbox_line_str)

			mic_coords_star_file.close()
			cbox_file.close()
	"""<<< Make star files"""
	
autopick_star_file.close()

# """Make coords_suffix_extract.star file >>>"""
# print('Creating coords_suffix star file ...')
# print('[GTF_DEBUG] inargs_mics : %s' % inargs_mics)
# # relion_coords_suffix_star_file = open(os.path.join(outargs_rpath, "coords_suffix_cryolopicks.star"),"w+")
# relion_coords_suffix_star_file = open(os.path.join(outargs_rpath, "coords_suffix_cryolopicks.star"),"w")
# relion_coords_suffix_star_file.write("{}\n".format(inargs_mics))
# relion_coords_suffix_star_file.close()
# """<<< Make coords_suffix_extract.star file"""

"""Finishing up >>>"""

print('Creating RELION_OUTPUT_NODES star file ...')
# relion_output_nodes_star_file = open(os.path.join(outargs_rpath, "RELION_OUTPUT_NODES.star"),"w+")
relion_output_nodes_star_file = open(os.path.join(outargs_rpath, "RELION_OUTPUT_NODES.star"),"w")
relion_output_nodes_star_file.write("\n")
relion_output_nodes_star_file.write("# version 30001\n")
relion_output_nodes_star_file.write("data_output_nodes\n")
relion_output_nodes_star_file.write("\n")
relion_output_nodes_star_file.write("loop_\n")
relion_output_nodes_star_file.write("_rlnPipeLineNodeName #1 \n")
# relion_output_nodes_star_file.write("_rlnPipeLineNodeType #2\n")
relion_output_nodes_star_file.write("_rlnPipeLineNodeTypeLabel #2 \n")
# relion_output_nodes_star_file.write("{} 2\n".format(os.path.join(outargs_rpath, "coords_suffix_cryolopicks.star")))
# relion_output_nodes_star_file.write("{} 2\n".format(os.path.join(outargs_rpath, "autopick.star")))
relion_output_nodes_star_file.write("{} MicrographsCoords.star.relion.autopick \n".format(os.path.join(outargs_rpath, "autopick.star")))
# relion_output_nodes_star_file.write(logfile+" 13")
relion_output_nodes_star_file.write("\n")
relion_output_nodes_star_file.close()


relion_job_exit_status_file=open(os.path.join(outargs_rpath, "RELION_JOB_EXIT_SUCCESS"),"w")
relion_job_exit_status_file.close()

print('[GTF_DEBUG] Done')
"""<<< Finishing up"""
