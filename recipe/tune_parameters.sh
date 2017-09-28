#!/bin/bash

if [ ! -d logs ]
then
  mkdir logs
fi

NOTIFY=0
for arg in "$@"
do
  case $arg in
    --notify*)
        NOTIFY=1
        shift
        ;;

    *)
      shift
      ;;
  esac
done

logfile="logs/tune_parameters_`date +%Y-%m-%d-%T`.log"
run_log_prefix="/tmp/tune_parameters"

scale_opts="--transition-scale=1.0 --acoustic-scale=0.1 --self-loop-scale=0.1"
num_iters=`seq 14 14`
max_iter_inc=`seq 7 7`
totgauss=`seq 800 800`


mv steps/train_mono.sh steps/train_mono.sh.bak
for tScale in `seq 0.1 0.1 1.0`; do
  for aScale in `seq 0.01 0.01 0.1`; do
    for slScale in `seq 0.01 0.01 0.1`; do
      for iteration in $num_iters; do
        for iteration_increment in $max_iter_inc; do
          for gauss in $totgauss; do
            echo -e "---------- START ----------" >> $logfile
            scale_opts="--transition-scale=$tScale --acoustic-scale=$aScale --self-loop-scale=$slScale"
            echo -e "scale_opts=\"$scale_opts\""
            echo -e "scale_opts=\"$scale_opts\"" >> $logfile
            echo -e "num_iters=$iteration"
            echo -e "num_iters=$iteration" >> $logfile
            echo -e "max_iter_inc=$iteration_increment"
            echo -e "max_iter_inc=$iteration_increment" >> $logfile
            echo -e "totgauss=$gauss"
            echo -e "totgauss=$gauss" >> $logfile

            sed "s/scale_opts=.*/scale_opts=\"$scale_opts\"/g" steps/train_mono.sh.bak | \
            sed "s/num_iters=[0-9]*/num_iters=$iteration/g" | \
            sed "s/max_iter_inc=[0-9]*/max_iter_inc=$iteration_increment/g" | \
            sed "s/totgauss=[0-9]*/totgauss=$gauss/g" > steps/train_mono.sh

            chmod +x steps/train_mono.sh

            run_log=${run_log_prefix}_${iteration}_${iteration_increment}_${gauss}.log

            start_time=`date +%s`
            ./run.sh > $run_log 2> /dev/null
            end_time=`date +%s`

            tail -n1 $run_log | cut -d' ' -f1,2
            tail -n1 $run_log >> $logfile

            time_taken=`expr $end_time - $start_time`
            echo -e "Time Taken = $time_taken secs"
            echo -e "Time Taken = $time_taken secs" >> $logfile
            echo -e "----------- END -----------\n" >> $logfile

            echo "----------"
          done
        done
      done
    done
  done
done
mv steps/train_mono.sh.bak steps/train_mono.sh

if [ $NOTIFY == 1 ] &&  [ -f notify.sh ]; then
  ./notify.sh $logfile
fi
