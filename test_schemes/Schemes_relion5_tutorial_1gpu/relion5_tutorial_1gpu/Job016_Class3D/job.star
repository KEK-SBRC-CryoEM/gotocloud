
# version 30001

data_job

_rlnJobTypeLabel             relion.class3d
_rlnJobIsContinue                       0
_rlnJobIsTomo                           0
 

# version 30001

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
do_preread_images         No 
  do_queue         No 
do_zero_mask        Yes 
dont_skip_align        Yes 
   fn_cont         "" 
    fn_img Select/job014/particles.star 
   fn_mask         "" 
    fn_ref InitialModel/job015/initial_model.mrc 
   gpu_ids          0 
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
min_dedicated JSE_DISABLED_PARALLEL 
nr_classes          4 
   nr_iter         25 
    nr_mpi          3 
   nr_pool         30 
nr_threads          8 
offset_range          5 
offset_step          1 
other_args         "" 
particle_diameter        200 
      qsub JSE_DISABLED_PARALLEL 
qsub_extra1 JSE_DISABLED_PARALLEL 
qsub_extra2 JSE_DISABLED_PARALLEL 
qsubscript JSE_DISABLED_PARALLEL 
 queuename Job016_Class3D 
 range_psi         10 
 range_rot         -1 
range_tilt         15 
ref_correct_greyscale        Yes 
 relax_sym         "" 
  sampling "7.5 degrees" 
scratch_dir   /scratch 
sigma_angles          5 
  sym_name         C1 
 tau_fudge          4 
   use_gpu        Yes 
 
