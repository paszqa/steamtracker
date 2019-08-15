#!/bin/bash

lastDays=7
currentDate=$(date +%Y-%m-%d)
firstDate=$(date -d "$currentDate -$lastDays day" +%Y-%m-%d)
steamId=$1
pathToScript="/home/osmc/git/steamtracker"
steamName=$(tail -1 $pathToScript/users/$steamId/userinfo.txt|awk -F';' '{print $2}')
pathToPlayed="/home/osmc/git/steamtracker/users/$steamId/played.csv"
pathToGameList="/home/osmc/git/steamtracker/users/$steamId/gamelist.csv"

#clear html
echo "" > /var/www/html/steamtracker/$steamName-$steamId.html

#generate html
#header
echo "<html><head><style>" >>  /var/www/html/steamtracker/$steamName-$steamId.html
echo "table{ border: 2px solid #222; border-collapse: collapse; background-color: #c5c5c5;}" >>  /var/www/html/steamtracker/$steamName-$steamId.html
echo "td{ border: 2px solid #444;}" >>  /var/www/html/steamtracker/$steamName-$steamId.html
echo "td.low{ background-color: #f2ffcc; }">>  /var/www/html/steamtracker/$steamName-$steamId.html
echo "td.medium{ background-color: #dfff80; }">>  /var/www/html/steamtracker/$steamName-$steamId.html
echo "td.high{ background-color: #99cc00; }">>  /var/www/html/steamtracker/$steamName-$steamId.html
echo "td.veryhigh{ background-color: #608000; }">>  /var/www/html/steamtracker/$steamName-$steamId.html
echo "tr:hover{ background-color: #00f5f5; border: 2px solid #000; }" >>  /var/www/html/steamtracker/$steamName-$steamId.html
echo "</style></head>" >>  /var/www/html/steamtracker/$steamName-$steamId.html
echo "<body>" >>  /var/www/html/steamtracker/$steamName-$steamId.html
echo "<table><tr>"  >>  /var/www/html/steamtracker/$steamName-$steamId.html
echo "<td style='width:50px;'>ID</td><td style='width: 200px;'>Game</td>">>  /var/www/html/steamtracker/$steamName-$steamId.html
dateArray=()
for i in $(seq 0 $lastDays); do
	temp=$(($lastDays - $i))
	thisDate=$(date -d "$currentDate -$temp day" +%Y-%m-%d)

	dateArray+=("$thisDate")
	echo "<td>$thisDate</td>" >>  /var/www/html/steamtracker/$steamName-$steamId.html
done
echo "</tr>" >>  /var/www/html/steamtracker/$steamName-$steamId.html
#echo "</table>" >>  /var/www/html/steamtracker/$steamName-$steamId.html

#echo "</body></html>"  >>  /var/www/html/steamtracker/$steamName-$steamId.html


##GENERATE GAMELIST
echo "" > $pathToGameList
cat $pathToPlayed|awk -F';' '{print $2}'|sort -u >> $pathToGameList


for appId in $(ls $pathToScript/users/$steamId/|grep -viE 'csv|xml'); do
	echo "<tr><td>$appId</td><td>games name</td>">>  /var/www/html/steamtracker/$steamName-$steamId.html
	for i in $(seq 0 $lastDays); do
		if [ -f $pathToScript/users/$steamId/$appId/${dateArray[i]} ]; then
			timePlayed=$(cat $pathToScript/users/$steamId/$appId/${dateArray[i]} | awk -F';' '{print $2}')
			if [ $timePlayed -gt 179 ]; then
				tdclass="veryhigh"
			elif [ $timePlayed -gt 119 ]; then
				tdclass="high"
                        elif [ $timePlayed -gt 59 ]; then
                                tdclass="medium"
			else
				tdclass="low"
			fi

			echo -n "<td class='$tdclass'>$timePlayed</td>" >>  /var/www/html/steamtracker/$steamName-$steamId.html
		else
			echo "<td>N/A</td>">>  /var/www/html/steamtracker/$steamName-$steamId.html
		fi
	done
	echo "</tr>">>  /var/www/html/steamtracker/$steamName-$steamId.html
done


##RUN MAIN SCRIPT
#while read line; do
#	lineDate=$(echo $line | awk -F';' '{print $1}')
#	gameTitle=$(echo $line | awk -F';' '{print $3}')
#	appId=$(echo $line | awk -F';' '{print $2}')
#	thisDayPlayed=$(echo $line | awk -F';' '{print $4}')
#	if [ $lineDate == "2019-08-14" ]; then
#		echo "<tr><td>$appId</td><td>$gameTitle</td><td></td><td></td><td></td><td></td><td>$thisDayPlayed</td><td></td></tr>" >>  /var/www/html/steamtracker/$steamName-$steamId.html
#	fi
#	echo $line >>  /var/www/html/steamtracker/$steamName-$steamId.html
#done < $pathToPlayed

echo "</table>" >>  /var/www/html/steamtracker/$steamName-$steamId.html
echo "</body></html>"  >>  /var/www/html/steamtracker/$steamName-$steamId.html




