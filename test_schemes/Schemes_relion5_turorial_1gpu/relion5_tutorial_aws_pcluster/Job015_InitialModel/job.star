
# version 30001

data_job

_rlnJobTypeLabel             relion.initialmodel
_rlnJobIsContinue                       0
_rlnJobIsTomo                           0
 

# version 30001

data_joboptions_values

loop_ 
_rlnJobOptionVariable #1 
_rlnJobOptionValue #2 
ctf_intact_first_peak         No 
do_combine_thru_disc         No 
do_ctf_correction        Yes 
do_parallel_discio        Yes 
do_preread_images         No 
  do_queue         No 
 do_run_C1        Yes 
do_solvent        Yes 
   fn_cont         "" 
    fn_img Select/job014/particles.star 
   gpu_ids          0 
min_dedicated JSE_DISABLED_PARALLEL 
nr_classes          1 
   nr_iter        100 
    nr_mpi          1 
   nr_pool         30 
nr_threads         24 
other_args         "" 
particle_diameter        200 
      qsub JSE_DISABLED_PARALLEL 
qsub_extra1 JSE_DISABLED_PARALLEL 
qsub_extra2 JSE_DISABLED_PARALLEL 
qsubscript JSE_DISABLED_PARALLEL 
 queuename Job015_InitialModel 
scratch_dir   /scratch 
  sym_name         D2 
 tau_fudge          4 
   use_gpu        Yes 
 
