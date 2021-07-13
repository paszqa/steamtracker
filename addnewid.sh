#!/bin/bash
steamId=$1
currentDate=$(date +%Y-%m-%d)
pathToScript="/home/pi/steamtracker"
mkdir -p $pathToScript/users/$steamId
if [ -f $pathToScript/users/$steamId/datejoined.txt ]; then
	echo "User exists"
else
	echo $currentDate > $pathToScript/users/$steamId/datejoined.txt
fi
