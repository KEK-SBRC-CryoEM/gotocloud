
# version 30001

data_job

_rlnJobTypeLabel             relion.maskcreate
_rlnJobIsContinue                       0
_rlnJobIsTomo                           0
 

# version 30001

data_joboptions_values

loop_ 
_rlnJobOptionVariable #1 
_rlnJobOptionValue #2 
    angpix         -1 
  do_helix         No 
  do_queue         No 
extend_inimask          0 
     fn_in Refine3D/job019/run_class001.mrc 
helical_z_percentage         30 
inimask_threshold      0.005 
lowpass_filter         15 
min_dedicated JSE_DISABLED_PARALLEL 
nr_threads         32 
other_args         "" 
      qsub JSE_DISABLED_PARALLEL 
qsub_extra1 JSE_DISABLED_PARALLEL 
qsub_extra2 JSE_DISABLED_PARALLEL 
qsubscript JSE_DISABLED_PARALLEL 
 queuename Job020_MaskCreate 
width_mask_edge          6 
 
