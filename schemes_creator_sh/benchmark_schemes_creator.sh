#!/bin/bash
#
# Usage:
#   benchmark_schemes_create.sh
#   
# Arguments & Options:
#   none
#   
# Examples:
#   $ ./benchmark_schemes_create.sh
#
#
usage_exit() {
        echo "GoToCloud: Usage $0" 1>&2
        echo "GoToCloud: Exiting(1)..."
        exit 1
}
# Check if the number of command line arguments is valid
if [[ $# -gt 4 ]]; then
    echo "Invalid number of arguments ($#)"
    usage_exit
fi
# Parse command line arguments
while getopts h OPT
do
    case "$OPT" in
        h)  usage_exit
            ;;
        \?) echo "Invalid option $OPTARG is specified!"
            usage_exit
            ;;
    esac
done

function awk() {
    command awk -v FPAT='[^[:space:]]+|\"[^\"]*\"' "$@"
}

function job_star_create_for_each_instance() {
    #Create job directory and job.star
    SCHEME_JOB_NAME1=$1
    SCHEME_JOB_NAME2=$2
    SCHEME_JOB_NAME3=$3
    # Relion parameter Setting file
    SETTING_FILE=${SCRIPT_DIR}/setting_file.txt    # used in SCHEME_JOB_NAME1, SCHEME_JOB_NAME2, SCHEME_JOB_NAME3
    SETTING_FILE_PL=${SCRIPT_DIR}/setting_file_polish.txt       # used in Polish
    NR_SETTINGS=$(cat ${SETTING_FILE} | awk '! /^#/' | awk 'NF' | awk 'END{print NR}')
    count=()
    for jobname in ${SCHEME_JOB_NAME1} ${SCHEME_JOB_NAME2} ${SCHEME_JOB_NAME3}
    do
        JOB_STAR_TEMPLATE=${SCRIPT_DIR}/template_${jobname}_job.star
        if [ $jobname == "Polish" ]; then
            NR_SETTINGS=$(cat ${SETTING_FILE_PL} | awk '! /^#/' | awk 'NF' | awk 'END{print NR}')
        else
            NR_SETTINGS=$(cat ${SETTING_FILE} | awk '! /^#/' | awk 'NF' | awk 'END{print NR}')
        fi
        for ((no=1;no<=${NR_SETTINGS};no++))
        do
            JOB_STAR_TEMPLATE=${SCRIPT_DIR}/template_${jobname}_job.star
            count+=($((${#count[@]}+1)))
            LAST_NUMBER=${count[${#count[@]}-1]}
            JOB_NO=$(printf "%03d\n" "${LAST_NUMBER}")
            SCHEMES_JOB_DIR=${SCHEMES_PRO_DIR}/${JOB_NO}_${jobname}_${no}
            mkdir ${SCHEMES_JOB_DIR}
            SCHEMES_JOB_STAR=${SCHEMES_JOB_DIR}/job.star
            cp ${JOB_STAR_TEMPLATE} ${SCHEMES_JOB_STAR}
            if [ $jobname == "Polish" ]; then
                NUMBER_OF_NODES=$(cat ${SETTING_FILE_PL} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $1}')
                NUMBER_OF_MPI=$(cat ${SETTING_FILE_PL} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $2}')
                NUMBER_OF_THREADS=$(cat ${SETTING_FILE_PL} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $3}')
                MINIMUM_DEDICATED=$(cat ${SETTING_FILE_PL} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $4}')
                PARTITION=$(cat ${SETTING_FILE_PL} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $5}')
                SUBMIT_COMMAND=$(cat ${SETTING_FILE_PL} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $6}')
                SUBMIT_SCRIPT=$(cat ${SETTING_FILE_PL} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $7}')
                ADDITIONAL_ARGS=$(cat ${SETTING_FILE_PL} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $8}')
                sed -i "s@XXX_NUMBER_OF_NODES_XXX@${NUMBER_OF_NODES}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_NUMBER_OF_MPI_XXX@${NUMBER_OF_MPI}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_NUMBER_OF_THREADS_XXX@${NUMBER_OF_THREADS}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_MINIMUM_DEDICATED_XXX@${MINIMUM_DEDICATED}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_PARTITION_XXX@${PARTITION}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_SUBMIT_COMMAND_XXX@${SUBMIT_COMMAND}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_SUBMIT_SCRIPT_XXX@${SUBMIT_SCRIPT}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_ADDITIONAL_ARGS_XXX@${ADDITIONAL_ARGS}@g" ${SCHEMES_JOB_STAR}
            else
                PREREAD_IMAGES=$(cat ${SETTING_FILE} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $1}')
                SCRATCH_DIR=$(cat ${SETTING_FILE} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $2}')
                USE_GPU=$(cat ${SETTING_FILE} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $3}')
                GPU_IDS=$(cat ${SETTING_FILE} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $4}')
                NUMBER_OF_NODES=$(cat ${SETTING_FILE} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $5}')
                NUMBER_OF_MPI=$(cat ${SETTING_FILE} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $6}')
                NUMBER_OF_THREADS=$(cat ${SETTING_FILE} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $7}')
                MINIMUM_DEDICATED=$(cat ${SETTING_FILE} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $8}')
                PARTITION=$(cat ${SETTING_FILE} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $9}')
                NR_POOL=$(cat ${SETTING_FILE} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $10}')
                SUBMIT_COMMAND=$(cat ${SETTING_FILE} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $11}')
                SUBMIT_SCRIPT=$(cat ${SETTING_FILE} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $12}')
                ADDITIONAL_ARGS=$(cat ${SETTING_FILE} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $13}')
                sed -i "s@XXX_PREREAD_IMAGES_XXX@${PREREAD_IMAGES}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_SCRATCH_DIR_XXX@${SCRATCH_DIR}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_USE_GPU_XXX@${USE_GPU}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_GPU_IDS_XXX@${GPU_IDS}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_NUMBER_OF_NODES_XXX@${NUMBER_OF_NODES}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_NUMBER_OF_MPI_XXX@${NUMBER_OF_MPI}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_NUMBER_OF_THREADS_XXX@${NUMBER_OF_THREADS}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_MINIMUM_DEDICATED_XXX@${MINIMUM_DEDICATED}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_NR_POOL_XXX@${NR_POOL}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_PARTITION_XXX@${PARTITION}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_SUBMIT_COMMAND_XXX@${SUBMIT_COMMAND}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_SUBMIT_SCRIPT_XXX@${SUBMIT_SCRIPT}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_ADDITIONAL_ARGS_XXX@${ADDITIONAL_ARGS}@g" ${SCHEMES_JOB_STAR}
            fi
        done
    done
}

function job_star_create_for_each_job() {
    #Create job directory and job.star
    SCHEME_JOB_NAME1=$1
    SCHEME_JOB_NAME2=$2
    SCHEME_JOB_NAME3=$3
    SCHEME_JOB_NAME4=$4
    # Relion parameter Setting file
    SETTING_FILE=${SCRIPT_DIR}/setting_file.txt    # used in SCHEME_JOB_NAME1, SCHEME_JOB_NAME2, SCHEME_JOB_NAME3
    SETTING_FILE_PL=${SCRIPT_DIR}/setting_file_polish.txt       # used in Polish
    count=()
    for jobname in ${SCHEME_JOB_NAME1} ${SCHEME_JOB_NAME2} ${SCHEME_JOB_NAME3} ${SCHEME_JOB_NAME4}
    do
        JOB_STAR_TEMPLATE=${SCRIPT_DIR}/template_${jobname}_job.star
        if [ $jobname == "Polish" ]; then
            NR_SETTINGS=$(cat ${SETTING_FILE_PL} | awk '! /^#/' | awk 'NF' | awk 'END{print NR}')
        else
            NR_SETTINGS=$(cat ${SETTING_FILE} | awk '! /^#/' | awk 'NF' | awk 'END{print NR}')
        fi
        for ((no=1;no<=${NR_SETTINGS};no++))
        do
            count+=($((${#count[@]}+1)))
            LAST_NUMBER=${count[${#count[@]}-1]}
            JOB_NO=$(printf "%03d\n" "${LAST_NUMBER}")
            SCHEMES_JOB_DIR=${SCHEMES_PRO_DIR}/${JOB_NO}_${jobname}_${no}
            mkdir ${SCHEMES_JOB_DIR}
            SCHEMES_JOB_STAR=${SCHEMES_JOB_DIR}/job.star
            cp ${JOB_STAR_TEMPLATE} ${SCHEMES_JOB_STAR}
            if [ $jobname == "Polish" ]; then
                NUMBER_OF_MPI=$(cat ${SETTING_FILE_PL} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $1}')
                NUMBER_OF_THREADS=$(cat ${SETTING_FILE_PL} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $2}')
                MINIMUM_DEDICATED=$(cat ${SETTING_FILE_PL} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $3}')
                PARTITION=$(cat ${SETTING_FILE_PL} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $4}')
                SUBMIT_COMMAND=$(cat ${SETTING_FILE_PL} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $5}')
                SUBMIT_SCRIPT=$(cat ${SETTING_FILE_PL} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $6}')
                ADDITIONAL_ARGS=$(cat ${SETTING_FILE_PL} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $7}')
                sed -i "s@XXX_NUMBER_OF_MPI_XXX@${NUMBER_OF_MPI}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_NUMBER_OF_THREADS_XXX@${NUMBER_OF_THREADS}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_MINIMUM_DEDICATED_XXX@${MINIMUM_DEDICATED}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_PARTITION_XXX@${PARTITION}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_SUBMIT_COMMAND_XXX@${SUBMIT_COMMAND}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_SUBMIT_SCRIPT_XXX@${SUBMIT_SCRIPT}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_ADDITIONAL_ARGS_XXX@${ADDITIONAL_ARGS}@g" ${SCHEMES_JOB_STAR}
            else
                PREREAD_IMAGES=$(cat ${SETTING_FILE} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $1}')
                SCRATCH_DIR=$(cat ${SETTING_FILE} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $2}')
                USE_GPU=$(cat ${SETTING_FILE} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $3}')
                GPU_IDS=$(cat ${SETTING_FILE} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $4}')
                NUMBER_OF_MPI=$(cat ${SETTING_FILE} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $5}')
                NUMBER_OF_THREADS=$(cat ${SETTING_FILE} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $6}')
                MINIMUM_DEDICATED=$(cat ${SETTING_FILE} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $7}')
                PARTITION=$(cat ${SETTING_FILE} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $8}')
                SUBMIT_COMMAND=$(cat ${SETTING_FILE} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $9}')
                SUBMIT_SCRIPT=$(cat ${SETTING_FILE} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $10}')
                ADDITIONAL_ARGS=$(cat ${SETTING_FILE} | awk '! /^#/' | awk 'NF' | awk 'NR == '$no' {print $11}')
                sed -i "s@XXX_PREREAD_IMAGES_XXX@${PREREAD_IMAGES}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_SCRATCH_DIR_XXX@${SCRATCH_DIR}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_USE_GPU_XXX@${USE_GPU}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_GPU_IDS_XXX@${GPU_IDS}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_NUMBER_OF_MPI_XXX@${NUMBER_OF_MPI}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_NUMBER_OF_THREADS_XXX@${NUMBER_OF_THREADS}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_MINIMUM_DEDICATED_XXX@${MINIMUM_DEDICATED}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_PARTITION_XXX@${PARTITION}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_SUBMIT_COMMAND_XXX@${SUBMIT_COMMAND}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_SUBMIT_SCRIPT_XXX@${SUBMIT_SCRIPT}@g" ${SCHEMES_JOB_STAR}
                sed -i "s@XXX_ADDITIONAL_ARGS_XXX@${ADDITIONAL_ARGS}@g" ${SCHEMES_JOB_STAR}

            fi
        done
    done
}

function scheme_star_create() {
    SCHEMES_STAR_TEMPLATE=${SCRIPT_DIR}/template_scheme.star
    SCHEMES_STAR=${SCHEMES_PRO_DIR}/scheme.star
    cp ${SCHEMES_STAR_TEMPLATE} ${SCHEMES_STAR}

    SCHEMES_JOB_DIRS="${SCHEMES_PRO_DIR}/*"
    pro_dirs=`find $SCHEMES_JOB_DIRS -maxdepth 0 -type d`
    dir_ary=()
    for pro_dir in $pro_dirs;
    do
        SCHEMES_JOB_DIR_NAME=`echo $pro_dir | awk -F "[/]" '{print $NF}'`
        dir_ary+=("${SCHEMES_JOB_DIR_NAME}")
    done

    NUMBER_DIR_ARY=`echo "${#dir_ary[*]}"`

    for ((i=1;i<=${NUMBER_DIR_ARY};i++))
    do
        if [ $i -eq ${NUMBER_DIR_ARY} ]; then
            SCHEMES_RN_JOBS=$(sed -n '/_rlnSchemeJobHasStarted/=' ${SCHEMES_STAR})
            SCHEMES_RN_EDGES=$(sed -n '/_rlnSchemeEdgeBooleanVariable/=' ${SCHEMES_STAR})
            INSERT_STRINGS_JOBS="${dir_ary[i-1]}  ${dir_ary[i-1]}     new     0"
            INSERT_STRINGS_EDGES="${dir_ary[i-1]}  EXIT     0     undefined     undefined"
            sed -i "$((${SCHEMES_RN_JOBS}+$i))i ${INSERT_STRINGS_JOBS}" ${SCHEMES_STAR}
            sed -i "$((${SCHEMES_RN_EDGES}+$i))a ${INSERT_STRINGS_EDGES}" ${SCHEMES_STAR}
        else
            SCHEMES_RN_JOBS=$(sed -n '/_rlnSchemeJobHasStarted/=' ${SCHEMES_STAR})
            SCHEMES_RN_EDGES=$(sed -n '/_rlnSchemeEdgeBooleanVariable/=' ${SCHEMES_STAR})
            INSERT_STRINGS_JOBS="${dir_ary[i-1]}  ${dir_ary[i-1]}     new     0"
            INSERT_STRINGS_EDGES="${dir_ary[i-1]}  ${dir_ary[i]}     0     undefined     undefined"
            sed -i "$((${SCHEMES_RN_JOBS}+$i))i ${INSERT_STRINGS_JOBS}" ${SCHEMES_STAR}
            sed -i "$((${SCHEMES_RN_EDGES}+$i))a ${INSERT_STRINGS_EDGES}" ${SCHEMES_STAR}
        fi
    done
    CURRENT_NODE_NAME=${dir_ary[0]}
    sed -i "s@XXX_SCHEMES_NAME_XXX@${SCHEMES_NAME}@g" ${SCHEMES_STAR}
    sed -i "s@XXX_CURRENT_NODE_NAME_XXX@${CURRENT_NODE_NAME}@g" ${SCHEMES_STAR}
}


# Create Schemes directory
SCRIPT_DIR=$(cd $(dirname $0); pwd)
RELION_PROJECT_DIR=`pwd`
SCHEMES_DIR_NAME="Schemes"
SCHEMES_PRO_DIR_NAME="relion_benchmark_181122_Iba4_V3o1"
SCHEMES_NAME="${SCHEMES_DIR_NAME}/${SCHEMES_PRO_DIR_NAME}/"

SCHEMES_DIR=${RELION_PROJECT_DIR}/${SCHEMES_DIR_NAME}
SCHEMES_PRO_DIR=${SCHEMES_DIR}/${SCHEMES_PRO_DIR_NAME}
if [ -e ${SCHEMES_DIR} ]; then
    echo "Schemes directory exists."
    echo "Exiting(1)... "
    exit 1
else
    mkdir ${SCHEMES_DIR}
    mkdir ${SCHEMES_PRO_DIR}
fi
#Create job directory and job.star
job_star_create_for_each_instance $1 $2 $3
# Create schemes.star
scheme_star_create
