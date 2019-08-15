#!/bin/bash

lastDays=3
currentDate=$(date +%Y-%m-%d)
firstDate=$(date -d "$currentDate -$lastDays day" +%Y-%m-%d)
steamId=$1
pathToScript="/home/osmc/git/steamtracker"
steamName=$(tail -1 $pathToScript/users/$steamId/userinfo.txt|awk -F';' '{print $2}')
pathToPlayed="/home/osmc/git/steamtracker/users/$steamId/played.csv"
pathToGameList="/home/osmc/git/steamtracker/users/$steamId/gamelist.csv"
dateJoined=$(cat $pathToScript/users/$steamId/datejoined.txt)
#clear html
echo "" > /var/www/html/steamtracker/$steamName-$steamId.html

#generate html
#header
echo '<html><meta charset="UTF-8"><head><style>' >>  /var/www/html/steamtracker/$steamName-$steamId.html
echo "body { font-family: Calibri, Arial; }" >>  /var/www/html/steamtracker/$steamName-$steamId.html
echo "table{ border: 2px solid #777; border-collapse: collapse; background-color: #c5c5c5;}" >>  /var/www/html/steamtracker/$steamName-$steamId.html
echo "td{ border: 2px solid #777;}" >>  /var/www/html/steamtracker/$steamName-$steamId.html
echo "td.firstrow{ background-color: #e67300; text-align: center;}" >>  /var/www/html/steamtracker/$steamName-$steamId.html
echo "td.id{ background-color: #ffd9b3;}" >>  /var/www/html/steamtracker/$steamName-$steamId.html
echo "td.game{ background-color: #ffb366;}" >>  /var/www/html/steamtracker/$steamName-$steamId.html
echo "td.na{ background-color: #a5a5a5;}" >>  /var/www/html/steamtracker/$steamName-$steamId.html
echo "td.zero{ background-color: #d5d5d5;}" >>  /var/www/html/steamtracker/$steamName-$steamId.html
echo "td.low{ background-color: #f2ffcc; }">>  /var/www/html/steamtracker/$steamName-$steamId.html
echo "td.medium{ background-color: #dfff80; }">>  /var/www/html/steamtracker/$steamName-$steamId.html
echo "td.high{ background-color: #99cc00; }">>  /var/www/html/steamtracker/$steamName-$steamId.html
echo "td.veryhigh{ background-color: #608000; }">>  /var/www/html/steamtracker/$steamName-$steamId.html
echo "tr:hover{ background-color: #00f5f5; border: 2px solid #fff; }" >>  /var/www/html/steamtracker/$steamName-$steamId.html
echo "</style></head>" >>  /var/www/html/steamtracker/$steamName-$steamId.html
echo "<body>" >>  /var/www/html/steamtracker/$steamName-$steamId.html

echo "<p>Username: $(tail -1 $pathToScript/users/$steamId/userinfo.txt | awk -F';' '{print $2}')</p>"  >>  /var/www/html/steamtracker/$steamName-$steamId.html
echo "<p>Date joined: $dateJoined</p>"  >>  /var/www/html/steamtracker/$steamName-$steamId.html
echo "<table><tr>"  >>  /var/www/html/steamtracker/$steamName-$steamId.html
echo "<td class='firstrow' style='width:50px;'>ID</td><td class='firstrow' style='width: 200px;'>Game</td>">>  /var/www/html/steamtracker/$steamName-$steamId.html
dateArray=()
for i in $(seq 0 $lastDays); do
	temp=$(($lastDays - $i))
	thisDate=$(date -d "$currentDate -$temp day" +%Y-%m-%d)

	dateArray+=("$thisDate")
	if [ $(date -d $thisDate +%s) -ge $(date -d $dateJoined +%s) ]; then
		echo "<td class='firstrow'>$thisDate</td>" >>  /var/www/html/steamtracker/$steamName-$steamId.html
	fi
done
echo "</tr>" >>  /var/www/html/steamtracker/$steamName-$steamId.html
#echo "</table>" >>  /var/www/html/steamtracker/$steamName-$steamId.html

#echo "</body></html>"  >>  /var/www/html/steamtracker/$steamName-$steamId.html


##GENERATE GAMELIST
echo "" > $pathToGameList
cat $pathToPlayed|awk -F';' '{print $2}'|sort -u >> $pathToGameList


for appId in $(ls $pathToScript/users/$steamId/|grep -viE 'csv|xml|txt'); do
	if [ $(cat $pathToScript/users/$steamId/$appId/$currentDate | awk -F';' '{print $3}') -gt 0 ]; then
		echo "<tr><td class='id'>$appId</td><td class='game'>$(cat $pathToScript/users/$steamId/$appId/info.txt)</td>">>  /var/www/html/steamtracker/$steamName-$steamId.html
		for i in $(seq 0 $lastDays); do
			if [ $(date -d ${dateArray[i]} +%s) -ge $(date -d $dateJoined +%s) ]; then
				if [ -f $pathToScript/users/$steamId/$appId/${dateArray[i]} ]; then
					timePlayed=$(cat $pathToScript/users/$steamId/$appId/${dateArray[i]} | awk -F';' '{print $2}')
					if [ ${dateArray[i]} == $(cat $pathToScript/users/$steamId/datejoined.txt) ]; then
						tdclass="low"
					elif [ $timePlayed -gt 179 ]; then
						tdclass="veryhigh"
					elif [ $timePlayed -gt 119 ]; then
						tdclass="high"
		                        elif [ $timePlayed -gt 59 ]; then
		                                tdclass="medium"
					elif [ $timePlayed -gt 0 ]; then
						tdclass="low"
					else
						tdclass="zero"
					fi
		
					echo -n "<td class='$tdclass'>$timePlayed</td>" >>  /var/www/html/steamtracker/$steamName-$steamId.html
				else
					echo "<td class='na'>N/A</td>">>  /var/www/html/steamtracker/$steamName-$steamId.html
				fi
			fi
		done
		echo "</tr>">>  /var/www/html/steamtracker/$steamName-$steamId.html
	fi
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




