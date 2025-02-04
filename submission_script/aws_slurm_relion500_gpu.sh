#!/bin/bash
#SBATCH --ntasks=XXXmpinodesXXX
#SBATCH --exclusive
#SBATCH --partition=XXXextra1XXX
#SBATCH --nodes=XXXextra2XXX
#SBATCH --error=XXXerrfileXXX
#SBATCH --output=XXXoutfileXXX
#SBATCH --job-name=XXXqueueXXX

echo "---- machinefile ----"
NODEFILE=$(generate_pbs_nodefile) && cat ${NODEFILE}

echo "---- intelmpi ----"
#module purge
#module load intelmpi

export I_MPI_PIN_DOMAIN=socket

echo "---- openmp ----"
export OMP_NUM_THREADS=XXXthreadsXXX

cat <<ETX

---- SLURM OUTPUT ENVIRONMENT VARIABLES ----
JOB_START_TIME="${SLURM_JOB_START_TIME}"
JOB_ID="${SLURM_JOB_ID}"
JOB_NAME="${SLURM_JOB_NAME}"
PARTITION_NAME="${SLURM_JOB_PARTITION}"
NODE_LIST="${SLURM_JOB_NODELIST}"
NODEFILE="${NODEFILE}"
NTASKS="${SLURM_NTASKS}"
JOB_NUM_NODES="${SLURM_JOB_NUM_NODES}"
CPUS_PER_GPU="${SLURM_CPUS_PER_GPU}"
CPUS_PER_TASK="${SLURM_CPUS_PER_TASK}"
NTASKS_PER_NODE="${SLURM_NTASKS_PER_NODE}"

---- INTEL MPI ENVIRONMENT VARIABLES ----
I_MPI_PIN_DOMAIN = "${I_MPI_PIN_DOMAIN}"

---- OPENMP ENVIRONMENT VARIABLES ----
OMP_NUM_THREADS = "${OMP_NUM_THREADS}"

ETX

echo "---- Hello Relion ----"
#module load relion/5.0-beta-pc3.7.0/intel_amd-gcc-intelmpi-gpu
if which relion > /dev/null 2>&1; then
    relion_version=$(relion --version | sed -nE 's/^RELION version: (\S*).*$/\1/p')
    module -v purge
    case ${relion_version} in
        "5.0.0-commit-4e57a4")
            TOKEN=$(curl --silent -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600") \
            && instance_type=$(curl --silent -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-type)
            case ${instance_type%%.*} in
                "g6")
                    module -v load relion/5.0.0-4e57a4d/gcc-intelmpi-gpu-cudaarch89;;
                "g5")
                    module -v load relion/5.0.0-4e57a4d/gcc-intelmpi-gpu-cudaarch86;;
                "g4dn")
                    module -v load relion/5.0.0-4e57a4d/gcc-intelmpi-gpu-cudaarch75;;
                *)
                    echo "undefined instance_type ${instance_type}"
                    echo "performing \"module load relion/5.0.0-4e57a4d/gcc-intelmpi-gpu-cudaarch75\" instead"
                    module -v load relion/5.0.0-4e57a4d/gcc-intelmpi-gpu-cudaarch75;;
            esac ;;
        "5.0-beta-0-commit-832d07")
            module -v load relion/5.0-beta-pc3.7.0/intel_amd-gcc-intelmpi-gpu;;
        "4.0.1-commit-7809a7")
            module -v load relion/4.0.1-pc3.7.0/intel_amd-gcc-intelmpi-gpu;;
        *)
            echo "undefined relion version ${relion_version}"
            echo "performing \"module load relion\" instead"
            module -v load relion;;
    esac
else
    module -v purge
    echo "assuming relion version failed"
    echo "performing \"module load relion\" instead"
    module -v load relion
fi

module list
which relion
env time -V
echo "I_MPI_PIN_DOMAIN: "$I_MPI_PIN_DOMAIN

STARTTIME=`date -u +%s`
echo "Started (Unix time): $STARTTIME"

env time mpirun -n ${SLURM_NTASKS} -machinefile ${NODEFILE} XXXcommandXXX

ENDTIME=`date -u +%s`
echo "Ended (Unix time): $ENDTIME"
echo "Elapsed (Unix time): `echo $ENDTIME - $STARTTIME | bc`"

