
# version 30001

data_scheme_general

_rlnSchemeName                       Schemes/relion5_tutorial_aws_pcluster/
_rlnSchemeCurrentNodeName            Job001_Import

# version 30001

data_scheme_floats

loop_ 
_rlnSchemeFloatVariableName #1 
_rlnSchemeFloatVariableValue #2 
_rlnSchemeFloatVariableResetValue #3 
do_at_most    50.000000    50.000000 
maxtime_hr    48.000000    48.000000 
  wait_sec   180.000000   180.000000 


# version 30001

data_scheme_bools

loop_ 
_rlnSchemeBooleanVariableName #1 
_rlnSchemeBooleanVariableValue #2 
_rlnSchemeBooleanVariableResetValue #3
dummy       0      0


# version 30001

data_scheme_strings

loop_ 
_rlnSchemeStringVariableName #1 
_rlnSchemeStringVariableValue #2 
_rlnSchemeStringVariableResetValue #3 
ctffind_exe               /efs/em/ctffind-4.1.14-linux64/bin/ctffind                          /efs/em/ctffind-4.1.14-linux64/bin/ctffind
gctf_exe                  /efs/em/Gctf_v1.06/bin/Gctf-v1.06_sm_20_cu7.5_x86_64                /efs/em/Gctf_v1.06/bin/Gctf-v1.06_sm_20_cu7.5_x86_64
motioncor2_exe            ""                                                                  ""
topaz_exe                 relion_python_topaz                                                 relion_python_topaz
cryolo_repo               /efs/em/cryolo                                                      /efs/em/cryolo
cryolo_exe                /efs/em/cryolo/gtf_relion4_run_cryolo_system.sh                     /efs/em/cryolo/gtf_relion4_run_cryolo_system.sh


# version 30001

data_scheme_operators

loop_ 
_rlnSchemeOperatorName #1 
_rlnSchemeOperatorType #2 
_rlnSchemeOperatorOutput #3 
_rlnSchemeOperatorInput1 #4 
_rlnSchemeOperatorInput2 #5 
      EXIT       exit  undefined  undefined  undefined 
 

# version 30001

data_scheme_jobs

loop_ 
_rlnSchemeJobNameOriginal #1 
_rlnSchemeJobName #2 
_rlnSchemeJobMode #3 
_rlnSchemeJobHasStarted #4 
Job001_Import Job001_Import        new            0 
Job002_MotionCorr Job002_MotionCorr        new            0 
Job003_CtfFind Job003_CtfFind        new            0 
Job005_Select_micr Job005_Select_micr        new            0 
Job006_AutoPick_LoGPick Job006_AutoPick_LoGPick        new            0 
Job007_Extract_LoGPick Job007_Extract_LoGPick        new            0 
Job008_Class2D_for_ref Job008_Class2D_for_ref        new            0 
Job009_Select_for_2Dref Job009_Select_for_2Dref        new            0 
Job010_AutoPick_Topaz_train Job010_AutoPick_Topaz_train        new            0 
Job011_AutoPick_TopazPick Job011_AutoPick_TopazPick        new            0 
Job012_Extract_TopazPick Job012_Extract_TopazPick        new            0
Job013_Class2D Job013_Class2D        new            0
Job014_Select_part Job014_Select_part        new            0 
Job015_InitialModel Job015_InitialModel        new            0 
Job016_Class3D Job016_Class3D        new            0 
Job017_Select_class3D Job017_Select_class3D        new            0 
Job018_Extract_reextract Job018_Extract_reextract        new            0 
Job019_Refine3D_first Job019_Refine3D_first        new            0 
Job020_MaskCreate Job020_MaskCreate        new            0 
Job021_PostProcess_first Job021_PostProcess_first        new            0 
Job022_CtfRefine_trefoil Job022_CtfRefine_trefoil        new            0 
Job023_CtfRefine_magnification Job023_CtfRefine_magnification        new            0 
Job024_CtfRefine_CTF_parameter Job024_CtfRefine_CTF_parameter        new            0 
Job025_Refine3D_FirstCTFcycle Job025_Refine3D_FirstCTFcycle        new            0 
Job026_PostProcess_FirstCTFcycle Job026_PostProcess_FirstCTFcycle        new            0 
Job028_Polish Job028_Polish        new            0 
Job029_Refine3D_FirstPolishcycle Job029_Refine3D_FirstPolishcycle        new            0 
Job030_PostProcess_FirstPolishcycle Job030_PostProcess_FirstPolishcycle        new            0 
Job031_LocalRes Job031_LocalRes        new            0 
Job032_External_cryolo Job032_External_cryolo        new            0 


# version 30001

data_scheme_edges

loop_ 
_rlnSchemeEdgeInputNodeName #1 
_rlnSchemeEdgeOutputNodeName #2 
_rlnSchemeEdgeIsFork #3 
_rlnSchemeEdgeOutputNodeNameIfTrue #4 
_rlnSchemeEdgeBooleanVariable #5 
Job001_Import Job002_MotionCorr            0  undefined  undefined 
Job002_MotionCorr Job003_CtfFind            0  undefined  undefined 
Job003_CtfFind   Job005_Select_micr            0  undefined  undefined 
Job005_Select_micr   Job006_AutoPick_LoGPick   0  undefined  undefined
Job006_AutoPick_LoGPick   Job007_Extract_LoGPick   0  undefined  undefined
Job007_Extract_LoGPick   Job008_Class2D_for_ref   0  undefined  undefined
Job008_Class2D_for_ref   Job009_Select_for_2Dref   0  undefined  undefined
Job009_Select_for_2Dref   Job010_AutoPick_Topaz_train   0  undefined  undefined
Job010_AutoPick_Topaz_train   Job011_AutoPick_TopazPick   0  undefined  undefined
Job011_AutoPick_TopazPick   Job012_Extract_TopazPick   0  undefined  undefined
Job012_Extract_TopazPick   Job013_Class2D   0  undefined  undefined
Job013_Class2D   Job014_Select_part   0  undefined  undefined
Job014_Select_part   Job015_InitialModel   0  undefined  undefined
Job015_InitialModel   Job016_Class3D   0  undefined  undefined
Job016_Class3D    Job018_Extract_reextract   0  undefined  undefined
Job018_Extract_reextract   Job019_Refine3D_first   0  undefined  undefined
Job019_Refine3D_first   Job020_MaskCreate   0  undefined  undefined
Job020_MaskCreate   Job021_PostProcess_first   0  undefined  undefined
Job021_PostProcess_first   Job022_CtfRefine_trefoil   0  undefined  undefined
Job022_CtfRefine_trefoil   Job023_CtfRefine_magnification   0  undefined  undefined
Job023_CtfRefine_magnification   Job024_CtfRefine_CTF_parameter   0  undefined  undefined
Job024_CtfRefine_CTF_parameter   Job025_Refine3D_FirstCTFcycle   0  undefined  undefined
Job025_Refine3D_FirstCTFcycle   Job026_PostProcess_FirstCTFcycle   0  undefined  undefined
Job026_PostProcess_FirstCTFcycle   Job028_Polish   0  undefined  undefined
Job028_Polish   Job029_Refine3D_FirstPolishcycle   0  undefined  undefined
Job029_Refine3D_FirstPolishcycle   Job030_PostProcess_FirstPolishcycle   0  undefined  undefined
Job030_PostProcess_FirstPolishcycle   Job031_LocalRes   0  undefined  undefined
Job031_LocalRes   Job032_External_cryolo   0  undefined  undefined
Job032_External_cryolo   EXIT   0  undefined  undefined
