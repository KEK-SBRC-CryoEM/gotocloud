
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
  do_queue        Yes 
extend_inimask          0 
     fn_in Refine3D/job019/run_class001.mrc 
helical_z_percentage         30 
inimask_threshold      0.005 
lowpass_filter         15 
min_dedicated          1 
nr_threads        192 
other_args         "" 
      qsub     sbatch 
qsub_extra1 c7i-vcpu192-gpu0 
qsub_extra2          1 
qsubscript /efs/em/aws_slurm_relion_excl.sh 
 queuename Job020_MaskCreate 
width_mask_edge          6 
 
