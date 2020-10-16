#!/bin/bash

time_save_path=/tmp/timer.time
if [ -f $time_save_path ]; then
  seconds_left=$(($(cat $time_save_path) - $(date +%s)))
else
  seconds_left=-1
fi
blink_state=1
increment=$1

if [ -z $increment ]; then
  increment=300
fi

if [ -L $0 ] ; then
    DIR=$(dirname $(readlink -f $0)) ;
else
    DIR=$(dirname $0) ;
fi ;
ping_path="$DIR/ping.wav"

update_time () {
  echo $(($(date +%s) + seconds_left)) > $time_save_path
}

trap "((seconds_left+=increment)) && update_time" USR1
trap "((seconds_left-=increment)) && update_time" USR2

echo $$
while true; do
  if [ $seconds_left -gt 0 ]; then
    tmp=$seconds_left
    s=$((tmp%60))
    tmp=$((tmp/60))
    if [ $tmp -gt 0 ]; then
      m=$((tmp%60))
      tmp=$((tmp/60))
      if [ $tmp -gt 0 ]; then
        printf "%d:%02d:%02d\n" $tmp $m $s
      else
        printf "%d:%02d\n" $m $s
      fi
    else
      echo "$s"
    fi
    ((seconds_left--))
  elif [ $seconds_left -eq 0 ]; then
    if [ $blink_state -eq 1 ]; then
      echo "%{R}Time up!%{R}"
    else
      echo "Time up!"
    fi
    aplay $ping_path -q &
    ((blink_state=-blink_state))
  else
    echo ""
    seconds_left=-1
  fi
  sleep 1 &
  wait
done
