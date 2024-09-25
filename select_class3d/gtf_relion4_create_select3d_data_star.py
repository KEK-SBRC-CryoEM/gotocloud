#!/usr/bin/env python

# ***************************************************************************
#
# Copyright (c) 2022-2024 Structural Biology Research Center, 
#                         Institute of Materials Structure Science, 
#                         High Energy Accelerator Research Organization (KEK)
#
#
# Authors:   Toshio Moriya (toshio.moriya@kek.jp)
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
# 02111-1307  USA
#
# ***************************************************************************
#
#
# [Develop Notes]
# ========================================================================================
from __future__ import print_function

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
###	end = kwargs.get('end', '\n')
	karg_end = kwargs.get('end', '\n')
	print_timestamp = kwargs.get('print_timestamp', True)

	# prepend timestamp
	t = gtf_get_timestamp()
	f = sys._getframe(1).f_code.co_name
	if print_timestamp:
		m = t + " " + f + " => " + "  ".join(map(str, args))
	else:
		m = "  ".join(map(str, args))
	
	# print message to stdout
###	print( m, end=end )
	print( m, end=karg_end )
	# print m, end=karg_end
	sys.stdout.flush()

	# return printed message
	return m

def gtf_create_relion4_data_particles_dict():
	"""
	Creates data_particles dictionary of RELION 4.
	:return: data_particles dictionary of RELION 4.
	"""
	relion_data_particles_dict = {}
	relion_data_particles_dict['_rlnMicrographName']              = [-1, '#     Micrograph Name        := %2d (%s)'] # Micrograph, CTF, Window, Class2d, Class3d, Refine3d
	relion_data_particles_dict['_rlnOpticsGroup']                 = [-1, '#     Optics Group ID        := %2d (%s)'] # Global except Coordinate Star File
	relion_data_particles_dict['_rlnDefocusU']                    = [-1, '#     Defocus U              := %2d (%s)'] # CTF, Window, Class2d, Class3d, Refine3d
	relion_data_particles_dict['_rlnDefocusV']                    = [-1, '#     Defocus V              := %2d (%s)'] # CTF, Window, Class2d, Class3d, Refine3d
	relion_data_particles_dict['_rlnDefocusAngle']                = [-1, '#     Defocus Angle          := %2d (%s)'] # CTF, Window, Class2d, Class3d, Refine3d
	relion_data_particles_dict['_rlnAmplitudeContrast']           = [-1, '#     Amp. Contrast          := %2d (%s)'] # CTF, Window, Class2d, Class3d, Refine3d
	relion_data_particles_dict['_rlnPhaseShift']                  = [-1, '#     Phase shift            := %2d (%s)'] # CTF, Window, Class2d, Class3d    # For Volta Phase Support
	relion_data_particles_dict['_rlnVoltage']                     = [-1, '#     Acc. Vol.              := %2d (%s)'] # CTF, Window, Class2d, Class3d, Refine3d
	relion_data_particles_dict['_rlnSphericalAberration']         = [-1, '#     Cs                     := %2d (%s)'] # CTF, Window, Class2d, Class3d, Refine3d
	relion_data_particles_dict['_rlnCtfFigureOfMerit']            = [-1, '#     CTF Fig. of Merit      := %2d (%s)'] # CTF, Window, Class2d, Class3d, Refine3d
	relion_data_particles_dict['_rlnCtfMaxResolution']            = [-1, '#     CTF Max Resolution     := %2d (%s)'] # CTF, 
	relion_data_particles_dict['_rlnCtfImage']                    = [-1, '#     CTF Image              := %2d (%s)'] # CTF
	relion_data_particles_dict['_rlnImageName']                   = [-1, '#     Particle Source        := %2d (%s)'] # Window, Class2d, Class3d, Refine3d
	relion_data_particles_dict['_rlnCoordinateX']                 = [-1, '#     X Coordinate           := %2d (%s)'] # Window, Class2d, Class3d, Refine3d
	relion_data_particles_dict['_rlnCoordinateY']                 = [-1, '#     Y Coordinate           := %2d (%s)'] # Window, Class2d, Class3d, Refine3d
	relion_data_particles_dict['_rlnAutopickFigureOfMerit']       = [-1, '#     Figure of Merit        := %2d (%s)'] # Only Relion 3.1.0! Class2d, Class3d, Refine3d
	relion_data_particles_dict['_rlnOriginXAngst']                = [-1, '#     X Translation (v3.1.0) := %2d (%s)'] # Only Relion 3.1.0! Class2d, Class3d, Refine3d
	relion_data_particles_dict['_rlnOriginYAngst']                = [-1, '#     Y Translation (v3.1.0) := %2d (%s)'] # Only Relion 3.1.0! Class2d, Class3d, Refine3d
	relion_data_particles_dict['_rlnAngleRot']                    = [-1, '#     Rotation               := %2d (%s)'] # Class2d, Class3d, Refine3d
	relion_data_particles_dict['_rlnAngleTilt']                   = [-1, '#     Tilt                   := %2d (%s)'] # Class2d, Class3d, Refine3d
	relion_data_particles_dict['_rlnAnglePsi']                    = [-1, '#     Psi                    := %2d (%s)'] # Class2d, Class3d, Refine3d
	relion_data_particles_dict['_rlnMaxValueProbDistribution']    = [-1, '#     Max Probability        := %2d (%s)'] # Class2d, Class3d, Refine3d
	relion_data_particles_dict['_rlnNormCorrection']              = [-1, '#     Norm Correction        := %2d (%s)'] # Class2d, Class3d, Refine3d
	relion_data_particles_dict['_rlnClassNumber']                 = [-1, '#     Num. of 2D/3D Classes  := %2d (%s)'] # Class2d, Class3d
	relion_data_particles_dict['_rlnRandomSubset']                = [-1, '#     Random Subset          := %2d (%s)'] # Refine3d
###	relion_data_particles_dict['_rlnHelicalTubeID']               = [-1, '#     Helical Tube ID        := %2d (%s)'] # Helical    # For Helical Reconstruction Support
###	relion_data_particles_dict['_rlnAngleTiltPrior']              = [-1, '#     Ang. Tilt Prior        := %2d (%s)'] # Helical    # For Helical Reconstruction Support
###	relion_data_particles_dict['_rlnAnglePsiPrior']               = [-1, '#     Ang. Psi Prior         := %2d (%s)'] # Helical    # For Helical Reconstruction Support
###	relion_data_particles_dict['_rlnHelicalTrackLength']          = [-1, '#     Helical Track Len.     := %2d (%s)'] # Helical    # For Helical Reconstruction Support
###	relion_data_particles_dict['_rlnAnglePsiFlipRatio']           = [-1, '#     Ang. Psi. Flip Ratio   := %2d (%s)'] # Helical    # For Helical Reconstruction Support

	return relion_data_particles_dict

### def gtf_create_relion4_category_dict():
### 	"""
### 	Creates category dictionary for RELION4.
### 	:return: category dictionary for RELION4.
### 	"""
### 	relion_category_dict = {}
### 	relion_category_dict['mic']     = ['Micrographs',             True, [], ['_rlnMicrographName', '_rlnOpticsGroup'], [], [], []]
### 	
### 	return relion_category_dict

def gtf_create_relion4_category_dict():
	"""
	Creates category dictionary for RELION4.
	:return: category dictionary for RELION4.
	"""
	relion_category_dict = {}
	relion_category_dict['class']     = ['Classification',            True, [], ['_rlnImageName','_rlnClassNumber'], [], [], []]
	
	return relion_category_dict

# ========================================================================================
# Run function
# ========================================================================================
# IMPORTANT NOTE (2022/08/12 Toshio Moriya)
# Following RELION convension
# Inputs of this script
# - Class3D/job*/run_it*_data.star
# 
# Outputs of this script for RELION
# - ????.star
# ### - summary.star
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
# Exteranl/job###/ Exteranl/job###/???.star 
# ++++++++++++++++++++++++++++++
# 
def run(relion_particles_data_star_file_rpath, relion_job_dir_rpath, selected_class_id, selected_relion_particles_data_star_file_name, relion_project_dir_fpath = None):
	gtf_print( '[GTF_DEBUG] relion_particles_data_star_file_rpath = {}'.format(relion_particles_data_star_file_rpath) )
	gtf_print( '[GTF_DEBUG] relion_job_dir_rpath = {}'.format(relion_job_dir_rpath) )
	gtf_print( '[GTF_DEBUG] selected_class_id = {}'.format(selected_class_id) )
	gtf_print( '[GTF_DEBUG] selected_relion_particles_data_star_file_name = {}'.format(selected_relion_particles_data_star_file_name) )
	gtf_print( '[GTF_DEBUG] relion_project_dir_fpath = {}'.format(relion_project_dir_fpath) )

	if (not os.path.exists(relion_particles_data_star_file_rpath)):
		gtf_print( '[GTF_ERROR] Input RELION particles data star file "{}" is not found.'.format(relion_particles_data_star_file_rpath) )
		return
	
	if (not os.path.exists(relion_job_dir_rpath)):
		gtf_print( '[GTF_ERROR] RELION job directory "{]" does not exist. The script assumes the output directory exists already.'.format(relion_job_dir_rpath) )
		return
	
	if selected_class_id < 1:
		gtf_print( '[GTF_ERROR] Specified Selected Class ID "{}" is not valid. The value must be greater than 0.'.format(selected_class_id) )
		return
	
	if relion_project_dir_fpath is not None:
		if not os.path.exists(relion_project_dir_fpath):
			gtf_print( '[GTF_ERROR] Specified RELION project directory "{}" does not exist.'.format(relion_project_dir_fpath) )
			return
	
	
	# ------------------------------------------------------------------------------------
	# Constants
	# ------------------------------------------------------------------------------------
	str_relion_start_section = 'data_particles'

	# Initialise dictionary for RELION params file related items
	i_enum = -1
	i_enum += 1; idx_section_col_counts = i_enum
	i_enum += 1; idx_is_section_found   = i_enum
	i_enum += 1; idx_is_loop_found      = i_enum
	
	relion_section = {}
	relion_section['data_particles']    = [-1, False, False] # Model Classes Section
	
### 	i_enum = -1
### 	i_enum += 1; idx_optics_col   = i_enum
### 	i_enum += 1; idx_optics_title = i_enum
	
### 	relion_optics_dict = {}
### 	relion_optics_dict = gtf_create_relion4_optics_dict()
	
	i_enum = -1
	i_enum += 1; idx_data_col   = i_enum
	i_enum += 1; idx_data_title = i_enum
	
	relion_data_particles_dict = {}
	
	i_enum = -1
	i_enum += 1; idx_relion_process           = i_enum
	i_enum += 1; idx_is_category_found        = i_enum
	i_enum += 1; idx_required_optics_key_list = i_enum
	i_enum += 1; idx_required_key_list        = i_enum
	i_enum += 1; idx_denpended_key_list       = i_enum
	i_enum += 1; idx_optional_optics_key_list = i_enum
	i_enum += 1; idx_optional_key_list        = i_enum
	
	relion_category_dict = {}

	# Output files & directories related
	# selected_relion_particles_data_star_file_name    = 'selected_data.star'
	# # selected_relion_particles_data_star_file_name   = '{}selected_data.star'.format(outputs_root)

	# ------------------------------------------------------------------------------------
	# STEP 1: Read RELION parameters from STAR file
	# ------------------------------------------------------------------------------------	
	
	# Initialise loop variables 
	str_section_title = None
	is_success = True
###	i_relion_optics_item_col = 0     # Counter for number of RELION optics items/columns
###	i_relion_optics_entry = 0        # Counter for number of RELION optics/entries, starting from 0
	i_relion_data_particles_item_col = 0       # Counter for number of RELION data items/columns
	i_relion_data_particles_entry = 0          # Counter for number of RELION data/entries, starting from 0
	i_relion_data_particles_entry_selected = 0 # Counter for number of selected RELION data/entries, starting from 0
	
###	relion_optics_entry_dict={}   # For optics entry (one entry for each potics group)
###	motioncor_dict={}    # For micrograph selecting list (one entry for each micrograph)
	particles_data_entry_dict={}    # For class3d model classes list (one entry for each class3d class model)
	
	# Open input/output files
	assert os.path.exists(relion_particles_data_star_file_rpath), '# Logical Error: Input RELION STAR file must exits at this point of code.'
	file_relion_star = open(relion_particles_data_star_file_rpath,'r')

	file_path_selected_relion_data_star = os.path.join(relion_job_dir_rpath, selected_relion_particles_data_star_file_name)
	# assert os.path.exists(file_path_selected_relion_data_star), '# Logical Error: Output RELION DATA STAR file must exits at this point of code.'
	file_selected_relion_data_star = open(file_path_selected_relion_data_star,'w+')
	
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
			
			file_selected_relion_data_star.write(str_line)
			
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
### 		# Process item list and data entries 
### 		elif str_section_title == 'data_optics':
### 			assert relion_section[str_section_title][idx_is_section_found] == True, '# Logical Error: relion_section[str_section_title][idx_is_section_found] must have been set to True at this point of code.'
### 			assert relion_section[str_section_title][idx_is_loop_found] == True, '# Logical Error: relion_section[str_section_title][idx_is_section_found] must have been set to True at this point of code.'
### 			tokens_line = str_line.split() # print tokens_line
### 			n_tokens_line = len(tokens_line)
### 			
### 			# First, check item list and find the column number of each item
### 			if str_line.find('_rln') != -1:
### 				i_relion_optics_item_col += 1
### 				# print '# DEBUG: updated Column Counts := %d ' % (i_relion_optics_item_col)
### 				
### 				relion_key = str_line.split(' ')[0]
### 				assert relion_key.find('_rln') != -1, '# Logical Error: The string %s must contain _rln at this point of code.' % (str_line)
### 				
### ###				if relion_key in list(relion_optics_dict.keys()):
### ###					relion_optics_dict[relion_key][idx_optics_col] = int(i_relion_optics_item_col)
### ###					gtf_print(relion_optics_dict[relion_key][idx_optics_title] % (relion_optics_dict[relion_key][idx_optics_col], relion_key))
### 			
### 			# Then, read the data entries
### 			elif n_tokens_line == i_relion_optics_item_col:
### 				# Check if all entries of each category were found in RELION STAR file
### 				# Do this only once
### 				if i_relion_optics_entry == 0:
### 					gtf_print('# ')
### 					gtf_print('# Checking RELION STAR file %s section contents ...' % (str_section_title))
### 				
### ###				assert relion_optics_dict['_rlnOpticsGroup'][idx_optics_col] != -1, '# Logical Error: _rlnOpticsGroup has to be found at this point of code'
### ###				assert relion_optics_dict['_rlnOpticsGroupName'][idx_optics_col] != -1, '# Logical Error: _rlnOpticsGroupName has to be found at this point of code'
### ###				
### ###				relion_optics_group_id_str = tokens_line[relion_optics_dict['_rlnOpticsGroup'][idx_optics_col] - 1]
### ###				relion_optics_entry_dict[relion_optics_group_id_str] = {}
### 				
### ###				for optics_key in list(relion_optics_dict.keys()):
### ###					if relion_optics_dict[optics_key][idx_optics_col] < 0:
### ###						gtf_print('#     %s  for Optics Group Parameters is not found' % (optics_key))
### ###					# else:
### ###					# 	gtf_print('#     %s is found at column #%d' % (optics_key, relion_optics_dict[optics_key][idx_optics_col]))
### ###					relion_optics_entry_dict[relion_optics_group_id_str][optics_key] = tokens_line[relion_optics_dict[optics_key][idx_optics_col] - 1]
### 					
### 				i_relion_optics_entry += 1
### 				
### 			else:
### 				gtf_print('# ')
### 				gtf_print('# An empty line is detected after relion optics entries at line %d...' % i_line)
### 				
### 				if relion_section[str_section_title][idx_is_loop_found] == False:
### 					gtf_print('# ERROR!!! loop_ line after %s section is not found!!!' % (str_section_title))
### 					gtf_print('#          Please check if STAR file is not corrupted.')
### 					is_success = False
### 					break
### 				
### 				gtf_print('# Reseting the section status by assuming this is the end of relion %s section ...' % str_section_title)
### 				str_section_title = None
### 			
			file_selected_relion_data_star.write(str_line)
		else:
			assert str_section_title is not None, '# Logical Error: str_section_title must have been found at this point of code.'
			assert relion_section[str_section_title][idx_is_section_found] == True, '# Logical Error: relion_section[str_section_title][idx_is_section_found] must have been set to True at this point of code.'
			assert relion_section[str_section_title][idx_is_loop_found] == True, '# Logical Error: relion_section[str_section_title][idx_is_section_found] must have been set to True at this point of code.'
			tokens_line = str_line.split() # print tokens_line
			n_tokens_line = len(tokens_line)
			
			# Create relion_data_particles_dict & relion_category_dict according to the detected relion version
			if len(relion_data_particles_dict) == 0:
				assert len(relion_category_dict) == 0, '# Logical Error: relion_category_dict is not initialized properly.'
###				assert len(relion_optics_entry_dict) == i_relion_optics_entry, '# Logical Error: relion_optics_entry_dict and i_relion_optics_entry counter has to be the same.'
###				assert len(relion_optics_entry_dict) > 0, '# Logical Error: relion_optics_entry_dict must have at least one entry.'
				relion_data_particles_dict = gtf_create_relion4_data_particles_dict()
				relion_category_dict = gtf_create_relion4_category_dict()
			
			assert len(relion_data_particles_dict) > 0, '# Logical Error: relion_data_particles_dict has not been set properly.'
			assert len(relion_category_dict) > 0, '# Logical Error: relion_data_particles_dict has not been set properly.'
			
			# First, check item list and find the column number of each item
			if str_line.find('_rln') != -1:
				i_relion_data_particles_item_col += 1
				# print '# DEBUG: updated Column Counts := %d ' % (i_relion_data_particles_item_col)
				
				relion_key = str_line.split(' ')[0]
				assert relion_key.find('_rln') != -1, '# Logical Error: The string %s must contain _rln at this point of code.' % (str_line)
				
				if relion_key in list(relion_data_particles_dict.keys()):
					relion_data_particles_dict[relion_key][idx_data_col] = int(i_relion_data_particles_item_col)
					gtf_print(relion_data_particles_dict[relion_key][idx_data_title] % (relion_data_particles_dict[relion_key][idx_data_col], relion_key))
				
				file_selected_relion_data_star.write(str_line)
			# Then, read the data entries
			elif n_tokens_line == i_relion_data_particles_item_col:
				# Check if all entries of each category were found in RELION STAR file
				# Do this only once
				if i_relion_data_particles_entry == 0:
					gtf_print('# ')
					gtf_print('# Checking RELION STAR file %s section contents ...' % (str_section_title))
					for category_key in list(relion_category_dict.keys()):
						for key in relion_category_dict[category_key][idx_required_optics_key_list]:
							if relion_optics_dict[key][idx_optics_col] < 0:
								gtf_print('#     %s entry for %s is not found in data_optics section' % (key, relion_category_dict[category_key][idx_relion_process]))
								relion_category_dict[category_key][idx_is_category_found] = False
						
						for key in relion_category_dict[category_key][idx_required_key_list]:
							if relion_data_particles_dict[key][idx_data_col] < 0:
								gtf_print('#     %s entry for %s is not found in %s' % (key, relion_category_dict[category_key][idx_relion_process], str_section_title))
								relion_category_dict[category_key][idx_is_category_found] = False
						
						if relion_category_dict[category_key][idx_is_category_found] == True:
							for key in relion_category_dict[category_key][idx_denpended_key_list]:
								if relion_category_dict[key][idx_is_category_found] == False:
									gtf_print('#     %s required for %s is not found' % (relion_category_dict[key][idx_relion_process], relion_category_dict[category_key][idx_relion_process]))
									relion_category_dict[category_key][idx_is_category_found] = False
					
###					if i_relion_optics_entry > 0:
###						assert len(relion_optics_entry_dict) > 0, '# Logical Error: relion_optics_entry_dict must have at least one entry.'
###						assert '_rlnOpticsGroup' in relion_data_particles_dict, '# Logical Error: There is data_optics section but _rlnOpticsGroup is not found in %s section.' % (str_section_title)
###						assert relion_data_particles_dict['_rlnOpticsGroup'][idx_data_col] > 0, '# Logical Error: There is _rlnOpticsGroup in %s but the column ID is not set.' % (str_section_title)
						
###					if relion_category_dict['mic'][idx_is_category_found] == False:
					if relion_category_dict['class'][idx_is_category_found] == False:
						gtf_print('# ')
						gtf_print('# ERROR!!! Input STAR file must contain all entries for %s as the minimum requirement. Aborting execution ...' % (relion_category_dict['class3d'][idx_relion_process]))
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
				
				if i_relion_data_particles_entry % 1000 == 0:
					gtf_print('# Processing RELION entries from %7d to %7d ...' % (i_relion_data_particles_entry, i_relion_data_particles_entry + 1000 - 1))
				
###				relion_optics_group_id_str = None
###				if i_relion_optics_entry > 0:
###					relion_optics_group_id_str = tokens_line[relion_data_particles_dict['_rlnOpticsGroup'][idx_data_col]  - 1]
###					# print ('DEBUG: relion_optics_group_id_str := %s' % relion_optics_group_id_str)
				
				##### Store particles data related parameters #####
				# Partilce's image name must be found always.
				assert relion_category_dict['class'][idx_is_category_found], '# Logical Error: Class3D information must be found at this point of code.'
				relion_particle_name = tokens_line[relion_data_particles_dict['_rlnImageName'][idx_data_col] - 1]
				
				if relion_particle_name not in particles_data_entry_dict:
					particles_data_entry_dict[relion_particle_name] = {}
				assert relion_particle_name in particles_data_entry_dict
				
				for relion_data_particles_key in list(relion_data_particles_dict.keys()):
					# if relion_data_particles_dict[relion_data_particles_key][idx_data_col] < 0:
					# 	gtf_print('#     %s  for Particles Data Parameters is not found' % (relion_data_particles_key))
					# else:
					# 	gtf_print('#     %s is found at column #%d' % (relion_data_particles_key, relion_data_particles_dict[relion_data_particles_key][idx_data_col]))
					particles_data_entry_dict[relion_particle_name][relion_data_particles_key] = tokens_line[relion_data_particles_dict[relion_data_particles_key][idx_data_col] - 1]
				
				# print ('DEBUG: particles_data_entry_dict[relion_particle_name][_rlnClassNumber]    : ', particles_data_entry_dict[relion_particle_name]['_rlnClassNumber'])
				class_number = int(particles_data_entry_dict[relion_particle_name]['_rlnClassNumber'])
				if class_number == selected_class_id:
					# print ('DEBUG:  ', particles_data_entry_dict[relion_particle_name]['_rlnImageName'], ', ', particles_data_entry_dict[relion_particle_name]['_rlnClassNumber'])
					# print ('DEBUG: str_line    : ', str_line)
					# print ('DEBUG: tokens_line : ', tokens_line)
					file_selected_relion_data_star.write(str_line)
					i_relion_data_particles_entry_selected += 1
				
				i_relion_data_particles_entry += 1
			
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
				
				file_selected_relion_data_star.write(str_line)
	
	gtf_print('# ')
	gtf_print('# Finished checking all lines in this STAR file at line %d...' % i_line)
	
	# Close input/output files
	file_relion_star.close()
	file_selected_relion_data_star.close()
	
	# ------------------------------------------------------------------------------------
	# STEP 2: Prepare output file paths
	# ------------------------------------------------------------------------------------
	
	if is_success:
		# Store the results of counters
		
		gtf_print('# ')
		gtf_print('# Detected RELION column counts                     := {} '.format(i_relion_data_particles_item_col))
		gtf_print('# Detected RELION entry counts                      := {} '.format(i_relion_data_particles_entry))
		gtf_print('# Selected RELION entry counts                      := {} '.format(i_relion_data_particles_entry_selected))
		gtf_print('# Discarded RELION entry counts                     := {} '.format(i_relion_data_particles_entry - i_relion_data_particles_entry_selected))
		
	return particles_data_entry_dict

# ----------------------------------------------------------------------------------------

if __name__ == '__main__':
###	sp_global_def.print_timestamp( "Start" )
	# Parse command argument
	arglist = []
	for arg in sys.argv:
		arglist.append( arg )

	progname = os.path.basename( arglist[0] )
	usage = progname + '  input_class3d_model_star_file  output_directory  selected_class_id  output_class3d_model_star_file_name --relion_project_dir=DIR_PATH'
	parser = OptionParser(usage, version="0.0.0")

	parser.add_option('--relion_project_dir',      type='string',         default=None,          help='RELION project directory: Path to RELION project directory associated with the RELION Micrographs STAR file. By default, the program assume the current directory is the RELION project directory. (default none)')
	
	(options,args) = parser.parse_args( arglist[1:] )
	
	# ------------------------------------------------------------------------------------
	# Check validity of input arguments and options
	# ------------------------------------------------------------------------------------
	if len(args) != 4:
		gtf_print( "Usage: " + usage )
		gtf_print( "Please run \'" + progname + " -h\' for detailed options" )
		gtf_print( "[GTF_ERROR] Missing paths to input RELION DATA STAR file and output directory. Please see usage information above" )
		sys.exit() ### return <<<< SyntaxError: 'return' outside function
	
	gtf_print('# ')
	gtf_print('# %s' % gtf_get_cmd_line())
	gtf_print('# ')
	
	# Rename arguments and options for readability
	args_file_path_relion_star    = args[0]
	args_dir_path_work            = args[1]
	args_selected_class_id        = int(args[2])
	args_file_name_selectd_star   = args[3]

	options_dir_path_relion_project  = options.relion_project_dir

	run(args_file_path_relion_star, args_dir_path_work, args_selected_class_id, args_file_name_selectd_star, options_dir_path_relion_project)
	
	gtf_print('# ')
	gtf_print('# DONE!')
	
###	sp_global_def.print_timestamp( "Finish" )

# ========================================================================================
# END OF SCRIPT
# ========================================================================================
