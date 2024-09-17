
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
do_own_params        Yes 
do_param_optim         No 
 do_polish        Yes 
  do_queue        Yes 
 eval_frac        0.5 
extract_size         -1 
first_frame          1 
   fn_data Inputs/Polish/particles.star 
    fn_mic Inputs/Polish/corrected_micrographs.star 
   fn_post Inputs/Polish/postprocess.star 
last_frame         -1 
    maxres         -1 
min_dedicated          XXX_MINIMUM_DEDICATED_XXX 
    minres         20 
    nr_mpi         XXX_NUMBER_OF_MPI_XXX 
nr_threads         XXX_NUMBER_OF_THREADS_XXX 
opt_params         "" 
optim_min_part      10000 
other_args         XXX_ADDITIONAL_ARGS_XXX 
      qsub     XXX_SUBMIT_COMMAND_XXX 
qsub_extra1 XXX_PARTITION_XXX 
qsubscript XXX_SUBMIT_SCRIPT_XXX
 queuename     Polish 
   rescale         -1 
 sigma_acc          2 
 sigma_div       5000 
 sigma_vel        0.2 
 
