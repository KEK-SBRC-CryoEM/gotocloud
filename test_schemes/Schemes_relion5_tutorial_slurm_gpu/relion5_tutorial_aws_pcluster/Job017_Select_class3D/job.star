
# version 30001

data_job

_rlnJobTypeLabel             relion.select.interactive
_rlnJobIsContinue                       1
_rlnJobIsTomo                           0
 

# version 30001

data_joboptions_values

loop_ 
_rlnJobOptionVariable #1 
_rlnJobOptionValue #2 
discard_label rlnImageName 
discard_sigma          4 
do_class_ranker         No 
do_discard         No 
  do_queue         No 
 do_random         No 
do_recenter         No 
do_regroup         No 
do_remove_duplicates         No 
do_select_values         No 
  do_split         No 
duplicate_threshold         30 
   fn_data         "" 
    fn_mic         "" 
  fn_model Class3D/job016/run_it025_optimiser.star 
image_angpix         -1 
min_dedicated         48 
 nr_groups          1 
  nr_split         -1 
other_args         "" 
      qsub       "" 
qsubscript "" 
 queuename    Job017_Select 
rank_threshold       0.25 
select_label rlnCtfMaxResolution 
select_maxval      9999. 
select_minval     -9999. 
select_nr_classes         -1 
select_nr_parts         -1 
split_size         10 
qsub_extra1 "" 
qsub_extra2 ""