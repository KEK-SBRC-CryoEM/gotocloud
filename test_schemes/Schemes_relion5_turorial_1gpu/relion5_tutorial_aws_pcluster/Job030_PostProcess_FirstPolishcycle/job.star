
# version 30001

data_job

_rlnJobTypeLabel             relion.postprocess
_rlnJobIsContinue                       0
_rlnJobIsTomo                           0
 

# version 30001

data_joboptions_values

loop_ 
_rlnJobOptionVariable #1 
_rlnJobOptionValue #2 
adhoc_bfac      -1000 
    angpix      1.244 
autob_lowres         10 
do_adhoc_bfac         No 
do_auto_bfac        Yes 
  do_queue         No 
do_skip_fsc_weighting         No 
     fn_in Refine3D/job029/run_half1_class001_unfil.mrc 
   fn_mask MaskCreate/job020/mask.mrc 
    fn_mtf mtf_k2_200kV.star 
  low_pass          5 
min_dedicated JSE_DISABLED_PARALLEL 
mtf_angpix      0.885 
other_args         "" 
      qsub JSE_DISABLED_PARALLEL 
qsub_extra1 JSE_DISABLED_PARALLEL 
qsub_extra2 JSE_DISABLED_PARALLEL 
qsubscript JSE_DISABLED_PARALLEL 
 queuename Job030_PostProcess 
 
