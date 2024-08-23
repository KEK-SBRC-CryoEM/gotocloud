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
module purge
module load relion/5.0-beta-pc3.7.0/intel-intel-intelmpi-cpu_xcore
module load intelmpi
module list
time mpirun -n ${SLURM_NTASKS} -machinefile ${NODEFILE} XXXcommandXXX
