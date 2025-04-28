#!/usr/bin/env python
"""
bfactor_plot
---------

Pipeline setup script for automated processing with RELION 4.

Authors: Sjors H.W. Scheres, Takanori Nakane & Colin Palmer

Call this from the intended location of the RELION project directory, and provide
the name of a file containing options if needed. See the relion_it_options.py
file for an example.

Usage example: 
    python3 ./bfactor_plot_kek.py -o path_output -p path_parameter.yaml -i3d Refine3D/job049/ -ipp PostProcess/job050/ --minimum_nr_particles 225 --maximum_nr_particles 7200

Modified by: (2025.March) Jair Pereira and Toshio Moriya
- Added support for **YAML files** instead of raw `.py` for parameter input.
- Replaced `sys.argv` with **argparse** for better argument handling.
- Added functionality for setting the **output_node.star** file.
- Improved handling of **matplotlib** and **numpy** imports.
- Replaced **np.int** (deprecated) with **int** for compatibility.
- Fixed the issue with outputting `\u00C5` for **Å** (angstrom symbol).
- Resolved **matplotlib UserWarning** regarding setting tick labels before setting ticks on `ax2` and `ax3`.
- Improved default parameter loading from **Refine3D** and **PostProcess** `job.star` files, with parameter priority order: `terminal > yaml > job.star`.
"""

from __future__ import print_function

import collections
import os
import sys
import time
import glob
from math import log, sqrt

import yaml
import argparse
from pathlib import Path
try:
    import numpy as np
    import matplotlib as mpl
    mpl.use('pdf')
    import matplotlib.pyplot as plt
    from matplotlib.ticker import FixedLocator, FixedFormatter
    IMPORTS_OK = True
except ImportError as e:
    print(f" BFACTOR | WARNING: {e}. It will NOT produce the b-factor plot as pdf!!!")
    IMPORTS_OK = False

# Constants
PIPELINE_STAR = 'default_pipeline.star'
RUNNING_FILE = 'RUNNING' # prefix is appended in main()
SETUP_CHECK_FILE = 'SUBMITTED_JOBS' # prefix is appended in main()

# The parameter names on the original bfactor plot are different from the Refine3D job.star
#   this dictionary is used to translate them
#   this is a layer of compatibility, refactoring should ensure the same name on the related jobs
PARAMS_TRANS = {
    "queue_name":                "queuename",
    "queue_submit_command":      "qsub",
    "queue_submission_template": "qsubscript",
    "queue_minimum_dedicated":   "min_dedicated",
    "refine_preread_images":     "do_preread_images",
    "refine_scratch_disk":       "scratch_dir",
    "refine_nr_pool":            "nr_pool",
    "refine_do_gpu":             "use_gpu",
    "refine_gpu":                "gpu_ids",
    "refine_mpi":                "nr_mpi",
    "refine_threads":            "nr_threads",
    "refine_skip_padding":       "do_pad1",
    "refine_submit_to_queue":    "do_queue",
    "refine_ini_lowpass":        "low_pass",}


class RelionItOptions:
    # job prefix
    prefix = 'BFACTOR_PLOT_'

    # If program crahses saying "'utf-8' codec can't decode byte 0xXX in position YY",
    # most likely run.job file in the job directory contains garbage bytes.

    def __init__(self, from_terminal=None, from_yaml=None):
        if from_terminal is not None:
            self.load_parameters_from_terminal(from_terminal)
        if from_yaml is not None:
            self.load_parameters_from_dictionary(from_yaml)

        # handling path simple appending (where the user adds "/" or not at the end)
        self.input_refine3d_job    = os.path.join(self.input_refine3d_job,    "")
        self.input_postprocess_job = os.path.join(self.input_postprocess_job, "")

        # opts.output  = args.output
        self.outfile = self.prefix+"rosenthal-henderson-plot.pdf"
        self.outtext = self.prefix+"estimated.txt"

    def load_parameters_from_terminal(self, args):
        for arg, value in vars(args).items():
            if value is not None:
                setattr(self, arg, value if value is not None else getattr(self, arg))

    def load_parameters_from_dictionary(self, dict_params):
        """
        Receives a python dictionary and set the keys as attributes name
            and the values as the attribute value

        Expects a flat dictionary (does not accept nested dictionary)
        """
        if dict_params is not None:
            for key, value in dict_params.items():
                if not hasattr(self, key) or getattr(self, key) is None: #dont overwrite if attribute already exist
                    setattr(self, key, value)

def gtf_get_timestamp(file_format=False):
	"""
	Utility function to get a properly formatted timestamp. 

	Args:
		file_format (bool): If true, timestamp will not include ':' characters
			for a more OS-friendly string that can be used in less risky file 
			names [default: False ]
	"""
	if file_format:
		return time.strftime("%Y-%m-%d_%H-%M-%S", time.localtime())
	else:
		return time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())

def make_output_directory(output_path):
    """
        Creates the output directory
            
        If running from relion, 
            we keep the output directory as is since relion enforces unique directory

        If running from the terminal,
            we create a timestamped subdirectory
            
    """
    running_from_relion = os.path.exists(os.path.join(output_path, "job.star"))

    if not running_from_relion:
        output_path = os.path.join(output_path, gtf_get_timestamp(True))
        Path(output_path).mkdir(parents=True, exist_ok=True)

    # return path
    return output_path

def load_yaml_parameters(filepath):
    """
    Receives a string filepath for a .yaml file and loads it as a dictionary
    """
    if filepath is not None and filepath.strip()!="":
        parameters = yaml.safe_load(filepath)
        with open(filepath, 'r') as yaml_file:
            yaml_dict = yaml.safe_load(yaml_file)
        return yaml_dict
    return None

def read_and_merge_job_parameters(filename_list, d_name_trans):
    '''Merges parameters from a list of RELION job.star files based on a translation mapping d_name_trans,
       gets only the parameters in d_name_trans
       gives priority based on the file order in filename_list'''
    d_result = {}
    file_list = [parse_jobstar_parameters(filename) for filename in filename_list]

    # iterate over each key in the translation dictionary
    for key, translated_name in d_name_trans.items():
        value_found = None
        # check each file in the given priority order
        for options in file_list:
            if translated_name in options:
                value_found = options[translated_name]
                break
        # add key to the dict only if we find a value
        if value_found is not None:
            d_result[key] = value_found

    return d_result

def parse_jobstar_parameters(filename):
    """
    Parses the 'data_joboptions_values' section of a RELION job.star file 
    and extracts key-value pairs into a dictionary, 
    where _rlnJobOptionVariable is the key, and 
    _rlnJobOptionValue is the value

    The function:
    - Locates the 'data_joboptions_values' section.
    - Identifies the 'loop_' keyword to start reading data.
    - Skips header lines (starting with '_').
    - Extracts key-value pairs from the section.

    Parameters:
    filename (str): Path to the RELION job.star file.

    Returns:
    dict: A dictionary where keys are _rlnJobOptionVariables
            and values are their corresponding _rlnJobOptionValue

    Note: This function is used and tested only for
            parsing Refine3D/jobNNN/job.star and PostProcess/jobNNN/job.star
    """
    options = {}
    in_section = False
    in_loop = False

    with open(filename, "r") as f:
        for line in f:
            stripped = line.strip()

            # Skip comments
            if stripped.startswith("#"):
                continue
            # Start section if we find data_joboptions_values
            if stripped.startswith("data_joboptions_values"):
                in_section = True
                continue
            # Once in the section, look for the loop keyword
            if in_section and stripped.startswith("loop_"):
                in_loop = True
                continue
            # Skip header lines starting with underscore
            if in_loop and stripped.startswith("_"):
                continue
            # Stop reading if we hit an empty line or a new section marker
            if in_loop and (stripped == "" or stripped.startswith("data_")):
                break
            # If in loop, split the line into key and value
            if in_loop:
                # Split on whitespace – RELION STAR files often have columns separated by variable spaces.
                parts = stripped.split()
                if len(parts) >= 2:
                    key = parts[0]
                    # Join remaining parts in case value has spaces
                    value = " ".join(parts[1:])
                    value = {"yes": True, "no": False}.get(value.lower(), value) #maps yes->true, no->false, otherwise keep values as is
                    options[key] = value
    return options

def make_rln_output_node_file(outpath, outfiles):
    outfilepath = os.path.join(outpath, "RELION_OUTPUT_NODES.star")
    with open(outfilepath, mode="w") as file:
        file.write("\n# version 30001\n")
        file.write("data_output_nodes\n\n")
        file.write("loop_\n")
        file.write("_rlnPipeLineNodeName #1 \n")
        file.write("_rlnPipeLineNodeTypeLabel #2 \n")
        for of in outfiles:
            file.write("{} LogFile.pdf.relion.postprocess \n".format(os.path.join(outpath, of)))
        file.write("\n")

def validate_args(args):
    errors = []

    # if the essential parameters were not set by terminal (or in relion)
    if(args.maximum_nr_particles is None or
        args.minimum_nr_particles is None or
        args.input_postprocess_job is None or
        args.input_refine3d_job is None):
        # then we must receive a parameter file
        if args.mpi_parameters is None or args.mpi_parameters.strip()=="": 
            errors.append("You must provide following parameters: --maximum_nr_particles, --minimum_nr_particles, --input_postprocess_job, and --input_refine3d_job")
            errors.append("Or provide a yaml parameter file using --mpi_parameters")
    
    # This is for runs from the terminal, since Relion always provides the output directory
    #(this becomes a warning as it defaults to "External/bfactor_<timestamp>")
    # if args.output is None: 
    #     errors.append("RELION_IT: ERROR! You must specify the output directory!")

    if errors:
        for err in errors:
            print(err)
        if args.output: 
            open(os.path.join(args.output, "RELION_JOB_EXIT_FAILURE"), "w").close()
        return False
    return True

def load_star(filename):
    from collections import OrderedDict
    
    datasets = OrderedDict()
    current_data = None
    current_colnames = None
    
    in_loop = 0 # 0: outside 1: reading colnames 2: reading data

    for line in open(filename):
        line = line.strip()

        # remove comments
        comment_pos = line.find('#')
        if comment_pos > 0:
            line = line[:comment_pos]

        if line == "":
            if in_loop == 2:
                in_loop = 0
            continue

        if line.startswith("data_"):
            in_loop = 0

            data_name = line[5:]
            current_data = OrderedDict()
            datasets[data_name] = current_data

        elif line.startswith("loop_"):
            current_colnames = []
            in_loop = 1

        elif line.startswith("_"):
            if in_loop == 2:
                in_loop = 0

            elems = line[1:].split()
            if in_loop == 1:
                current_colnames.append(elems[0])
                current_data[elems[0]] = []
            else:
                current_data[elems[0]] = elems[1]

        elif in_loop > 0:
            in_loop = 2
            elems = line.split()
            assert len(elems) == len(current_colnames)
            for idx, e in enumerate(elems):
                current_data[current_colnames[idx]].append(e)

    return datasets

def getJobName(name_in_script, done_file):
    jobname = None
    # See if we've done this job before, i.e. whether it is in the done_file
    if (os.path.isfile(done_file)):
        f = open(done_file,'r')
        for line in f:
            elems = line.split()
            if len(elems) < 3: continue 
            if elems[0] == name_in_script:
                jobname = elems[2]
                break
        f.close()

    return jobname

def addJob(jobtype, name_in_script, done_file, options, template=None, alias=None):
    jobname = getJobName(name_in_script, done_file)

    # If we hadn't done it before, add it now
    if (jobname is not None):
        already_had_it = True 
    else:
        already_had_it = False
        optionstring = ''
        for opt in options[:]:
            optionstring += opt + ';'

        command = 'relion_pipeliner'

        if template is None:
            command += ' --addJob ' + jobtype
        else:
            command += ' --addJobFromStar ' + template

        command += ' --addJobOptions "' + optionstring + '"'
        if alias is not None:
            command += ' --setJobAlias "' + alias + '"'

        #print("Debug: addJob executes " + command)
        os.system(command)

        pipeline = load_star(PIPELINE_STAR)
        jobname = pipeline['pipeline_processes']['rlnPipeLineProcessName'][-1]
        
        # Now add the jobname to the done_file
        f = open(done_file,'a')
        f.write(name_in_script + ' = ' + jobname + '\n')
        f.close()

    # return the name of the job in the RELION pipeline, e.g. 'Import/job001/'
    return jobname, already_had_it

def RunJobs(jobs, repeat, wait, schedulename):

    runjobsstring = ''
    for job in jobs[:]:
        runjobsstring += job + ' '

    command = 'relion_pipeliner --schedule ' + schedulename + ' --repeat ' + str(repeat) + ' --min_wait ' + str(wait) + ' --RunJobs "' + runjobsstring + '" &' 

    #print("Debug: RunJobs executes " + command)
    os.system(command)

def CheckForExit():
    if not os.path.isfile(RUNNING_FILE):
        print(" BFACTOR | MESSAGE:", RUNNING_FILE, "file no longer exists, exiting now ...")
        exit(0)

def WaitForJob(wait_for_this_job, seconds_wait):
    time.sleep(seconds_wait)
    print(" BFACTOR | MESSAGE: waiting for job to finish in", wait_for_this_job)
    while True:
        pipeline = load_star(PIPELINE_STAR)
        myjobnr = -1
        for jobnr in range(0,len(pipeline['pipeline_processes']['rlnPipeLineProcessName'])):
            jobname = pipeline['pipeline_processes']['rlnPipeLineProcessName'][jobnr]
            if jobname == wait_for_this_job:
                myjobnr = jobnr
        if myjobnr < 0:
            print(" ERROR: cannot find ", wait_for_this_job, " in ", PIPELINE_STAR)
            exit(1)

        status = pipeline['pipeline_processes']['rlnPipeLineProcessStatusLabel'][myjobnr]
        if status == "Succeeded":
            print(" BFACTOR | MESSAGE: job in", wait_for_this_job, "has finished now")
            return
        else:
            CheckForExit()
            time.sleep(seconds_wait)

def find_split_job_output(prefix, n, max_digits=6):
    import os.path
    for i in range(max_digits):
        filename = prefix + str(n).rjust(i, '0') + '.star'
        if os.path.isfile(filename):
            return filename
    return None

def line_fit(xs, ys):
    n = len(xs)
    assert n == len(ys)

    mean_x = 0.0
    mean_y = 0.0
    for x, y in zip(xs, ys):
        mean_x += x
        mean_y += y

    mean_x /= n
    mean_y /= n

    var_x = 0.0
    cov_xy = 0.0
    for x, y in zip(xs, ys):
        var_x += (x - mean_x) ** 2
        cov_xy += (x - mean_x) * (y - mean_y)

    slope = cov_xy / var_x
    intercept = mean_y - slope * mean_x

    return slope, intercept

def get_postprocess_result(post_star):
    result = load_star(post_star)['general']
    resolution = float(result['rlnFinalResolution'])
    pp_bfactor = float(result['rlnBfactorUsedForSharpening'])
    return resolution, pp_bfactor

def run_pipeline(opts):
    """
    Configure and run the RELION 3 pipeline with the given options.
    
    Args:
        opts: options for the pipeline, as a RelionItOptions object.
    """

    # Write RUNNING_RELION_IT file, when deleted, this script will stop
    with open(RUNNING_FILE, 'w'):
        pass

    ### Prepare the list of queue arguments for later use
    queue_options = ['Submit to queue? == Yes',
                     'Queue name:  == {}'.format(opts.queue_name),
                     'Queue submit command: == {}'.format(opts.queue_submit_command),
                     'Standard submission script: == {}'.format(opts.queue_submission_template),
                     'Minimum dedicated cores per node: == {}'.format(opts.queue_minimum_dedicated)]

    # Get the original STAR file
    refine3d_run_file = os.path.join(opts.input_refine3d_job, "job.star")
    all_particles_star_file = None
    if os.path.exists(refine3d_run_file):
        for line in open(refine3d_run_file,'r'):
            if 'fn_img' in line:
                all_particles_star_file = line.split()[1].replace('\n','')
                break
    else:
        refine3d_run_file = os.path.join(opts.input_refine3d_job, "job.star") # old style
        for line in open(refine3d_run_file,'r'):
            if 'Input images STAR file' in line:
                all_particles_star_file = line.split(' == ')[1].replace('\n','')
                break
    if all_particles_star_file is None:
        print(' ERROR: cannot find input STAR file in', refine3d_run_file)
        exit(1)

    all_particles = load_star(all_particles_star_file)
    all_nr_particles = len(all_particles['particles']['rlnImageName'])
    all_particles_resolution, all_particles_bfactor = get_postprocess_result(opts.input_postprocess_job + 'postprocess.star') 

    nr_particles = []
    resolutions = []
    pp_bfactors = []

    current_nr_particles = opts.minimum_nr_particles
    while current_nr_particles <= opts.maximum_nr_particles and current_nr_particles < all_nr_particles:

        schedule_name = 'batch_' + str(current_nr_particles)

        # A. Split the STAR file
        split_options = ['OR select from particles.star: == {}'.format(all_particles_star_file),
                         'OR: split into subsets? == Yes',
                         'Subset size:  == {}'.format(current_nr_particles),
                         'Randomise order before making subsets?: == Yes',
                         'OR: number of subsets:  == 1']

        split_job_name = 'split_job_' + str(current_nr_particles)
        split_alias = opts.prefix + 'split_' + str(current_nr_particles)
        split_job, already_had_it = addJob('Select', split_job_name, SETUP_CHECK_FILE, split_options, None, split_alias)
        if not already_had_it:
            RunJobs([split_job], 1, 0, schedule_name)
            WaitForJob(split_job, 30)

        # B. Run Refine3D
        split_filename = find_split_job_output('{}particles_split'.format(split_job), 1)
        assert split_filename is not None
        refine_options = ['Input images STAR file: == {}'.format(split_filename),
                          'Number of pooled particles: == {}'.format(opts.refine_nr_pool),
                          'Which GPUs to use: == {}'.format(opts.refine_gpu),
                          'Number of MPI procs: == {}'.format(opts.refine_mpi),
                          'Initial low-pass filter (A): == {}'.format(opts.refine_ini_lowpass),
                          'Number of threads: == {}'.format(opts.refine_threads)]

        if opts.refine_skip_padding:
            refine_options.append('Skip padding? == Yes')
        else:    
            refine_options.append('Skip padding? == No')

        if opts.refine_do_gpu:
            refine_options.append('Use GPU acceleration? == Yes')
        else:
            refine_options.append('Use GPU acceleration? == No')

        if opts.refine_preread_images:
            refine_options.append('Pre-read all particles into RAM? == Yes')
            refine_options.append('Copy particles to scratch directory: == ')
        else:
            refine_options.append('Pre-read all particles into RAM? == No')
            refine_options.append('Copy particles to scratch directory: == {}'.format(opts.refine_scratch_disk))
        
        if opts.refine_submit_to_queue:
            refine_options.extend(queue_options)
        else:
            refine_options.append('Submit to queue? == No')

        refine_job_name = 'refine_job_' + str(current_nr_particles)
        refine_alias = opts.prefix + str(current_nr_particles)
        refine_job, already_had_it = addJob('Refine3D', refine_job_name, SETUP_CHECK_FILE, refine_options, refine3d_run_file, refine_alias)
        if not already_had_it:
            RunJobs([refine_job], 1, 0, schedule_name)
            WaitForJob(refine_job, 30)

        halfmap_filename = None
        try:
            job_star = load_star(refine_job + "job_pipeline.star")
            for output_file in job_star["pipeline_output_edges"]['rlnPipeLineEdgeToNode']:
                if output_file.endswith("half1_class001_unfil.mrc"):
                    halfmap_filename = output_file
                    break
            assert halfmap_filename != None
        except:
            print(" BFACTOR | MESSAGE: Refinement job " + refine_job + " does not contain expected output maps.")
            print(" BFACTOR | MESSAGE: This job should have finished, but you may continue it from the GUI.")
            print(" BFACTOR | MESSAGE: For now, making the plot without this job.")

        if halfmap_filename is not None:
            # C. Run PostProcess            
            postprocess_run_file = os.path.join(opts.input_postprocess_job, "job.star")
            if not os.path.exists(postprocess_run_file):
                postprocess_run_file = os.path.join(opts.input_postprocess_job, "run.star")
            post_options = ['One of the 2 unfiltered half-maps: == {}'.format(halfmap_filename)]
            post_job_name = 'post_job_' + str(current_nr_particles)
            post_alias = opts.prefix + str(current_nr_particles)
            post_job, already_had_it = addJob('PostProcess', post_job_name, SETUP_CHECK_FILE, post_options, postprocess_run_file, post_alias)
            if not already_had_it:
                RunJobs([post_job], 1, 0, schedule_name)
                WaitForJob(post_job, 30)
        
            # Get resolution from
            post_star = post_job + 'postprocess.star'
            try:
                resolution, pp_bfactor = get_postprocess_result(post_star)
                nr_particles.append(current_nr_particles)
                resolutions.append(resolution)
                pp_bfactors.append(pp_bfactor)
            except:
                print(' BFACTOR | WARNING: Failed to get post-processed resolution for {} particles'.format(current_nr_particles))

        # Update the current number of particles
        current_nr_particles = 2 * current_nr_particles

    # Also include the result from the original PostProcessing job
    if all_nr_particles <= opts.maximum_nr_particles:
        nr_particles.append(all_nr_particles)
        resolutions.append(all_particles_resolution)
        pp_bfactors.append(all_particles_bfactor)

    # Now already make preliminary plots here, e.g
    output_info = []
    print()
    output_info += ["NrParticles Ln(NrParticles) Resolution(A) 1/Resolution^2 PostProcessBfactor"]
    xs = []
    ys = []
    for n_particles, resolution, pp_bfactor in zip(nr_particles, resolutions, pp_bfactors):
        log_n_particles = log(n_particles)
        inv_d2 = 1.0 / (resolution * resolution)
        output_info += ['{0:11d} {1:15.3f} {2:13.2f} {3:14.4f} {4:18.2f}'.format(n_particles,log_n_particles, resolution, inv_d2, -pp_bfactor)]

        xs.append(log_n_particles)
        ys.append(inv_d2)
    slope, intercept = line_fit(xs, ys)
    b_factor = 2.0 / slope
    output_info += [""]
    output_info += ["ESTIMATED B-FACTOR from {0:d} points is {1:.2f}".format(len(xs), b_factor)]
    output_info += ["The fitted line is: Resolution = 1 / Sqrt(2 / {0:.3f} * Log_e(#Particles) + {1:.3f})".format(b_factor, intercept)]
    output_info += ["IF this trend holds, you will get:"]
    for x in (1.5, 2, 4, 8):
        current_nr_particles = int(all_nr_particles * x)
        resolution = 1 / sqrt(slope * log(current_nr_particles) + intercept)
        output_info += ["   {0:.2f} A from {1:d} particles ({2:d} % of the current number of particles)".format(resolution, current_nr_particles, int(x * 100))]
    output_info+=[""]
    print("\n".join(output_info))
    # saves it to a .txt
    with open(os.path.join(opts.output, opts.outtext), mode='w') as file:
        file.write("\n".join(output_info))

    if IMPORTS_OK:        
        fitted = []
        for x in xs:
            fitted.append(x * slope + intercept)

        fig = plt.figure()
        ax1 = fig.add_subplot(111)
        ax1.plot(xs, ys, '.')
        ax1.plot(xs, fitted)
        ax1.set_xlabel("ln(#particles)")
        ax1.set_ylabel("1/Resolution$^2$ in 1/$\u00C5^2$") #@2025.03.10 locale friendly
        ax1.set_title("Rosenthal & Henderson plot: B = 2.0 / slope = {:.1f}".format(b_factor));

        ax2 = ax1.twiny()
        ax2.xaxis.set_ticks_position("bottom")
        ax2.xaxis.set_label_position("bottom")
        ax2.set_xlim(ax1.get_xlim())
        ax2.spines["bottom"].set_position(("axes", -0.15)) # In matplotlib 1.2, the order seems to matter
        ax2.set_xlabel("#particles")
        #@2025.03.18: fixed UserWarning for not setting ticks before setting labels
        ax2.xaxis.set_major_locator(FixedLocator(ax1.get_xticks()))
        ax2.xaxis.set_major_formatter(FixedFormatter(np.exp(ax1.get_xticks()).astype(int)))
    
        ax3 = ax1.twinx()
        ax3.set_ylabel("Resolution in $\u00C5$")
        ax3.set_ylim(ax1.get_ylim())
        ax3.yaxis.set_ticks_position("right")
        ax3.yaxis.set_label_position("right")
        yticks = ax1.get_yticks()
        yticks[yticks <= 0] = 1.0 / (999 * 999) # to avoid zero division and negative sqrt
        ndigits = 1
        if np.max(yticks) > 0.25:
            ndigits = 2
        #@2025.03.18: fixed UserWarning for not setting ticks before setting labels
        ax3.yaxis.set_major_locator(FixedLocator(ax1.get_yticks()))
        ax3.yaxis.set_major_formatter(FixedFormatter(np.sqrt(1 / yticks).round(ndigits)))

        output_name = os.path.join(opts.output, opts.outfile) # @2025.03.10: save it to the output folder
        plt.savefig(output_name, bbox_inches='tight')
        print(" BFACTOR | MESSAGE: Plot written to " + output_name)
    else:
        print('WARNING: Failed to plot. Probably matplotlib and/or numpy is missing.')


def move_files(opts):
    if os.path.isfile(RUNNING_FILE):
        os.remove(RUNNING_FILE)

    #@2025.03.31: move SUBMITTED_JOB and .log to the output directory
    if os.path.isfile(SETUP_CHECK_FILE):
        os.rename(SETUP_CHECK_FILE, os.path.join(opts.output, SETUP_CHECK_FILE))
    for file in glob.glob("pipeline_batch*.log"):
        os.rename(file, os.path.join(opts.output, file))

def main():
    global RUNNING_FILE
    global SETUP_CHECK_FILE

    print(' BFACTOR | MESSAGE: -------------------------------------------------------------------------------------------------------------------')
    print(' BFACTOR | MESSAGE: Script for automated Bfactor-plot generation in RELION (>= 3.1)')
    print(' BFACTOR | MESSAGE: Authors: Sjors H.W. Scheres & Takanori Nakane')
    print(' BFACTOR | MESSAGE: Modified by: (2025.03) Jair Pereira and Toshio Moriya')
    print(' BFACTOR | MESSAGE: Usage example: python3 ./bfactor_plot_kek.py -o path_output -p path_parameter.yaml -i3d Refine3D/job049/ -ipp PostProcess/job050/ --minimum_nr_particles 225 --maximum_nr_particles 7200')
    print(' BFACTOR | MESSAGE: -------------------------------------------------------------------------------------------------------------------')

    parser = argparse.ArgumentParser()
    parser.add_argument("-o", "--output",                  type=str, default="External/bfactor/", help = "Output job directory path")
    parser.add_argument("-j", "--j", "--threads",          type=str, default='1',  help="Number of threads (Input from RELION. Not used here).")
    parser.add_argument("-p", "--mpi_parameters",          type=str, default=None, help="A .yaml file specifying machine parameters")
    parser.add_argument("-i3d", "--input_refine3d_job",    type=str, help="Refine 3D job output directory is required! (e.g: PostProcess/job050/)")
    parser.add_argument("-ipp", "--input_postprocess_job", type=str, help="Postprocess job output directory is required! (e.g: Refine3D/job049/)")
    parser.add_argument("-minp", "--minimum_nr_particles", type=int, default=5000,   help="Minimun Number of Particles (int)")
    parser.add_argument("-maxp", "--maximum_nr_particles", type=int, default=400000, help="Maximum Number of Particles (int)")  

    args, unknown = parser.parse_known_args()
    print(" BFACTOR | MESSAGE: B-Factor Plot running...")

    opts = RelionItOptions(
        from_terminal = args,
        from_yaml     = load_yaml_parameters(args.mpi_parameters) # if provided
    )
    from_jobstar = read_and_merge_job_parameters([os.path.join(jobs, "job.star") 
                    for jobs in [opts.input_refine3d_job, opts.input_postprocess_job]], PARAMS_TRANS)
    opts.load_parameters_from_dictionary(from_jobstar) # if no yaml, get from input jobs

    # Make output directory
    opts.output = make_output_directory(output_path=args.output)
    )

    print(" BFACTOR | MESSAGE: Using Refine3D Job directory as: ",      opts.input_refine3d_job)
    print(" BFACTOR | MESSAGE: Using PostProcess Job directory as: ",   opts.input_postprocess_job)
    print(" BFACTOR | MESSAGE: Using Minimum Number of Particles as: ", opts.minimum_nr_particles)
    print(" BFACTOR | MESSAGE: Using Maximum Number of Particles as: ", opts.maximum_nr_particles)
    print(" BFACTOR | MESSAGE: Writing output to: ", opts.output, flush=True)
    print(' BFACTOR | MESSAGE: -------------------------------------------------------------------------------------------------------------------')
    
    SETUP_CHECK_FILE = opts.prefix + SETUP_CHECK_FILE
    RUNNING_FILE = opts.prefix + RUNNING_FILE

    # Make sure no other version of this script are running...
    if os.path.isfile(RUNNING_FILE):
        print(" BFACTOR | ERROR:", RUNNING_FILE, "is already present: delete this file and make sure no other copy of this script is running. Exiting now ...")
        exit(0)

    try:
        # Run the bfactor pipeline
        run_pipeline(opts)
        ## Creates RELION_OUTPUT_NODES star file
        make_rln_output_node_file(outpath=opts.output, outfiles=[opts.outfile, opts.outtext] if IMPORTS_OK else [opts.outtext]) # cant produce .pdf if numpy and matplot are missing...
        open(os.path.join(args.output, "RELION_JOB_EXIT_SUCCESS"), "w")
    finally:
        move_files(opts) # move all files to the output directory
        print(' BFACTOR | MESSAGE: exiting now... ')
    

if __name__ == "__main__":
    main()
        
