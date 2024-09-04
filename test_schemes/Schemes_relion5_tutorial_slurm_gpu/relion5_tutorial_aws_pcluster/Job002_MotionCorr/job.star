
# version 30001

data_job

_rlnJobTypeLabel             relion.motioncorr.own
_rlnJobIsContinue                       0
_rlnJobIsTomo                           0
 

# version 30001

data_joboptions_values

loop_ 
_rlnJobOptionVariable #1 
_rlnJobOptionValue #2 
   bfactor        150 
bin_factor          1 
do_dose_weighting        Yes 
do_float16        Yes 
do_own_motioncor        Yes 
  do_queue        Yes 
do_save_noDW         No 
do_save_ps        Yes 
dose_per_frame      1.277 
eer_grouping         32 
first_frame_sum          1 
 fn_defect         "" 
fn_gain_ref Movies/gain.mrc 
fn_motioncor2_exe $$motioncor2_exe 
 gain_flip "No flipping (0)" 
  gain_rot "No rotation (0)" 
   gpu_ids         "" 
group_for_ps          4 
group_frames          1 
input_star_mics Import/job001/movies.star 
last_frame_sum         -1 
min_dedicated         24 
    nr_mpi         24 
nr_threads          8 
other_args         "" 
other_motioncor2_args         "" 
   patch_x          5 
   patch_y          5 
pre_exposure          0 
      qsub     sbatch 
qsub_extra1 m7i-vcpu192-gpu0 
qsub_extra2          1 
qsubscript /efs/em/aws_slurm_relion_excl.sh 
 queuename Job002_MotionCorr 
 
