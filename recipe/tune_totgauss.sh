#!/bin/bash

if [ ! -d logs ]
then
  mkdir logs
fi

logfile="logs/totgauss_`date +%Y-%m-%d-%T`.log"
run_log_prefix="/tmp/tune_totgauss"

mv steps/train_mono.sh steps/train_mono.bak
for gauss in `seq 100 50 1000`
do
  echo -e "---------- START $gauss ----------" >> $logfile
  echo -e "totgauss = $gauss"
  echo -e "totgauss = $gauss" >> $logfile

  sed 's/totgauss=[0-9]*/totgauss='$gauss'/g' steps/train_mono.sh.bak > steps/train_mono.sh
  chmod +x steps/train_mono.sh

  run_log=${run_log_prefix}_${gauss}.log

  start_time=`date +%s`
  ./run.sh > $run_log 2> /dev/null
  end_time=`date +%s`


  tail -n1 $run_log | cut -d' ' -f1,2
  tail -n1 $run_log >> $logfile

  time_taken=`expr $end_time - $start_time`
  echo -e "Time Taken = $time_taken secs"
  echo -e "Time Taken = $time_taken secs" >> $logfile
  echo -e "----------- END $iterations -----------\n" >> $logfile

  echo "----------"
done
mv steps/train_mono.sh.bak steps/train_mono.sh
