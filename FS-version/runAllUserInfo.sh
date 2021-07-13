#!/bin/bash
pathToScript="/home/osmc/git/steamtracker"
for user in $(ls $pathToScript/users/); do
        #username=$(cat $pathToScript/users/
        echo -n "Running GetUserInfo script for $user for date: "
	if [ -z $1 ]; then
	        echo -n "$(date +%Y-%m-%d)..."
	        ./getuserinfo.sh $user
	else
		echo -n "$1..."
		./getuserinfo.sh $user $1
	fi
        echo "Done."
done

