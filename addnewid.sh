#!/bin/bash
steamId=$1
currentDate=$(date +%Y-%m-%d)
pathToScript="/home/osmc/git/steamtracker"
mkdir -p $pathToScript/users/$steamId
echo $currentDate > $pathToScript/users/$steamId/datejoined.txt
$pathToScript/getsite.sh $steamId
