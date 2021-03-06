#!/bin/bash
ACTION=$1
MAX_VOLUME=65536
STEP=8192 # 65536 = 100% volume
declare -i CURVOL=`cat ~/.volume` #Reads in the current volume
if [[ $ACTION == "reset" ]]; then
  CURVOL=$(echo "$MAX_VOLUME/2" | bc)
  echo $CURVOL > ~/.volume
  echo 0 > ~/.mute
  for i in 0 1 2 3 4 5 6; do
    pactl set-sink-mute $i 0
    pactl set-sink-volume $i $CURVOL
  done
fi

if [[ $ACTION == "increase" ]]; then
  for i in 0 1 2 3 4 5 6; do
    pactl set-sink-mute $i 0
  done
  echo 0 > ~/.mute
  CURVOL=$(($CURVOL + $STEP))
fi
if [[ $ACTION == "decrease" ]]; then
  CURVOL=$(($CURVOL - $STEP))
fi

if [[ $CURVOL -le $MAX_VOLUME && $CURVOL -ge 0 ]]; then
  for i in 0 1 2 3 4 5 6; do
    echo $i
    pactl set-sink-volume $i $CURVOL
  done
  echo $CURVOL > ~/.volume # Write the new volume to disk to be read the next time the script is run.
fi

if [[ $ACTION == "toggle" ]]; then
  if [[ `cat ~/.mute` -eq 1 ]]; then
    ACTION=unmute
  else
    ACTION=mute
  fi
fi

if [[ $ACTION == "mute" ]]; then
  for i in 0 1 2 3 4 5 6; do
    pactl set-sink-mute $i 1
  done
  echo 1 > ~/.mute
fi

if [[ $ACTION == "unmute" ]]; then
  for i in 0 1 2 3 4 5 6; do
    pactl set-sink-mute $i 0
  done

  echo 0 > ~/.mute
fi
