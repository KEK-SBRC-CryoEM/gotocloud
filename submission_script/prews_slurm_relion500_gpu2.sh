#!/bin/bash
#SBATCH -p gpu
#SBATCH --gres=gpu:2 # with 2 GPUs
#SBATCH --mem=240 # and half memory
#SBATCH --error=XXXerrfileXXX
#SBATCH --output=XXXoutfileXXX
#SBATCH --open-mode=append
#SBATCH --job-name=XXXqueueXXX
#SBATCH --partition=XXXextra1XXX
#SBATCH --nodes=XXXextra2XXX
#SBATCH --ntasks-per-node=XXXdedicatedXXX

# --- Backup Functions ---
backup_file () {
    local filepath="$1"
    local last_n=0 # backup suffix
    
    # check suffix to determine backup number
    for bk in "${filepath}_bkup"[0-9]*; do
        if [[ -e "$bk" ]]; then
            local n_part="${bk##*_bkup}"
            if [[ "$n_part" =~ ^[0-9]+$ ]] && (( n_part > last_n )); then
                last_n=$n_part
            fi
        fi
    done

    local next_n=$(( last_n + 1 ))
    local dest="${filepath}_bkup${next_n}"

    cp -p "$filepath" "$dest"
    echo "Backed up: $(basename "$filepath") → $(basename "$dest")"

}
run_backup() {
    local basedir="$1"
    shift
    local files=("$@")

    for f in "${files[@]}"; do
        local fullpath="${basedir}/${f}"
        
        # if file exists, backup
        if [[ -f "$fullpath" ]]; then
            backup_file "$fullpath"
        fi
    done
}

BASEDIR=XXXnameXXX
FILES_TO_BACKUP=("default_pipeline.star" "job_pipeline.star" "job.star" "run_submit.script")
# --- End of Backup Functions ---

source /apps/setup.sh
module load relion/5.0

echo "=== RELION 5.0 job script ==="
echo ""
echo "relion_refine in `which relion_refine`"
echo "mpirun in `which mpirun`"
echo ""
run_backup "$BASEDIR" "${FILES_TO_BACKUP[@]}" # run backup
echo ""
STARTTIME=`date -u +%s`
echo "Started (Unix time): $STARTTIME."
echo

mpirun --oversubscribe --mca mtl psm2 --mca btl ^ofi -n XXXmpinodesXXX XXXcommandXXX

ENDTIME=`date -u +%s`
echo "Ended (Unix time): $ENDTIME."
echo "Elapsed (Unix time): `echo $ENDTIME - $STARTTIME | bc` seconds."