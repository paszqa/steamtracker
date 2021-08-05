#!/bin/bash
#######Info
# Script calculates monthly time spent in each title
# Requires:
# - steam64 ID as 1st parameter
# - DB user as 2nd parameter
# - DB pass as 3rd parameter
currentDate=$(date -d yesterday +%Y-%m-%d)
previousDate=$(date -d "$currentDate -1 day" +%Y-%m-%d)
pathToScript="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
steamId=$1
dbuser=$2
dbpass=$3
dateJoined=$(cat $pathToScript/users/$steamId/datejoined.txt)

for currentYear in $(seq $(date -d $dateJoined +%Y) $(date -d $currentDate +%Y)); do
	for currentMonth in $(seq 1 12); do
		if [ $currentMonth -lt 10 ]; then
                       currentMonthFixed=0$currentMonth
                fi
		echo -n > "$pathToScript/users/$steamId/$currentYear-$currentMonthFixed-raw.txt"
		for appId in $(mysql -u $dbuser -p$dbpass -e "SELECT DISTINCT \`appid\` FROM \`$steamId\` WHERE MONTH(date) = '$currentMonthFixed' ORDER BY \`playedtotal\`" trackedtimes | grep -vi 'appid' ); do
			timePlayedThisMonth=0
			for singleday in $(mysql -u $dbuser -p$dbpass -e "SELECT \`playedToday\` FROM \`$steamId\` WHERE \`appId\` = '$appId' AND MONTH(date) = '$currentMonthFixed'" trackedtimes | grep -vi 'playedToday'); do
				timePlayedThisMonth=$(($timePlayedThisMonth + $singleday))
			done
			if [ $timePlayedThisMonth -gt 0 ]; then
				echo "$appId;$(cat $pathToScript/users/$steamId/$appId/info.txt);$timePlayedThisMonth"  >> "$pathToScript/users/$steamId/$currentYear-$currentMonthFixed-raw.txt"
			fi

		done 
		echo -n > "$pathToScript/users/$steamId/$currentYear-$currentMonthFixed-top5.txt"
		cat $pathToScript/users/$steamId/$currentYear-$currentMonthFixed-raw.txt | sort -t';' -k3 -r -n| head -5 >> "$pathToScript/users/$steamId/$currentYear-$currentMonthFixed-top5.txt"

	done
done
