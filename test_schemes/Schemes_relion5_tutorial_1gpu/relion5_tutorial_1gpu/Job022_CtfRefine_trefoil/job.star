
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
do_4thorder        Yes 
do_aniso_mag         No 
  do_astig         No 
do_bfactor         No 
    do_ctf         No 
do_defocus         No 
  do_phase         No 
  do_queue         No 
   do_tilt        Yes 
do_trefoil        Yes 
   fn_data Refine3D/job019/run_data.star 
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
 queuename Job022_CtfRefine 
 
