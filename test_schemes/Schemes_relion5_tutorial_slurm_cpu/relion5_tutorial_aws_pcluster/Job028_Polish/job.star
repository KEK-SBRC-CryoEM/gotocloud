
# version 30001

data_job

_rlnJobTypeLabel             relion.polish
_rlnJobIsContinue                       0
_rlnJobIsTomo                           0
 

# version 30001

data_joboptions_values

loop_ 
_rlnJobOptionVariable #1 
_rlnJobOptionValue #2 
do_float16        Yes 
do_own_params         No 
do_param_optim         No 
 do_polish        Yes 
  do_queue        Yes 
 eval_frac        0.5 
extract_size         -1 
first_frame          1 
   fn_data Refine3D/job025/run_data.star 
    fn_mic MotionCorr/job002/corrected_micrographs.star 
   fn_post PostProcess/job026/postprocess.star 
last_frame         -1 
    maxres         -1 
min_dedicated         16 
    minres         20 
    nr_mpi         16 
nr_threads         12 
opt_params Polish/job027/opt_params_all_groups.txt 
optim_min_part       3500 
other_args         "" 
      qsub     sbatch 
qsub_extra1 m7i-vcpu192-gpu0 
qsub_extra2          1 
qsubscript /efs/em/aws_slurm_relion_excl.sh 
 queuename Job028_Polish 
   rescale         -1 
 sigma_acc          2 
 sigma_div       5000 
 sigma_vel        0.2 
 
