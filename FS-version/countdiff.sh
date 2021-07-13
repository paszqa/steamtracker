#!/bin/bash
if [ -z $2 ]; then
	fromDate=$(date +%Y-%m-%d)
else
	fromDate=$2
fi
previousDate=$(date -d "$fromDate -1 day" +%Y-%m-%d)
pathToScript="/home/osmc/git/steamtracker"
steamId=$1
#if file doesnt exist,create it
touch $pathToScript/users/$steamId/played.csv

for folder in $(ls $pathToScript/users/$steamId/ | grep -viE "xml|csv"); do
	appId=$folder
	folder=$pathToScript/users/$steamId/$folder
	#echo $steamId
	#echo $folder
	#cat $steamId/$folder/$fromDate
	#cat $steamId/$folder/$fromDate | awk -F";" "{ print $2 }"
	todayGameTime=$(cat $folder/$fromDate | awk -F";" '{ print $2 }')
	if [ -f "$folder/$previousDate" ]; then
		yesterdayGameTime=$(cat $folder/$previousDate| awk -F";" '{ print $2 }')
	else
		yesterdayGameTime=0
	fi
	gameTitle=$(cat $folder/info.txt)
	#echo "t:$todayGameTime"
	#echo "y:$yesterdayGameTime"
	#echo -n $fromDate >> $steamId/$folder/played.txt
	#echo "$todayGameTime - $yesterdayGameTime" | bc
	playedTodayOnly=$(echo "$todayGameTime - $yesterdayGameTime" | bc) 
	if [ $playedTodayOnly -gt 0 ]; then
		echo "$fromDate;$appId;$gameTitle;$playedTodayOnly;$todayGameTime" >> $pathToScript/users/$steamId/played.csv
	fi
	#echo "X:$playedTodayOnly"
	
done
#cat $steamId/*/$fromDate

