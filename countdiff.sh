#!/bin/bash
fromDate=$1
#previousDate=$(date $fromDate -d "yesterday")
previousDate=$(date -d "$fromDate -1 day" +%Y-%m-%d)

echo date=$fromDate
echo prev=$previousDate
steamId=76561198000030995
for folder in $(ls $steamId); do
	#echo $steamId
	#echo $folder
	#cat $steamId/$folder/$fromDate
	#cat $steamId/$folder/$fromDate | awk -F";" "{ print $2 }"
	todayGameTime=$(cat $steamId/$folder/$fromDate | awk -F";" '{ print $2 }')
	yesterdayGameTime=$(cat $steamId/$folder/$previousDate| awk -F";" '{ print $2 }')
	#echo "t:$todayGameTime"
	#echo "y:$yesterdayGameTime"
	#echo -n $fromDate >> $steamId/$folder/played.txt
	echo "$todayGameTime - $yesterdayGameTime" | bc
	playedTodayOnly=$(echo "$todayGameTime - $yesterdayGameTime" | bc) 
	echo "$fromDate;$playedTodayOnly" >> $steamId/$folder/played.txt
	#echo "X:$playedTodayOnly"
	
done
#cat $steamId/*/$fromDate

