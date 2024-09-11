#!/bin/bash
#SBATCH --ntasks=XXXmpinodesXXX
#SBATCH --ntasks-per-node=XXXdedicatedXXX
#SBATCH --partition=XXXextra1XXX
#SBATCH --cpus-per-task=XXXthreadsXXX
#SBATCH --error=XXXerrfileXXX
#SBATCH --output=XXXoutfileXXX
#SBATCH --job-name=XXXqueueXXX

echo "---- machinefile ----"
NODEFILE=$(generate_pbs_nodefile) && cat ${NODEFILE}

cat <<ETX

---- INPUT ENVIRONMENT VARIABLES ----
JOB_ID="${SLURM_JOB_ID}"
JOB_NAME="${SLURM_JOB_NAME}"
PARTITION_NAME="${SLURM_JOB_PARTITION}"
NODE_LIST="${SLURM_JOB_NODELIST}"
NODEFILE="${NODEFILE}"
NTASKS="${SLURM_NTASKS}"

ETX

echo "---- Hello Relion ----"
module load intelmpi
module list
env time -V

STARTTIME=`date -u +%s`
echo "Started (Unix time): $STARTTIME"

env time mpirun -n ${SLURM_NTASKS} -machinefile ${NODEFILE} XXXcommandXXX

ENDTIME=`date -u +%s`
echo "Ended (Unix time): $ENDTIME"
echo "Elapsed (Unix time): `echo $ENDTIME - $STARTTIME | bc`"
