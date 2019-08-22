#!/bin/bash
pathToScript="/home/osmc/git/steamtracker"
for user in $(ls $pathToScript/users/); do
	#username=$(cat $pathToScript/users/
	echo -n "Running script for $user for date: "
	if [ -z $1 ]; then
		echo -n "$(date)..."
		./countdiff.sh $user
	else
		echo -n "$1..."
		./countdiff.sh $user $1
	fi
	echo "Done."
done
