
# version 50001

data_job

_rlnJobTypeLabel             relion.class3d
_rlnJobIsContinue                       0
_rlnJobIsTomo                           0


# version 50001

data_joboptions_values

loop_
_rlnJobOptionVariable #1
_rlnJobOptionValue #2
allow_coarser         No
ctf_intact_first_peak         No
do_apply_helical_symmetry        Yes
do_blush        Yes
do_combine_thru_disc         No
do_ctf_correction        Yes
do_fast_subsets         No
  do_helix         No
do_local_ang_searches         No
do_local_search_helical_symmetry         No
   do_pad1         No
do_parallel_discio        Yes
do_preread_images         XXX_PREREAD_IMAGES_XXX
  do_queue        Yes
do_zero_mask        Yes
dont_skip_align        Yes
   fn_cont         ""
    fn_img Inputs/Class3D/particles.star
   fn_mask         ""
    fn_ref Inputs/Class3D/ref_map3d.mrc
   gpu_ids XXX_GPU_IDS_XXX
helical_nr_asu          1
helical_range_distance         -1
helical_rise_inistep          0
helical_rise_initial          0
helical_rise_max          0
helical_rise_min          0
helical_tube_inner_diameter         -1
helical_tube_outer_diameter         -1
helical_twist_inistep          0
helical_twist_initial          0
helical_twist_max          0
helical_twist_min          0
helical_z_percentage         30
highres_limit         -1
  ini_high         50
keep_tilt_prior_fixed        Yes
min_dedicated          XXX_MINIMUM_DEDICATED_XXX
nr_classes          4
   nr_iter         25
    nr_mpi         XXX_NUMBER_OF_MPI_XXX
   nr_pool         XXX_NR_POOL_XXX
nr_threads          XXX_NUMBER_OF_THREADS_XXX
offset_range          5
offset_step          1
other_args         XXX_ADDITIONAL_ARGS_XXX
particle_diameter        120
      qsub     XXX_SUBMIT_COMMAND_XXX
qsub_extra1 XXX_PARTITION_XXX
qsub_extra2 XXX_NUMBER_OF_NODES_XXX
qsubscript XXX_SUBMIT_SCRIPT_XXX
 queuename    Class3D
 range_psi         10
 range_rot         -1
range_tilt         15
ref_correct_greyscale        Yes
 relax_sym         ""
  sampling "7.5 degrees"
scratch_dir   XXX_SCRATCH_DIR_XXX
sigma_angles          5
  sym_name         C1
 tau_fudge          4
trust_ref_size         No
   use_gpu        XXX_USE_GPU_XXX

