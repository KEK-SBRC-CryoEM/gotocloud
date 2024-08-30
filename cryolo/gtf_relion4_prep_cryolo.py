#!/usr/bin/env python2.7

# Author: Toshio Moriya 2021-Current (toshio.moriya@kek.jp)
#
# Copyright (c) 2021 KEK IMMS SBRC
#
# [Develop Notes]
# - 2021/10/10 Toshio Moriya: Add training support
# In near future, I want add preparation of training datasets for crYOLO
# from RELION4 Particles STAR file!
# ========================================================================================

from sys import  *
import os
import sys
import shutil
import time
from optparse import OptionParser
from operator import itemgetter
import math
import numpy as np
import pathlib

# ========================================================================================
# Helper Functions
# ========================================================================================
# ----------------------------------------------------------------------------------------
# Generate command line
# ----------------------------------------------------------------------------------------
def gtf_get_cmd_line():
	cmd_line = ''
	for arg in sys.argv:
		cmd_line += arg + '  '
	cmd_line = 'Shell line command: ' + cmd_line
	return cmd_line

# ----------------------------------------------------------------------------------------
# Generic helper function
# ----------------------------------------------------------------------------------------
def gtf_get_timestamp( file_format=False ):
	"""
	Utility function to get a properly formatted timestamp. 

	Args:
		file_format (bool): If true, timestamp will not include ':' characters
			for a more OS-friendly string that can be used in less risky file 
			names [default: False ]
	"""
	if file_format:
		return time.strftime( "%Y-%m-%d_%H-%M-%S", time.localtime() )
	else:
		return time.strftime( "%Y-%m-%d %H:%M:%S", time.localtime() )

# ----------------------------------------------------------------------------------------
# Generic print function
# ----------------------------------------------------------------------------------------
def gtf_print( *args, **kwargs ):
	"""
	Generic print function that includes time stamps and caller id. Everything
	that is printed is also logged to file <SXPRINT_LOG> (can be disabled by
	setting SXPRINT_LOG to "").

	Args:
		*args: Variable number of arguments

		**kwargs: Dictionary containing (separate) variable number of (keyword) 
			arguments
		
		filename (string): If a file name is provided the message is also 
			written to file. If a file of the same name already exists the new
			message is appended to the end of the file. If no file of the given
			name exists it is created.

	Example:
		>>> gtf_print( "This is " + "a %s" % "test" + ".", filename="out.log" )
		2019-02-07 13:36:50 <module> => This is a test.
	"""
	end = kwargs.get('end', '\n')
	print_timestamp = kwargs.get('print_timestamp', True)

	# prepend timestamp
	t = gtf_get_timestamp()
	f = sys._getframe(1).f_code.co_name
	if print_timestamp:
		m = t + " " + f + " => " + "  ".join(map(str, args))
	else:
		m = "  ".join(map(str, args))
	
	# print message to stdout
	print( m, end=end)
	sys.stdout.flush()

	# return printed message
	return m

def gtf_create_relion4_optics_dict():
	"""
	Creates optics dictionary of RELION 4.
	:return: optics dictionary of RELION 4.
	"""
	relion_optics_dict = {}
	relion_optics_dict['_rlnOpticsGroupName']             = [-1, '#     Optics Group Name              := %2d (%s)']
	relion_optics_dict['_rlnOpticsGroup']                 = [-1, '#     Optics Group ID                := %2d (%s)']
	relion_optics_dict['_rlnMtfFileName']                 = [-1, '#     MTF File Name                  := %2d (%s)'] # This is not necessary for SPHIRE=
	relion_optics_dict['_rlnMicrographOriginalPixelSize'] = [-1, '#     Micrograph Original Pixel Size := %2d (%s)']
	relion_optics_dict['_rlnVoltage']                     = [-1, '#     Voltage                        := %2d (%s)']
	relion_optics_dict['_rlnSphericalAberration']         = [-1, '#     Spherical Aberration           := %2d (%s)']
	relion_optics_dict['_rlnAmplitudeContrast']           = [-1, '#     Amplitude Contrast             := %2d (%s)']
	relion_optics_dict['_rlnMicrographPixelSize']         = [-1, '#     Micrograph Pixel Size          := %2d (%s)'] # Only for Micrograph STAR File: MotionCorr,CtfFind

	return relion_optics_dict

# IMPORTANT NOTE (2021/10/19 Toshio Moriya)
# To avid file name conflicts of different CryoEM session,
# RELION mainteins the movie directory origanization including subdirectoies 
# as a relative path to the movie files from RELION project folder!
# This movie directory origanization is used under MotionCor, CtfFind, AutoPick job### directoy!
# RELION seems to be assuming PROCESS_STEP_NAME/job### directory to generate this the movie directory origanization
# since the changing of _rlnMicrographMetadata file did not affect later processings
def gtf_create_relion4_data_dict():
	"""
	Creates data dictionary of RELION 4.
	:return: data dictionary of RELION 4.
	"""
	relion_data_dict = {}
	relion_data_dict['_rlnCtfPowerSpectrum']            = [-1, '#     CTF Power Spectrum Name  := %2d (%s)'] # MotionCorr, JoinStar(MotionCorr)
	relion_data_dict['_rlnMicrographName']              = [-1, '#     Micrograph Name          := %2d (%s)'] # MotionCorr, JoinStar(MotionCorr), CtfFind, JoinStar(CtfFind), AutoPick
	relion_data_dict['_rlnMicrographMetadata']          = [-1, '#     Micrograph Metadata      := %2d (%s)'] # MotionCorr, JoinStar(MotionCorr)
	relion_data_dict['_rlnOpticsGroup']                 = [-1, '#     Optics Group ID          := %2d (%s)'] # Global except Coordinate Star File
	relion_data_dict['_rlnAccumMotionTotal']            = [-1, '#     Accumulated Motion Total := %2d (%s)'] # MotionCorr, JoinStar(MotionCorr)
	relion_data_dict['_rlnAccumMotionEarly']            = [-1, '#     Accumulated Motion Early := %2d (%s)'] # MotionCorr, JoinStar(MotionCorr)
	relion_data_dict['_rlnAccumMotionLate']             = [-1, '#     Accumulated Motion Late  := %2d (%s)'] # MotionCorr, JoinStar(MotionCorr)
	relion_data_dict['_rlnCtfImage']                    = [-1, '#     CTF Image                := %2d (%s)'] # CtfFind, JoinStar(CtfFind)
	relion_data_dict['_rlnDefocusU']                    = [-1, '#     Defocus U                := %2d (%s)'] # CtfFind, JoinStar(CtfFind)
	relion_data_dict['_rlnDefocusV']                    = [-1, '#     Defocus V                := %2d (%s)'] # CtfFind, JoinStar(CtfFind)
	relion_data_dict['_rlnCtfAstigmatism']              = [-1, '#     CTF Astigmatism          := %2d (%s)'] # CtfFind, JoinStar(CtfFind)
	relion_data_dict['_rlnDefocusAngle']                = [-1, '#     Defocus Angle            := %2d (%s)'] # CtfFind, JoinStar(CtfFind)
	relion_data_dict['_rlnCtfFigureOfMerit']            = [-1, '#     CTF Fig. of Merit        := %2d (%s)'] # CtfFind, JoinStar(CtfFind)
	relion_data_dict['_rlnCtfMaxResolution']            = [-1, '#     CTF Max Resolution       := %2d (%s)'] # CtfFind, JoinStar(CtfFind)
	relion_data_dict['_rlnMicrographCoordinates']       = [-1, '#     Micrograph Coordinates   := %2d (%s)'] # AutoPick

	return relion_data_dict

def gtf_create_relion4_category_dict():
	"""
	Creates category dictionary for RELION4.
	:return: category dictionary for RELION4.
	"""
	relion_category_dict = {}
	relion_category_dict['mic']     = ['Micrographs',             True, [], ['_rlnMicrographName', '_rlnOpticsGroup'], [], [], []]
	
	return relion_category_dict

# ========================================================================================
# Run function
# ========================================================================================
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
# 
def run(relion_mic_star_file_rpath, relion_job_dir_rpath, cryolo_output_dir_name = "crYOLO", relion_project_dir_fpath = None):
	gtf_print( '[GTF_DEBUG] relion_mic_star_file_rpath = {}'.format(relion_mic_star_file_rpath) )
	gtf_print( '[GTF_DEBUG] relion_job_dir_rpath = {}'.format(relion_mic_star_file_rpath) )
	gtf_print( '[GTF_DEBUG] cryolo_output_dir_name = {}'.format(cryolo_output_dir_name) )
	gtf_print( '[GTF_DEBUG] relion_project_dir_fpath = {}'.format(relion_project_dir_fpath) )

	if (not os.path.exists(relion_mic_star_file_rpath)):
		gtf_print( '[GTF_ERROR] Input RELION micrograph star file "{}" is not found.'.format(relion_mic_star_file_rpath) )
		return
	
	if (not os.path.exists(relion_job_dir_rpath)):
		gtf_print( '[GTF_ERROR] RELION job directory "{]" does not exist. The script assumes the output directory exists already'.format(relion_job_dir_rpath) )
		return
	
	if relion_project_dir_fpath is not None:
		if not os.path.exists(relion_project_dir_fpath):
			gtf_print( '[GTF_ERROR] Specified RELION project directory "{}" does not exist.'.format(relion_project_dir_fpath) )
			return
	
	# ------------------------------------------------------------------------------------
	# Constants
	# ------------------------------------------------------------------------------------
	str_relion_start_section = 'data_'

	# Initialise dictionary for RELION params file related items
	i_enum = -1
	i_enum += 1; idx_section_col_counts = i_enum
	i_enum += 1; idx_is_section_found   = i_enum
	i_enum += 1; idx_is_loop_found      = i_enum
	
	relion_section = {}
	relion_section['data_optics']           = [-1, False, False] # Global Parameter Section (All except Coordinate Star File)
	relion_section['data_micrographs']      = [-1, False, False] # Micrograph STAR File Section: MotionCorr,CtfFind
	
	i_enum = -1
	i_enum += 1; idx_optics_col   = i_enum
	i_enum += 1; idx_optics_title = i_enum
	
	relion_optics_dict = {}
	relion_optics_dict = gtf_create_relion4_optics_dict()
	
	i_enum = -1
	i_enum += 1; idx_col   = i_enum
	i_enum += 1; idx_title = i_enum
	
	relion_data_dict = {}
	
	i_enum = -1
	i_enum += 1; idx_relion_process           = i_enum
	i_enum += 1; idx_is_category_found        = i_enum
	i_enum += 1; idx_required_optics_key_list = i_enum
	i_enum += 1; idx_required_key_list        = i_enum
	i_enum += 1; idx_denpended_key_list       = i_enum
	i_enum += 1; idx_optional_optics_key_list = i_enum
	i_enum += 1; idx_optional_key_list        = i_enum
	
	relion_category_dict = {}
	
	# ------------------------------------------------------------------------------------
	# STEP 1: Convert RELION parameters to SPHIRE format
	# ------------------------------------------------------------------------------------	
	
	# Initialise loop variables 
	str_section_title = None
	is_success = True
	i_relion_optics_item_col = 0     # Counter for number of RELION optics items/columns
	i_relion_optics_entry = 0        # Counter for number of RELION optics/entries, starting from 0
	i_relion_data_item_col = 0       # Counter for number of RELION data items/columns
	i_relion_data_entry = 0          # Counter for number of RELION data/entries, starting from 0
	
	relion_optics_entry_dict={}   # For optics entry (one entry for each potics group)
	motioncor_dict={}    # For micrograph selecting list (one entry for each micrograph)
	
	# Open input/output files
	assert os.path.exists(relion_mic_star_file_rpath), '# Logical Error: Input RELION STAR file must exits at this point of code.'
	file_relion_star = open(relion_mic_star_file_rpath,'r')

	# Loop through all lines in input RELION STAR file
	for i_line, str_line in enumerate(file_relion_star):
	
		# First, find data section in STAR file 
		if str_section_title is None:
			if str_line.find(str_relion_start_section) != -1:
				str_section_title = str_line.rstrip('\n')
				gtf_print('# ')
				gtf_print('# Section Title: %s' % (str_section_title))
				assert relion_section[str_section_title][idx_is_section_found] == False, '# Logical Error: relion_section[str_section_title][idx_is_section_found] is not initialized to False properly.'
				assert relion_section[str_section_title][idx_is_loop_found] == False, '# Logical Error: relion_section[str_section_title][idx_is_loop_found] is not initialized to False properly.'
				relion_section[str_section_title][idx_is_section_found] = True
				assert relion_section[str_section_title][idx_is_section_found] == True,  '# Logical Error: relion_section[str_section_title][idx_is_section_found] must have been Ture at this point of code.'
				assert relion_section[str_section_title][idx_is_loop_found] == False, '# Logical Error: relion_section[str_section_title][idx_is_loop_found] is not initialized to False properly.'
		# Then, ignore loop_ in STAR file 
		elif relion_section[str_section_title][idx_is_loop_found] == False:
			if str_line.find('loop_') != -1:
				assert relion_section[str_section_title][idx_is_section_found] == True, '# Logical Error: relion_section[str_section_title][idx_is_section_found] must have been set to Ture at this point of code.'
				assert relion_section[str_section_title][idx_is_loop_found] == False, '# Logical Error: relion_section[str_section_title][idx_is_loop_found] is not initialized to False properly.'
				relion_section[str_section_title][idx_is_loop_found] = True
				assert relion_section[str_section_title][idx_is_section_found] == True, '# Logical Error: relion_section[str_section_title][idx_is_section_found] must have been set to True at this point of code.'
				assert relion_section[str_section_title][idx_is_loop_found] == True, '# Logical Error: relion_section[str_section_title][idx_is_section_found] must have been set to True at this point of code.'
				gtf_print('# ')
				gtf_print('# Extracting Column IDs:')
		# Process item list and data entries 
		elif str_section_title == 'data_optics':
			assert relion_section[str_section_title][idx_is_section_found] == True, '# Logical Error: relion_section[str_section_title][idx_is_section_found] must have been set to True at this point of code.'
			assert relion_section[str_section_title][idx_is_loop_found] == True, '# Logical Error: relion_section[str_section_title][idx_is_section_found] must have been set to True at this point of code.'
			tokens_line = str_line.split() # print tokens_line
			n_tokens_line = len(tokens_line)
			
			# First, check item list and find the column number of each item
			if str_line.find('_rln') != -1:
				i_relion_optics_item_col += 1
				# print '# DEBUG: updated Column Counts := %d ' % (i_relion_optics_item_col)
				
				relion_key = str_line.split(' ')[0]
				assert relion_key.find('_rln') != -1, '# Logical Error: The string %s must contain _rln at this point of code.' % (str_line)
				
				if relion_key in list(relion_optics_dict.keys()):
					relion_optics_dict[relion_key][idx_optics_col] = int(i_relion_optics_item_col)
					gtf_print(relion_optics_dict[relion_key][idx_optics_title] % (relion_optics_dict[relion_key][idx_optics_col], relion_key))
			
			# Then, read the data entries
			elif n_tokens_line == i_relion_optics_item_col:
				# Check if all entries of each category were found in RELION STAR file
				# Do this only once
				if i_relion_optics_entry == 0:
					gtf_print('# ')
					gtf_print('# Checking RELION STAR file %s section contents ...' % (str_section_title))
				
				assert relion_optics_dict['_rlnOpticsGroup'][idx_optics_col] != -1, '# Logical Error: _rlnOpticsGroup has to be found at this point of code'
				assert relion_optics_dict['_rlnOpticsGroupName'][idx_optics_col] != -1, '# Logical Error: _rlnOpticsGroupName has to be found at this point of code'
				
				relion_optics_group_id_str = tokens_line[relion_optics_dict['_rlnOpticsGroup'][idx_optics_col] - 1]
				relion_optics_entry_dict[relion_optics_group_id_str] = {}
				
				for optics_key in list(relion_optics_dict.keys()):
					if relion_optics_dict[optics_key][idx_optics_col] < 0:
						gtf_print('#     %s  for Optics Group Parameters is not found' % (optics_key))
					# else:
					# 	gtf_print('#     %s is found at column #%d' % (optics_key, relion_optics_dict[optics_key][idx_optics_col]))
					relion_optics_entry_dict[relion_optics_group_id_str][optics_key] = tokens_line[relion_optics_dict[optics_key][idx_optics_col] - 1]
					
				i_relion_optics_entry += 1
				
			else:
				gtf_print('# ')
				gtf_print('# An empty line is detected after relion optics entries at line %d...' % i_line)
				
				if relion_section[str_section_title][idx_is_loop_found] == False:
					gtf_print('# ERROR!!! loop_ line after %s section is not found!!!' % (str_section_title))
					gtf_print('#          Please check if STAR file is not corrupted.')
					is_success = False
					break
				
				gtf_print('# Reseting the section status by assuming this is the end of relion %s section ...' % str_section_title)
				str_section_title = None
			
		else:
			assert str_section_title is not None, '# Logical Error: str_section_title must have been found at this point of code.'
			assert relion_section[str_section_title][idx_is_section_found] == True, '# Logical Error: relion_section[str_section_title][idx_is_section_found] must have been set to True at this point of code.'
			assert relion_section[str_section_title][idx_is_loop_found] == True, '# Logical Error: relion_section[str_section_title][idx_is_section_found] must have been set to True at this point of code.'
			tokens_line = str_line.split() # print tokens_line
			n_tokens_line = len(tokens_line)
			
			# Create relion_data_dict & relion_category_dict according to the detected relion version
			if len(relion_data_dict) == 0:
				assert len(relion_category_dict) == 0, '# Logical Error: relion_category_dict is not initialized properly.'
				assert len(relion_optics_entry_dict) == i_relion_optics_entry, '# Logical Error: relion_optics_entry_dict and i_relion_optics_entry counter has to be the same.'
				assert len(relion_optics_entry_dict) > 0, '# Logical Error: relion_optics_entry_dict must have at least one entry.'
				relion_data_dict = gtf_create_relion4_data_dict()
				relion_category_dict = gtf_create_relion4_category_dict()
			
			assert len(relion_data_dict) > 0, '# Logical Error: relion_data_dict has not been set properly.'
			assert len(relion_category_dict) > 0, '# Logical Error: relion_data_dict has not been set properly.'
			
			# First, check item list and find the column number of each item
			if str_line.find('_rln') != -1:
				i_relion_data_item_col += 1
				# print '# DEBUG: updated Column Counts := %d ' % (i_relion_data_item_col)
				
				relion_key = str_line.split(' ')[0]
				assert relion_key.find('_rln') != -1, '# Logical Error: The string %s must contain _rln at this point of code.' % (str_line)
				
				if relion_key in list(relion_data_dict.keys()):
					relion_data_dict[relion_key][idx_col] = int(i_relion_data_item_col)
					gtf_print(relion_data_dict[relion_key][idx_title] % (relion_data_dict[relion_key][idx_col], relion_key))
			
			# Then, read the data entries
			elif n_tokens_line == i_relion_data_item_col:
				# Check if all entries of each category were found in RELION STAR file
				# Do this only once
				if i_relion_data_entry == 0:
					gtf_print('# ')
					gtf_print('# Checking RELION STAR file %s section contents ...' % (str_section_title))
					for category_key in list(relion_category_dict.keys()):
						for key in relion_category_dict[category_key][idx_required_optics_key_list]:
							if relion_optics_dict[key][idx_optics_col] < 0:
								gtf_print('#     %s entry for %s is not found in data_optics section' % (key, relion_category_dict[category_key][idx_relion_process]))
								relion_category_dict[category_key][idx_is_category_found] = False
						
						for key in relion_category_dict[category_key][idx_required_key_list]:
							if relion_data_dict[key][idx_col] < 0:
								gtf_print('#     %s entry for %s is not found in %s' % (key, relion_category_dict[category_key][idx_relion_process], str_section_title))
								relion_category_dict[category_key][idx_is_category_found] = False
						
						if relion_category_dict[category_key][idx_is_category_found] == True:
							for key in relion_category_dict[category_key][idx_denpended_key_list]:
								if relion_category_dict[key][idx_is_category_found] == False:
									gtf_print('#     %s required for %s is not found' % (relion_category_dict[key][idx_relion_process], relion_category_dict[category_key][idx_relion_process]))
									relion_category_dict[category_key][idx_is_category_found] = False
					
					if i_relion_optics_entry > 0:
						assert len(relion_optics_entry_dict) > 0, '# Logical Error: relion_optics_entry_dict must have at least one entry.'
						assert '_rlnOpticsGroup' in relion_data_dict, '# Logical Error: There is data_optics section but _rlnOpticsGroup is not found in %s section.' % (str_section_title)
						assert relion_data_dict['_rlnOpticsGroup'][idx_col] > 0, '# Logical Error: There is _rlnOpticsGroup in %s but the column ID is not set.' % (str_section_title)
						
					if relion_category_dict['mic'][idx_is_category_found] == False:
						gtf_print('# ')
						gtf_print('# ERROR!!! Input STAR file must contain all entries for %s as the minimum requirement. Aborting execution ...' % (relion_category_dict['mic'][idx_relion_process]))
						is_success = False
						break;
					
					for category_key in list(relion_category_dict.keys()):
						if relion_category_dict[category_key][idx_is_category_found] == True:
							gtf_print('# ')
							gtf_print('# Parameters associated with %s will be extracted.' % (relion_category_dict[category_key][idx_relion_process]))
						else:
							assert relion_category_dict[category_key][idx_is_category_found] == False, '# Logical Error: This must be true at this point of code.'
							gtf_print('# ')
							gtf_print('# [GTF_WARNING] %s cannot be extracted!!! Some of required paramters are missing (see above).' % (relion_category_dict[category_key][idx_relion_process]))
					gtf_print('# ')
				
				if i_relion_data_entry % 1000 == 0:
					gtf_print('# Processing RELION entries from %7d to %7d ...' % (i_relion_data_entry, i_relion_data_entry + 1000 - 1))
				
				relion_optics_group_id_str = None
				if i_relion_optics_entry > 0:
					relion_optics_group_id_str = tokens_line[relion_data_dict['_rlnOpticsGroup'][idx_col]  - 1]
					# print ('DEBUG: relion_optics_group_id_str := %s' % relion_optics_group_id_str)
				
				##### Store micrograph related parameters #####
				# Micrograph must be found always.
				assert relion_category_dict['mic'][idx_is_category_found], '# Logical Error: Micrograph information must be found any type of RELION STAR file at this point of code.'
				relion_motioncor_file_rpath = tokens_line[relion_data_dict['_rlnMicrographName'][idx_col] - 1]
				motioncor_dir_rpath, motioncor_file_basename = os.path.split(relion_motioncor_file_rpath)
				
				if motioncor_dir_rpath not in motioncor_dict:
					motioncor_dict[motioncor_dir_rpath] = {}
				assert motioncor_dir_rpath in motioncor_dict
				
				if motioncor_file_basename not in motioncor_dict[motioncor_dir_rpath]:
					motioncor_dict[motioncor_dir_rpath][motioncor_file_basename] = motioncor_file_basename
				else:
					assert cmp(motioncor_dict[motioncor_dir_rpath][motioncor_file_basename], motioncor_file_basename) == 0, '# Logical Error: key of motioncor_dict %s in %s and motioncor_file_basename %s must be identical.' % (motioncor_dict[motioncor_dir_rpath][motioncor_file_basename], motioncor_dir_rpath, motioncor_file_basename)
				
				i_relion_data_entry += 1
			
			else:
				gtf_print('# ')
				gtf_print('# An empty line is detected after relion optics entries at line %d...' % i_line)
				
				if relion_section[str_section_title][idx_is_loop_found] == False:
					gtf_print('# ERROR!!! loop_ line after %s section is not found!!!' % (str_section_title))
					gtf_print('#          Please check if STAR file is not corrupted.')
					is_success = False
					break
				
				gtf_print('# Reseting the section status by assuming this is the end of relion %s section ...' % str_section_title)
				str_section_title = None
				
	
	gtf_print('# ')
	gtf_print('# Finished checking all lines in this STAR file at line %d...' % i_line)
	
	# Close input/output files
	file_relion_star.close()
	
	# ------------------------------------------------------------------------------------
	# STEP 2: Prepare output file paths
	# ------------------------------------------------------------------------------------
	
	if is_success:
		# Store the results of counters
		sphire_micrographs_dict_dirname_counts = len(motioncor_dict)
		sphire_mircrograph_entry_total_counts = 0
		for sphire_micrograph_dirname in motioncor_dict:
			sphire_mircrograph_entry_total_counts += len(motioncor_dict[sphire_micrograph_dirname])
		
		gtf_print('# ')
		gtf_print('# Detected RELION column counts                     := {} '.format(i_relion_data_item_col))
		gtf_print('# Detected RELION entry counts                      := {} '.format(i_relion_data_entry))
		gtf_print('# Processed SPHIRE mircrograph directory counts     := {} '.format(sphire_micrographs_dict_dirname_counts))
		gtf_print('# Processed SPHIRE mircrograph entry total counts   := {} '.format(sphire_mircrograph_entry_total_counts))
		
		for motioncor_dir_rpath in sorted(motioncor_dict):
			### print('[GTF_DEBUG] motioncor_dir_rpath : %s' % motioncor_dir_rpath)
			# Remove first two directories (i.e. MotionCor/job###) from the path
			relion_movie_dirname_tuple = pathlib.Path(motioncor_dir_rpath).parts[2:]
			### print('[GTF_DEBUG] relion_movie_dirname_tuple : %s' % relion_movie_dirname_tuple)
			assert len(relion_movie_dirname_tuple) > 0, '# Logical Error: relion_movie_dirname_tuple should have at least one elements.'
			relion_movie_dir_rpath = str(pathlib.Path(*relion_movie_dirname_tuple))
			### print('[GTF_DEBUG] relion_movie_dir_rpath : %s' % relion_movie_dir_rpath)
	
			cryolo_motioncor_dir_rpath  = os.path.join(relion_job_dir_rpath, cryolo_output_dir_name, relion_movie_dir_rpath, "MotionCor")
			### print('[GTF_DEBUG] cryolo_motioncor_dir_rpath : %s' % cryolo_motioncor_dir_rpath)
			relion_motioncor_list_file_rpath = os.path.join(relion_job_dir_rpath, cryolo_output_dir_name, relion_movie_dir_rpath, "MotionCor.txt")
			### print('[GTF_DEBUG] relion_motioncor_list_file_rpath : %s' % relion_motioncor_list_file_rpath)
			# 2021/11/10 To support Relion's continue functions
			### assert not os.path.exists(cryolo_motioncor_dir_rpath), '# Logical Error: Current work directory should not exist at this point of code.'
			if not os.path.exists(cryolo_motioncor_dir_rpath):
				gtf_print('# ')
				gtf_print('# Creating work dir {} ...'.format(cryolo_motioncor_dir_rpath))
				os.makedirs(cryolo_motioncor_dir_rpath)
			
			# 2021/11/10 To support Relion's continue functions
			### relion_motioncor_list_file = open(relion_motioncor_list_file_rpath, 'w')
			relion_motioncor_list_file = open(relion_motioncor_list_file_rpath, 'a')
			for motioncor_file_basename in sorted(motioncor_dict[motioncor_dir_rpath]):
				### print('[GTF_DEBUG] motioncor_file_basename : %s' % motioncor_file_basename)
				relion_motioncor_file_rpath = os.path.join(motioncor_dir_rpath, motioncor_file_basename)
				### print('[GTF_DEBUG] relion_motioncor_file_rpath : %s' % relion_motioncor_file_rpath)
				adjusted_relion_motioncor_file_rpath = relion_motioncor_file_rpath
				if relion_project_dir_fpath is not None:
					adjusted_relion_motioncor_file_rpath = os.path.join(relion_project_dir_fpath, adjusted_relion_motioncor_file_rpath)
				### print('[GTF_DEBUG] adjusted_relion_motioncor_file_rpath : %s' % adjusted_relion_motioncor_file_rpath)
				if not os.path.exists(os.path.join(cryolo_motioncor_dir_rpath, motioncor_file_basename)):
					relion_motioncor_list_file.write('%s\n' % (adjusted_relion_motioncor_file_rpath))
					# Create Hard link of this relion micrograph file in cryolo micrographs directory
					os.link(adjusted_relion_motioncor_file_rpath, os.path.join(cryolo_motioncor_dir_rpath, motioncor_file_basename))
			relion_motioncor_list_file.close()
	
	return motioncor_dict

# ----------------------------------------------------------------------------------------

if __name__ == '__main__':
###	sp_global_def.print_timestamp( "Start" )
	# Parse command argument
	arglist = []
	for arg in sys.argv:
		arglist.append( arg )

	progname = os.path.basename( arglist[0] )
	usage = progname + '  input_micrographs_star_file  output_directory  --cryolo_output_dir_name=ROOT_NAME_STRING  --relion_project_dir=DIR_PATH'
###	usage = progname + '  input_micrographs_star_file  output_directory  --relion_project_dir=DIR_PATH'
	parser = OptionParser(usage, version="0.0.0")

	parser.add_option('--cryolo_output_dir_name',  type='string',         default='crYOLO',      help='Output micrograph dirctroy name: Specify the name of directory where the hard line of motion-corrected micrographs will be stored. It cannot be empty string or only white spaces. (default crYOLO)')
	parser.add_option('--relion_project_dir',      type='string',         default=None,          help='RELION project directory: Path to RELION project directory associated with the RELION Micrographs STAR file. By default, the program assume the current directory is the RELION project directory. (default none)')
	
	(options,args) = parser.parse_args( arglist[1:] )
	
	# ------------------------------------------------------------------------------------
	# Check validity of input arguments and options
	# ------------------------------------------------------------------------------------
	if len(args) != 2:
		gtf_print( "Usage: " + usage )
		gtf_print( "Please run \'" + progname + " -h\' for detailed options" )
		gtf_print( "[GTF_ERROR] Missing paths to input Micrographs STAR file and output directory. Please see usage information above" )
		sys.exit() ### return <<<< SyntaxError: 'return' outside function
	
	gtf_print('# ')
	gtf_print('# %s' % gtf_get_cmd_line())
	gtf_print('# ')
	
	# Rename arguments and options for readability
	args_file_path_relion_star    = args[0]
	args_dir_path_work            = args[1]

	options_dir_path_relion_project  = options.relion_project_dir
	cryolo_output_dir_name      = options.cryolo_output_dir_name.strip()

	run(args_file_path_relion_star, args_dir_path_work, cryolo_output_dir_name, options_dir_path_relion_project)
	
	gtf_print('# ')
	gtf_print('# DONE!')
	
###	sp_global_def.print_timestamp( "Finish" )

# ========================================================================================
# END OF SCRIPT
# ========================================================================================
