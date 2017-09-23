#!/bin/bash

if [ ! -d logs ]
then
  mkdir logs
fi

logfile="logs/num_iters_`date +%Y-%m-%d-%T`.log"
run_log_prefix="/tmp/tune_num_iters"
for iterations in `seq 14 20`
do
  echo -e "---------- START $iterations ----------" >> $logfile
  echo -e "num_iters = $iterations"
  echo -e "num_iters = $iterations" >> $logfile

  sed 's/num_iters=10/num_iters='$iterations'/g' steps/train_mono.sh.bak > steps/train_mono.sh
  chmod +x steps/train_mono.sh

  run_log=${run_log_prefix}_${iterations}.log

  start_time=`date +%s`
  ./run.sh > $run_log
  end_time=`date +%s`


  tail -n1 $run_log | cut -d' ' -f1,2
  tail -n1 $run_log >> $logfile 2> /dev/null

  time_taken=`expr $end_time - $start_time`
  echo -e "Time Taken = $time_taken secs"
  echo -e "Time Taken = $time_taken secs" >> $logfile
  echo -e "----------- END $iterations -----------\n" >> $logfile

  echo "----------"
done
cp steps/train_mono.sh.bak steps/train_mono.sh
