
# version 30001

data_job

_rlnJobTypeLabel             relion.autopick.log
_rlnJobIsContinue                       0
_rlnJobIsTomo                           0
 

# version 30001

data_joboptions_values

loop_ 
_rlnJobOptionVariable #1 
_rlnJobOptionValue #2 
    angpix         -1 
angpix_ref         -1 
continue_manual         No 
do_amyloid         No 
do_ctf_autopick        Yes 
do_ignore_first_ctfpeak_autopick         No 
do_invert_refs        Yes 
    do_log        Yes 
do_pick_helical_segments         No 
  do_queue        Yes 
do_read_fom_maps         No 
  do_ref3d         No 
   do_refs         No 
  do_topaz         No 
do_topaz_pick         No 
do_topaz_train         No 
do_topaz_train_parts         No 
do_write_fom_maps         No 
fn_input_autopick Select/job005/micrographs_split1.star 
fn_ref3d_autopick         "" 
fn_refs_autopick         "" 
fn_topaz_exe relion_python_topaz 
   gpu_ids         "" 
helical_nr_asu          1 
helical_rise         -1 
helical_tube_kappa_max        0.1 
helical_tube_length_min         -1 
helical_tube_outer_diameter        200 
  highpass         -1 
log_adjust_thr          0 
log_diam_max        180 
log_diam_min        150 
log_invert         No 
log_maxres         20 
log_upper_thr          5 
   lowpass         20 
maxstddevnoise_autopick        1.1 
min_dedicated         24 
minavgnoise_autopick       -999 
mindist_autopick        100 
    nr_mpi         24 
other_args         "" 
psi_sampling_autopick          5 
      qsub     sbatch 
qsub_extra1 m7i-vcpu192-gpu0 
qsub_extra2          1 
qsubscript /efs/em/aws_slurm_relion_excl.sh 
 queuename Job006_AutoPick 
ref3d_sampling "30 degrees" 
ref3d_symmetry         C1 
    shrink          0 
threshold_autopick       0.05 
topaz_model         "" 
topaz_nr_particles         -1 
topaz_other_args         "" 
topaz_particle_diameter         -1 
topaz_train_parts         "" 
topaz_train_picks         "" 
   use_gpu         No 
 
