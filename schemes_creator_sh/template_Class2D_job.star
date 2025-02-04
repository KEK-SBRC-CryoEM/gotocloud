
# version 50001

data_job

_rlnJobTypeLabel             relion.class2d
_rlnJobIsContinue                       0
_rlnJobIsTomo                           0


# version 50001

data_joboptions_values

loop_
_rlnJobOptionVariable #1
_rlnJobOptionValue #2
allow_coarser         No
ctf_intact_first_peak         No
do_bimodal_psi        Yes
 do_center        Yes
do_combine_thru_disc         No
do_ctf_correction        Yes
     do_em        Yes
   do_grad         No
  do_helix         No
do_parallel_discio        Yes
do_preread_images         XXX_PREREAD_IMAGES_XXX
  do_queue        Yes
do_restrict_xoff        Yes
do_zero_mask        Yes
dont_skip_align        Yes
   fn_cont         ""
    fn_img Inputs/Class2D/particles.star
   gpu_ids XXX_GPU_IDS_XXX
helical_rise       4.75
helical_tube_outer_diameter        200
highres_limit         -1
min_dedicated          XXX_MINIMUM_DEDICATED_XXX
nr_classes        200
nr_iter_em         25
nr_iter_grad        200
    nr_mpi         XXX_NUMBER_OF_MPI_XXX
   nr_pool         XXX_NR_POOL_XXX
nr_threads          XXX_NUMBER_OF_THREADS_XXX
offset_range          5
offset_step          1
other_args         XXX_ADDITIONAL_ARGS_XXX
particle_diameter        120
psi_sampling          6
      qsub     XXX_SUBMIT_COMMAND_XXX
qsub_extra1 XXX_PARTITION_XXX
qsub_extra2 XXX_NUMBER_OF_NODES_XXX
qsubscript XXX_SUBMIT_SCRIPT_XXX
 queuename    Class2D
 range_psi          6
scratch_dir   XXX_SCRATCH_DIR_XXX
 tau_fudge          2
   use_gpu        XXX_USE_GPU_XXX

