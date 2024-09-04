
# version 30001

data_job

_rlnJobTypeLabel             relion.localres.own
_rlnJobIsContinue                       0
_rlnJobIsTomo                           0
 

# version 30001

data_joboptions_values

loop_ 
_rlnJobOptionVariable #1 
_rlnJobOptionValue #2 
adhoc_bfac        -30 
    angpix      1.244 
  do_queue        Yes 
do_relion_locres        Yes 
do_resmap_locres         No 
     fn_in Refine3D/job029/run_half1_class001_unfil.mrc 
   fn_mask MaskCreate/job020/mask.mrc 
    fn_mtf mtf_k2_200kV.star 
 fn_resmap         "" 
    maxres          0 
min_dedicated         24 
    minres          0 
    nr_mpi         24 
other_args         "" 
      pval       0.05 
      qsub     sbatch 
qsub_extra1 m7i-vcpu192-gpu0 
qsub_extra2          1 
qsubscript /efs/em/aws_slurm_relion_excl.sh 
 queuename Job031_LocalRes 
   stepres          1 
 
