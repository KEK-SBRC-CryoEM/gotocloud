
# version 30001

data_job

_rlnJobTypeLabel             relion.external
_rlnJobIsContinue                       0
_rlnJobIsTomo                           0
 

# version 30001

data_joboptions_values

loop_ 
_rlnJobOptionVariable #1 
_rlnJobOptionValue #2 
  do_queue         No 
    fn_exe $$cryolo_exe 
  in_3dref         "" 
 in_coords         "" 
   in_mask         "" 
    in_mic CtfFind/job003/micrographs_ctf.star 
    in_mov         "" 
   in_part         "" 
min_dedicated JSE_DISABLED_PARALLEL 
nr_threads          1 
other_args         "" 
param10_label         "" 
param10_value         "" 
param1_label cryolo_repo 
param1_value $$cryolo_repo 
param2_label  threshold 
param2_value        0.3 
param3_label     device 
param3_value          0 
param4_label         "" 
param4_value         "" 
param5_label         "" 
param5_value         "" 
param6_label         "" 
param6_value         "" 
param7_label         "" 
param7_value         "" 
param8_label         "" 
param8_value         "" 
param9_label         "" 
param9_value         "" 
      qsub JSE_DISABLED_PARALLEL 
qsub_extra1 JSE_DISABLED_PARALLEL 
qsub_extra2 JSE_DISABLED_PARALLEL 
qsubscript JSE_DISABLED_PARALLEL 
 queuename Job032_External_cryolo 
 
