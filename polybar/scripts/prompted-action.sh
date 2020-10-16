#!/bin/bash

idle_text=$1
prompt=$2
cmd=$3
prompt_wait=$4

if [ -z $prompt_wait ]; then
	prompt_wait=2
fi

ready=0

hit() {
	if [ $ready -eq 0 ]; then
		ready=1
		echo "$prompt"
		sleep $prompt_wait &
		wait
	else
		eval "$cmd"
	fi
	ready=0
	echo "$idle_text"	
}

trap "hit" USR1

echo "$idle_text"
while true; do
	sleep 1 &
	wait
done
