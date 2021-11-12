#!/bin/bash
#
#
function gtc_rerion_tutorial() {
        cd /fsx
        cp /efs/em/relion30_tutorial_data.tar /fsx
        cp /efs/em/relion31_tutorial_precalculated_results.tar.gz /fsx
        tar -xf /fsx/relion30_tutorial_data.tar -C /fsx
        tar -zxf /fsx/relion31_tutorial_precalculated_results.tar.gz -C /fsx
        mv /fsx/relion30_tutorial /fsx/relion31_tutorial
        mv /fsx/PrecalculatedResults/* /fsx/relion31_tutorial
        rm /fsx/relion30_tutorial_data.tar
        rm /fsx/relion31_tutorial_precalculated_results.tar.gz
        rm -r /fsx/PrecalculatedResults/
}

# check if /fsx/relion31_tutorial/ exists.
GTC_RELION_DIR="/fsx/relion31_tutorial/"
if [ -d $GTC_RELION_DIR ]; then
        echo "GoToCloud: Relion tutorial is already set up"
        echo "GoToCloud: If you redo the setup, remove ${GTC_RELION_DIR}"
        echo "GoToCloud:   rm -r ${GTC_RELION_DIR} "
        echo "GoToCloud: And then run gtc_setup_relion_tutorial.sh"
        echo "GoToCloud: Exiting(0)..."
        exit 0
fi

echo "GoToCloud: Setting up Relion tutorial..."
gtc_rerion_tutorial &  #Excute in background
pid=$!  #Process ID
#echo "pid=${pid}"
GTC_STATUS_CHECK_INTERVAL=10 # in seconds
GTC_TIME_OUT=600 # in seconds
t0=`date +%s` # in seconds
while :
do
        sleep ${GTC_STATUS_CHECK_INTERVAL}
        # Check if process is completed.
        echo "GoToCloud: SETUP_IN_PROGRESS"
        ps ${pid} > /dev/null || {
            break
        }
        #sleep ${GTC_STATUS_CHECK_INTERVAL} 
        t1=`date +%s` # in seconds
        if [ $((t1-t0)) -gt ${GTC_TIME_OUT} ]; then
                echo "GoToCloud: [GCT_ERROR] GTC_TIME_OUT ${GTC_TIME_OUT} seconds"
                echo "GoToCloud: Exiting(1)..."
                exit 1
        fi
done



GTC_STATUS_CHECK_INTERVAL=10 # in seconds
GTC_TIME_OUT=600 # in seconds
# echo "GoToCloud: Exporting (archiving) data from Lustre to S3 bucket..."
# Request to export data from Lustre parallel file system (/fsx) to S3 bucket
nohup find /fsx -type f -print0 | xargs -0 -n 1 sudo lfs hsm_archive &
t0=`date +%s` # in seconds
while :
do
        sleep ${GTC_STATUS_CHECK_INTERVAL} 
        # Check if exporting (archiving) is completed.
        # It is done when output becomes "0", 
        GTC_EXIT_STATUS=`find /fsx -type f -print0 | xargs -0 -n 1 -P 8 sudo lfs hsm_action | grep 'ARCHIVE' | wc -l`
        # echo "GoToCloud: ${GCT_EXIT_STATUS}"
        if [ ${GTC_EXIT_STATUS} -eq 0 ]; then
                #echo "GoToCloud: Exporting (archiving) is completed."
                break
        else
                echo "GoToCloud: SETUP_IN_PROGRESS"
        fi

        t1=`date +%s` # in seconds
        if [ $((t1-t0)) -gt ${GTC_TIME_OUT} ]; then
                echo "GoToCloud: [GCT_ERROR] GTC_TIME_OUT ${GTC_TIME_OUT} seconds"
                echo "GoToCloud: Last output of status command:"
                echo "GoToCloud: ${GCT_EXIT_STATUS}"
                echo "GoToCloud: Exiting(1)..."
                exit 1
        fi
done

echo "GoToCloud: Relion tutorial is set up on"
echo "GoToCloud:   ${GTC_RELION_DIR}"
echo "GoToCloud: Done"
