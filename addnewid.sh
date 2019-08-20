#!/bin/bash
steamId=$1
currentDate=$(date +%Y-%m-%d)
pathToScript="/home/osmc/git/steamtracker"
mkdir -p $pathToScript/users/$steamId
if [ -f $pathToScript/users/$steamId/datejoined.txt]; then
	echo "Users exists"
else
	echo $currentDate > $pathToScript/users/$steamId/datejoined.txt
fi
$pathToScript/getsite.sh $steamId
$pathToScript/calcMonth.sh $steamId
$pathToScript/generateWeb.sh $steamId
