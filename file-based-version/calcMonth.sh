#!/bin/bash
currentDate=$(date +%Y-%m-%d)
previousDate=$(date -d "$currentDate -1 day" +%Y-%m-%d)
#currentDay=$(date +%d)
#currentMonth=$(date +%m)
#currentYear=$(date +%Y)
pathToScript="/home/osmc/git/steamtracker"
steamId=$1
dateJoined=$(cat $pathToScript/users/$steamId/datejoined.txt)

for currentYear in $(seq $(date -d $dateJoined +%Y) $(date -d $currentDate +%Y)); do
#	echo "YEAR: $currentYear"
	for currentMonth in $(seq $(date -d $dateJoined +%m) $(date -d $currentDate +%m)); do
#		echo "MONTH: $currentFixedMonth"
#		echo > "/var/www/html/steamtracker/users/$steamId/$appId/$currentYear-$currentMonthFixed"
		if [ $currentMonth -lt 10 ]; then
                       currentMonthFixed=0$currentMonth
                fi
		echo > "$pathToScript/users/$steamId/$currentYear-$currentMonthFixed-raw.txt"
		for appId in $(ls $pathToScript/users/$steamId/|grep -viE 'csv|txt|xml'); do
			timePlayedThisMonth=0

#			echo "ls $pathToScript/users/$steamId/$appId/|grep -iv \"$currentYear-$currentMonthFixed\""

			for singleday in $(ls $pathToScript/users/$steamId/$appId/|grep -i "$currentYear-$currentMonthFixed"); do
#				echo $singleday
#				echo $dateJoined
#				echo "YYYY $(cat $pathToScript/users/$steamId/$appId/$singleday | awk -F';' '{print $2}')"				
				timePlayedToday=$(cat $pathToScript/users/$steamId/$appId/$singleday | awk -F';' '{print $2}')
#				echo "TP: $timePlayedToday"
				if [ $singleday != $dateJoined ]; then
#					echo "$timePlayedThisMonth + $timePlayedToday"
					timePlayedThisMonth=$(($timePlayedThisMonth + $timePlayedToday))
				fi
			done
			if [ $timePlayedThisMonth -gt 0 ]; then
				echo "$appId;$(cat $pathToScript/users/$steamId/$appId/info.txt);$timePlayedThisMonth"  >> "$pathToScript/users/$steamId/$currentYear-$currentMonthFixed-raw.txt"
			fi
		done
		echo > "$pathToScript/users/$steamId/$currentYear-$currentMonthFixed-top5.txt"
		cat $pathToScript/users/$steamId/$currentYear-$currentMonthFixed-raw.txt | sort -t';' -k3 -r -n| head -5 >> "$pathToScript/users/$steamId/$currentYear-$currentMonthFixed-top5.txt"
	done
done




