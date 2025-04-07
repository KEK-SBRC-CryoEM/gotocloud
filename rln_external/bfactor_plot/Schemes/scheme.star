data_scheme_general
_rlnSchemeName                Schemes/BFactor_Plot
_rlnSchemeCurrentNodeName     WAIT

# ---------------------------
# Numeric (float) parameters
# ---------------------------
data_scheme_floats
loop_
_rlnSchemeFloatVariableName         #1
_rlnSchemeFloatVariableValue        #2
_rlnSchemeFloatVariableResetValue   #3
cs_minimum_nr_particles    225        225
cs_maximum_nr_particles    7200       7200
wait_sec                180        180 
maxtime_hr              96         96 

# ---------------------------
# Define string variables
# ---------------------------
data_scheme_strings
loop_
_rlnSchemeStringVariableName         #1
_rlnSchemeStringVariableValue        #2
_rlnSchemeStringVariableResetValue   #3
cs_parameter_file          ./bfactor_plot/config/bfactor.yaml ./bfactor_plot/config/bfactor.yaml
cs_input_refine3d_job      ./Refine3D/job043/                 ./Refine3D/job043/
cs_input_postprocess_job   ./PostProcess/job054/              ./PostProcess/job054/

# ---------------------------
# Operators
# ---------------------------
data_scheme_operators
loop_
_rlnSchemeOperatorName         #1
_rlnSchemeOperatorType         #2
_rlnSchemeOperatorOutput       #3
_rlnSchemeOperatorInput1       #4
_rlnSchemeOperatorInput2       #5
WAIT             wait            undefined       wait_sec         undefined
EXIT             exit            undefined       undefined        undefined
EXIT_maxtime     exit_maxtime    undefined       maxtime_hr       undefined 

# ---------------------------
# Define jobs
# ---------------------------
data_scheme_jobs
loop_
_rlnSchemeJobNameOriginal    #1
_rlnSchemeJobName            #2
_rlnSchemeJobMode            #3
_rlnSchemeJobHasStarted      #4
BFactor_Plot                 BFactor_Plot           new    0

# ---------------------------
# Define edges to connect the nodes in your workflow
# ---------------------------
data_scheme_edges
loop_
_rlnSchemeEdgeInputNodeName      #1
_rlnSchemeEdgeOutputNodeName     #2
_rlnSchemeEdgeIsFork             #3
_rlnSchemeEdgeOutputNodeNameIfTrue  #4
_rlnSchemeEdgeBooleanVariable    #5
WAIT                      EXIT_maxtime  0     undefined     undefined
EXIT_maxtime              BFactor_Plot  0     undefined     undefined
BFactor_Plot              WAIT          1     EXIT          undefined
