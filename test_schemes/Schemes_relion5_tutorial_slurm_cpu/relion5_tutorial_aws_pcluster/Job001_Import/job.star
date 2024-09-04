
# version 30001

data_job

_rlnJobTypeLabel             relion.import.movies
_rlnJobIsContinue                       0
_rlnJobIsTomo                           0
 

# version 30001

data_joboptions_values

loop_ 
_rlnJobOptionVariable #1 
_rlnJobOptionValue #2 
        Cs        1.4 
        Q0        0.1 
    angpix      0.885 
beamtilt_x          0 
beamtilt_y          0 
  do_other         No 
  do_queue         No 
    do_raw        Yes 
fn_in_other    ref.mrc 
 fn_in_raw Movies/*.tiff 
    fn_mtf mtf_k2_200kV.star 
is_multiframe        Yes 
        kV        200 
min_dedicated          0 
 node_type "Particle coordinates (*.box, *_pick.star)" 
optics_group_name opticsGroup1 
optics_group_particles         "" 
other_args         "" 
      qsub JSE_DISABLED_PARALLEL 
qsub_extra1 JSE_DISABLED_PARALLEL 
qsub_extra2          0 
qsubscript JSE_DISABLED_PARALLEL 
 queuename Job001_Import 
 
