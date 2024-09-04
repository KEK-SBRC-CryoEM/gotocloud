
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
  do_queue        Yes 
   do_tilt         No 
do_trefoil         No 
   fn_data CtfRefine/job023/particles_ctf_refine.star 
   fn_post PostProcess/job021/postprocess.star 
min_dedicated         24 
    minres         30 
    nr_mpi         24 
nr_threads          8 
other_args         "" 
      qsub     sbatch 
qsub_extra1 m7i-vcpu192-gpu0 
qsub_extra2          1 
qsubscript /efs/em/aws_slurm_relion_excl.sh 
 queuename Job024_CtfRefine 
 
