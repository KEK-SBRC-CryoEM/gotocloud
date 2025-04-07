
# version 50001

data_job

_rlnJobTypeLabel             relion.external
_rlnJobIsContinue                       0
_rlnJobIsTomo                           0
 

# version 50001

data_joboptions_values

loop_ 
_rlnJobOptionVariable #1 
_rlnJobOptionValue #2 
  do_queue         No 
    fn_exe ./bfactor_plot/bfactor_plot.py
  in_3dref         "" 
 in_coords         "" 
   in_mask         "" 
    in_mic         "" 
    in_mov         "" 
   in_part         "" 
min_dedicated          1 
nr_threads          1 
other_args         "" 
param10_label         "" 
param10_value         "" 
param1_label    parameter_file
param1_value    $$cs_parameter_file
param2_label    input_refine3d_job
param2_value    $$cs_input_refine3d_job
param3_label    input_postprocess_job
param3_value    $$cs_input_postprocess_job
param4_label    minimum_nr_particles
param4_value    $$cs_minimum_nr_particles
param5_label    maximum_nr_particles
param5_value    $$cs_maximum_nr_particles
param6_label         "" 
param6_value         "" 
param7_label         "" 
param7_value         "" 
param8_label         "" 
param8_value         "" 
param9_label         "" 
param9_value         "" 
      qsub     sbatch 
qsubscript /public/EM/RELION/relion/bin/relion_qsub.csh 
 queuename    openmpi 
 
