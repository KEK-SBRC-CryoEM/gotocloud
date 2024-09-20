
# version 30001

data_job

_rlnJobTypeLabel             relion.ctfrefine
_rlnJobIsContinue                       0
_rlnJobIsTomo                           0
 

# version 30001

data_joboptions_values

loop_ 
_rlnJobOptionVariable #1 
_rlnJobOptionValue #2 
do_4thorder         No 
do_aniso_mag         No 
  do_astig Per-micrograph 
do_bfactor         No 
    do_ctf        Yes 
do_defocus Per-particle 
  do_phase         No 
  do_queue         No 
   do_tilt         No 
do_trefoil         No 
   fn_data CtfRefine/job023/particles_ctf_refine.star 
   fn_post PostProcess/job021/postprocess.star 
min_dedicated JSE_DISABLED_PARALLEL 
    minres         30 
    nr_mpi         24 
nr_threads          1 
other_args         "" 
      qsub JSE_DISABLED_PARALLEL 
qsub_extra1 JSE_DISABLED_PARALLEL 
qsub_extra2 JSE_DISABLED_PARALLEL 
qsubscript JSE_DISABLED_PARALLEL 
 queuename Job024_CtfRefine 
 
