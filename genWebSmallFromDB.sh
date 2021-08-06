#!/bin/bash
############ INFO ##################
# Script requires:
# - target Steam64 ID of user in the first parameter.
# - DB user in 2nd parameter
# - DB pass in 3rd parameter

############ CONFIG ################
lastDays=14 ###DEFINE THIS
pathToWebDir="/var/www/localhost/steamtracker"   ###DEFINE THIS
############ AUTO SETUP ############
currentDate=$(date -d yesterday +%Y-%m-%d)
firstDate=$(date -d "$currentDate -$lastDays day" +%Y-%m-%d)
steamId=$1
pathToScript="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
#pathToScript="/home/pi/steamtracker"
steamName=$(tail -1 $pathToScript/users/$steamId/userinfo.txt|awk -F';' '{print $2}')
pathToPlayed="$pathToScript/users/$steamId/played.csv"
pathToGameList="$pathToScript/users/$steamId/gamelist.csv"
dateJoined=$(cat $pathToScript/users/$steamId/datejoined.txt)
mkdir -p $pathToWebDir/files
cp files/style_default.css $pathToWebDir/files/
dbuser=$2
dbpass=$3
########## CLEAR OLD PHP/HTML ################
echo "" > "$pathToWebDir/$steamName-$steamId.html"
echo "" > "$pathToWebDir/$steamName-$steamId-raw.php"
########## GENERATE NEW WEBSITE ##############
#Header / Stylesheet
echo '<html><meta charset="UTF-8"><head>' >>  "$pathToWebDir/$steamName-$steamId.html"
echo "<link rel=\"stylesheet\" href=\"files/style_default.css\"></head>" >>  "$pathToWebDir/$steamName-$steamId.html"
echo "<body>" >>  "$pathToWebDir/$steamName-$steamId.html"
echo "<div class='main'><div class='leftmain'>" >>  "$pathToWebDir/$steamName-$steamId.html"
echo "<table id=\"myTable\"><tr>"  >>  "$pathToWebDir/$steamName-$steamId.html"
echo "<th id='A' class='firstrow' onclick=\"if(this.id=='A'){ sortTable(1,'asc',0); this.id='B';}else{sortTable(1,'desc',0); this.id='A';}\" style='width: 70px;'>Game</th>">>  "$pathToWebDir/$steamName-$steamId.html"
dateArray=()
whichtable=0
for i in $(seq 0 $lastDays); do
	temp=$(($lastDays - $i))
	thisDate=$(date -d "$currentDate -$temp day" +%Y-%m-%d)
	
	dateArray+=("$thisDate")
	if [ $(date -d $thisDate +%s) -gt $(date -d $dateJoined +%s) ]; then
		echo "<th id='A' class='dates' onclick=\"if(this.id=='A'){ sortTable($(($whichtable+1)),'asc',1); this.id='B';}else{sortTable($(($whichtable+1)),'desc',1); this.id='A';}\"><p class='dateday'>$(date -d $thisDate +%d)</p><p class='datemonth'>$(date -d $thisDate +%b)</p><p class='dateyear'>$(date -d $thisDate +%Y)</p></th>" >>  "$pathToWebDir/$steamName-$steamId.html"
		whichtable=$(($whichtable+1))
	else
		echo "<th id='A' class='dates'><p class='dateday'>$(date -d $thisDate +%d)</p><p class='datemonth'>$(date -d $thisDate +%b)</p><p class='dateyear'>$(date -d $thisDate +%Y)</p></th>" >>  "$pathToWebDir/$steamName-$steamId.html"
		whichtable=$(($whichtable+1))
	fi

	if [ $i == $lastDays ]; then
		echo "<th id='A' class='dates' onclick=\"if(this.id=='A'){ sortTable($(($whichtable+1)),'asc',1); this.id='B';}else{sortTable($(($whichtable+1)),'desc',1); this.id='A';}\">PLAYED<br>RECENTLY</th>" >>  "$pathToWebDir/$steamName-$steamId.html"
		echo "<th id='A' class='dates' onclick=\"if(this.id=='A'){ sortTable($(($whichtable+2)),'asc',1); this.id='B';}else{sortTable($(($whichtable+2)),'desc',1); this.id='A';}\">PLAYED<br>TOTAL </th></tr>" >>  "$pathToWebDir/$steamName-$steamId.html"
	fi
		
done

## #GENERATE GAMELIST
echo "" > $pathToGameList
if [ -f $pathToPlayed ]; then
	cat $pathToPlayed|awk -F';' '{print $2}'|sort -u >> $pathToGameList
else
	echo "" > $pathToPlayed
fi

### GET TOP 5 MOST PLAYED OVERALL
echo -n "" > $pathToScript/users/$steamId/top5-ever.txt
mysql -u $dbuser -p$dbpass -e "SELECT * FROM (SELECT \`id\`,MAX(date),\`appid\`,\`playedtotal\` FROM \`trackedtimes\`.\`$steamId\` GROUP BY \`appid\`) tmp ORDER BY \`playedtotal\` DESC LIMIT 5" trackedtimes | grep -vi 'id' | awk -F\\t '{print ""$3";;"$4";"}' >> $pathToScript/users/$steamId/top5-ever.txt

### TODO: GET TOP 5 FROM EACH MONTH
# Working query:
# SELECT * FROM (SELECT `id`,MAX(date),`appid`,`playedtotal`,`playedThisMonth` FROM `trackedtimes`.`123123123` WHERE `date` >= '2021-07-01' AND `date` < '2021-08-01' GROUP BY `appid` ) tmp ORDER BY `playedThisMonth` DESC LIMIT 5

#while read line; do
	#appId=$(echo $line | awk -F";" '{print $1)')
	#gamename=$(echo $line | awk -F";" '{print $2)')
	#echo "<tr><td class='id'>$appId</td><td class='game'>$gamename</td>"
#done < $pathToWebDir/$steamName-$steamId-raw.php
	

#BUILD UI
for appId in $(mysql -u $dbuser -p$dbpass -e "SELECT DISTINCT \`appid\` FROM \`$steamId\` WHERE \`date\` >= '$firstDate' AND \`playedtoday\` ORDER BY \`playedtotal\`" trackedtimes | grep -vi 'id'); do
	echo "<td class='game'><img class='imglarge' src='https://steamcdn-a.akamaihd.net/steam/apps/$appId/capsule_231x87.jpg'></td>" >> "$pathToWebDir/$steamName-$steamId.html"
	recentPlayedTotal=0
	for i in $(seq 0 $lastDays); do
		if [ $(date -d ${dateArray[i]} +%s) -gt $(date -d $dateJoined +%s) ]; then
			#echo "mysql -u $dbuser -p$dbpass1234 -e SELECT * FROM \`$steamId\` WHERE \`date\` >= '$firstDate' AND \`appid\` = $appId trackedtimes | grep -vi 'id'| awk -F\\t '{print $5}'"
			timePlayed=$(mysql -u $dbuser -p$dbpass -e "SELECT * FROM \`$steamId\` WHERE \`date\` = '${dateArray[i]}' AND \`appid\` = $appId" trackedtimes | grep -vi 'id' | awk -F\\t '{print $5}')
			#echo "---TPA1--"
			#echo "TPA: $timePlayedArray"
			#echo "---TPA---"

			#for timePlayed in $(echo $timePlayedArray); do
			#echo "RPT+TP:$recentPlayedTotal + $timePlayed"
			echo "TP:$timePlayed"
			echo "appId:$appId"
			#echo "--"
			if [[ $timePlayed -eq "" ]]; then
				timePlayed=0
			fi
			recentPlayedTotal=$(($recentPlayedTotal + $timePlayed))
			if [ ${dateArray[i]} == $(cat $pathToScript/users/$steamId/datejoined.txt) ]; then
	                       	tdclass="low"
	                elif [ $timePlayed -gt 900 ]; then
	                       	tdclass="dark7"
                        elif [ $timePlayed -gt 600 ]; then
                                tdclass="dark6"
                        elif [ $timePlayed -gt 480 ]; then
                                tdclass="dark5"
                        elif [ $timePlayed -gt 360 ]; then
                                tdclass="dark4"
                        elif [ $timePlayed -gt 300 ]; then
                                tdclass="dark3"
                        elif [ $timePlayed -gt 240 ]; then
                                tdclass="dark2"
                        elif [ $timePlayed -gt 180 ]; then
                                tdclass="dark1"
                        elif [ $timePlayed -gt 120 ]; then
                                tdclass="veryhigh"				
	                elif [ $timePlayed -gt 60 ]; then
	                     	tdclass="high"
	                elif [ $timePlayed -gt 30 ]; then
	                       	tdclass="medium"
	                elif [ $timePlayed -gt 0 ]; then
	                      	tdclass="low"
	                else
	                       	tdclass="zero"
	                fi
			echo -n "<td class='$tdclass' title=''>" >> "$pathToWebDir/$steamName-$steamId.html"
			if [ $timePlayed -gt 0 ]; then
				timePlayed=$(echo "$timePlayed 60" | awk '{printf "%.2f", $1 / $2}')
				printf "%.2f" $timePlayed  >> "$pathToWebDir/$steamName-$steamId.html" #<?php echo round($timePlayed/60,2) ?>
			fi
			echo -n " </td>" >>  "$pathToWebDir/$steamName-$steamId.html"
			#echo "<td>$timePlayed ;$i</td>" >>  "$pathToWebDir/$steamName-$steamId.html"
			#done
		elif [ $(date -d ${dateArray[i]} +%s) -eq $(date -d $dateJoined +%s) ]; then
			#print "joined!!"
			echo "<td class='joined' title='Joined!'></td>" >>  "$pathToWebDir/$steamName-$steamId.html"
		else
			#print n/a
			echo "<td class='na' title='N/A'></td>" >>  "$pathToWebDir/$steamName-$steamId.html"
		fi
	done
        echo "<td class='id'>" >> "$pathToWebDir/$steamName-$steamId.html"
		recentPlayedTotal=$(echo "$recentPlayedTotal 60" | awk '{printf "%.2f", $1 / $2}')
		printf "%.2f" $recentPlayedTotal  >> "$pathToWebDir/$steamName-$steamId.html" #<?php echo round($recentPlayedTotal/60,2) ?>
		echo "</td>"  >>  "$pathToWebDir/$steamName-$steamId.html"
	totalPlayed=$(mysql -u $dbuser -p$dbpass -e "SELECT \`playedtotal\` FROM \`trackedtimes\`.\`$steamId\` WHERE \`appid\` = '$appId' ORDER BY \`playedtotal\` DESC LIMIT 1" trackedtimes | grep -vi 'played')
        echo -n "<td class='total'>" >> "$pathToWebDir/$steamName-$steamId.html"
		totalPlayed=$(echo "$totalPlayed 60" | awk '{printf "%.2f", $1 / $2}')
		printf "%.2f" $totalPlayed  >> "$pathToWebDir/$steamName-$steamId.html" #<?php echo round($totalPlayed/60,2) ?>
		echo "</td>" >>  "$pathToWebDir/$steamName-$steamId.html"
#	echo "<td class='id'>x</td>"  >>  "$pathToWebDir/$steamName-$steamId.html"
#	echo "<td class='total'>y</td>" >>  "$pathToWebDir/$steamName-$steamId.html"

        echo "</tr>">>  "$pathToWebDir/$steamName-$steamId.html"
done


	

#for appId in $(ls $pathToScript/users/$steamId/|grep -viE 'csv|xml|txt'); do
#	if [ $(cat $pathToScript/users/$steamId/$appId/$currentDate | awk -F';' '{print $3}') -gt 0 ]; then
#		#echo -n "$appId;$(cat $pathToScript/users/$steamId/$appId/info.txt);"
#		totalPlayed=0
#		recentPlayedTotal=0
#		#count Recent played to decide if game should be printed
#		for i in $(seq 0 $lastDays); do
#			if [ $(date -d ${dateArray[i]} +%s) -gt $(date -d $dateJoined +%s) ]; then
#				if [ -f $pathToScript/users/$steamId/$appId/${dateArray[i]} ]; then
#					if [ ${dateArray[i]} != $(cat $pathToScript/users/$steamId/datejoined.txt) ]; then
#							timePlayed=$(cat $pathToScript/users/$steamId/$appId/${dateArray[i]} | awk -F';' '{print $2}')
#							recentPlayedTotal=$(($recentPlayedTotal + $timePlayed))
#					fi
#				fi
#			fi
#		done
#		
#		if [ $recentPlayedTotal -gt 0 ]; then
#			#echo "<tr><td class='id'>$appId</td>"
#			echo "<td class='game'><img class='imglarge' src='https://steamcdn-a.akamaihd.net/steam/apps/$appId/capsule_231x87.jpg'></td>">>  "$pathToWebDir/$steamName-$steamId.html"
#			for i in $(seq 0 $lastDays); do
#				if [ $(date -d ${dateArray[i]} +%s) -gt $(date -d $dateJoined +%s) ]; then
#					if [ -f $pathToScript/users/$steamId/$appId/${dateArray[i]} ]; then
#						timePlayed=$(cat $pathToScript/users/$steamId/$appId/${dateArray[i]} | awk -F';' '{print $2}')
#						totalPlayed=$(cat $pathToScript/users/$steamId/$appId/${dateArray[i]} | awk -F';' '{print $3}')
#						if [ ${dateArray[i]} == $(cat $pathToScript/users/$steamId/datejoined.txt) ]; then
#							tdclass="low"
#						elif [ $timePlayed -gt 179 ]; then
#							tdclass="veryhigh"
#						elif [ $timePlayed -gt 119 ]; then
#							tdclass="high"
#									elif [ $timePlayed -gt 59 ]; then
#											tdclass="medium"
#						elif [ $timePlayed -gt 0 ]; then
#
#							tdclass="low"
#						else
#							tdclass="zero"
#						fi
#
#						#if [ ${dateArray[i]} != $(cat $pathToScript/users/$steamId/datejoined.txt) ]; then
#							#=$(($recentPlayedTotal + $timePlayed))
#						#fi
#						echo -n "<td class='$tdclass'><?php echo round($timePlayed/60,2) ?></td>" >>  "$pathToWebDir/$steamName-$steamId.html"
#					else
#
#						echo "<td class='na'>N/A</td>" >>  "$pathToWebDir/$steamName-$steamId.html"
#					fi
#				elif [ $(date -d ${dateArray[i]} +%s) -eq $(date -d $dateJoined +%s) ]; then
#					echo "<td class='joined'>Joined!</td>" >>  "$pathToWebDir/$steamName-$steamId.html"
#				else
#					echo "<td class='na'>N/A</td>" >>  "$pathToWebDir/$steamName-$steamId.html"
#				fi
#			done
#
#			echo "<td class='id'><?php echo round($recentPlayedTotal/60,2) ?></td>"  >>  "$pathToWebDir/$steamName-$steamId.html"
#			echo "<td class='total'><?php echo round($totalPlayed/60,2) ?></td>" >>  "$pathToWebDir/$steamName-$steamId.html"
#
#			echo "</tr>">>  "$pathToWebDir/$steamName-$steamId.html"
#		fi
#	fi
#done


##RUN MAIN SCRIPT
#while read line; do
#	lineDate=$(secho $line | awk -F';' '{print $1}')
#	gameTitle=$(secho $line | awk -F';' '{print $3}')
#	appId=$(secho $line | awk -F';' '{print $2}')
#	thisDayPlayed=$(secho $line | awk -F';' '{print $4}')
#	if [ $lineDate == "2019-08-14" ]; then
#		echo "<tr><td>$appId</td><td>$gameTitle</td><td></td><td></td><td></td><td></td><td>$thisDayPlayed</td><td></td></tr>" >>  $pathToWebDir/$steamName-$steamId.html
#	fi
#	echo $line >>  $pathToWebDir/$steamName-$steamId.html
#done < $pathToPlayed

echo "</table></div><div class='rightmain'>" >>  "$pathToWebDir/$steamName-$steamId.html"


echo "<div class='userinfo'><div class='username'>$(tail -1 $pathToScript/users/$steamId/userinfo.txt | awk -F';' '{print $2}')</div>"  >>  "$pathToWebDir/$steamName-$steamId.html"
echo "<div class='datejoined'>Joined @ $dateJoined</div></div>"  >>  "$pathToWebDir/$steamName-$steamId.html"
#BUILD TOP 5 OVERALL
#SELECT * FROM (SELECT `id`,MAX(date),`appid`,`playedtotal` FROM `trackedtimes`.`76561198000030995` GROUP BY `appid`) tmp ORDER BY `playedtotal` DESC
#echo "<br>TOP 5 OVERALL<br>"  >>  "$pathToWebDir/$steamName-$steamId.html"
echo "<div class='top5'><table class='top5'>" >>  "$pathToWebDir/$steamName-$steamId.html"
counter=0
while read i; do #for i in $(cat $pathToWebDir/$steamId/top5-ever.txt | head -5); do
	counter=$(($counter + 1))
#	echo "<tr><td>$i</td></tr>" >>  "$pathToWebDir/$steamName-$steamId.html"
	if [[ $i != "" ]]; then
		appId=$(echo $i|awk -F';' '{print $1}')
		gameName=$(echo $i|awk -F';' '{print $2}')
		timePlayed=$(echo $i|awk -F';' '{print $3}')


                if [ $timePlayed -gt 30000 ]; then
                tdclass="veryhigh"
                elif [ $timePlayed -gt 6000 ]; then
                tdclass="high"
                elif [ $timePlayed -gt 300 ]; then
                tdclass="medium"
                elif [ $timePlayed -gt 0 ]; then
                tdclass="low"
                else
                tdclass="zero"
                fi

		echo -n "<tr><td class='top5game'><img class='top5' src='https://steamcdn-a.akamaihd.net/steam/apps/$appId/capsule_231x87.jpg'></td><td id='larger' class=\"$tdclass\">" >> "$pathToWebDir/$steamName-$steamId.html"
		timePlayed=$(echo "$timePlayed 60" | awk '{printf "%.2f", $1 / $2}')
		printf "%.2f" $timePlayed  >> "$pathToWebDir/$steamName-$steamId.html" #<?php echo round($timePlayed/60,2) ?>
		echo "</td></tr>" >>  "$pathToWebDir/$steamName-$steamId.html"
#echo "<tr><td class='top5game'><img class='top5' src='https://steamcdn-a.akamaihd.net/steam/apps/$appId/capsule_231x87.jpg'></td><td id='larger' class=\"$tdclass\">z</td></tr>" >>  "$pathToWebDir/$steamName-$steamId.html"
	fi
	if [ $counter -gt 5 ]; then
		break
	fi
done < $pathToScript/users/$steamId/top5-ever.txt
echo "</table></div>" >>  "$pathToWebDir/$steamName-$steamId.html"
#BUILD TOP 5 each month
#echo "<br>TOP 5 MONTH<br>">> "$pathToWebDir/$steamName-$steamId.html"
echo "<div class='top5'><table class='top5'>" >>  "$pathToWebDir/$steamName-$steamId.html"
while read i; do
	#for i in $(cat /home/osmc/git/steamtracker/users/$steamId/$steamName-$steamId-top5-ever.txt | sort -t';' -k3 -r -n| head -1); do
	if [[ $i != "" ]]; then
		appId=$(echo $i|awk -F';' '{print $1}')
		gameName=$(echo $i|awk -F';' '{print $2}')
		timePlayed=$(echo $i|awk -F';' '{print $3}')
                if [ $timePlayed -gt 9000 ]; then
                tdclass="dark7"
                elif [ $timePlayed -gt 6000 ]; then
                tdclass="dark6"
                elif [ $timePlayed -gt 4800 ]; then
                tdclass="dark5"
                elif [ $timePlayed -gt 0 ]; then
                tdclass="low"
                else
                tdclass="zero"
                fi
		echo -n "<tr><td class='top5game'><img class='top5' src='https://steamcdn-a.akamaihd.net/steam/apps/$appId/capsule_231x87.jpg'></td><td id='larger' class=\"$tdclass\">" >> "$pathToWebDir/$steamName-$steamId.html"
		#timePlayed=$(($timePlayed/60))
		#timePlayed=$(bc <<< "scale=2; (20+5)/2")
		timePlayed=$(echo "$timePlayed 60" | awk '{printf "%.2f", $1 / $2}')
		printf "%.2f" $timePlayed  >> "$pathToWebDir/$steamName-$steamId.html" #<?php echo round($timePlayed/60,2) ?>
		echo "</td></tr>" >>  "$pathToWebDir/$steamName-$steamId.html"
#echo "<tr><td class='top5game'><img class='top5' src='https://steamcdn-a.akamaihd.net/steam/apps/$appId/capsule_231x87.jpg'></td><td id='larger' class=\"$tdclass\">f</td></tr>" >>  "$pathToWebDir/$steamName-$steamId.html"

#		echo "<tr><td>$appId</td><td>$gameName</td><td>$gameTime</td></tr>" >>  "$pathToWebDir/$steamName-$steamId.html"
	fi
done < /home/pi/steamtracker/users/$steamId/2021-07-top5.txt
echo "</table></div>" >>  "$pathToWebDir/$steamName-$steamId.html"
echo "</div></div>" >>  "$pathToWebDir/$steamName-$steamId.html"

echo "<script>
function sortTable(r,order,numbers) {
  var table, rows, switching, i, x, y, shouldSwitch;
  table = document.getElementById(\"myTable\");
  switching = true;
  /*Make a loop that will continue until
  no switching has been done:*/
  while (switching) {
    //start by saying: no switching is done:
    switching = false;
    rows = table.rows;
    /*Loop through all table rows (except the
    first, which contains table headers):*/
    for (i = 1; i < (rows.length - 1); i++) {
      //start by saying there should be no switching:
      shouldSwitch = false;
      /*Get the two elements you want to compare,
      one from current row and one from the next:*/
      x = rows[i].getElementsByTagName(\"TD\")[r];
      y = rows[i + 1].getElementsByTagName(\"TD\")[r];
      //check if the two rows should switch place:
	if (order == \"asc\"){
		if (numbers == 0){
	       		if (x.innerHTML.toLowerCase() > y.innerHTML.toLowerCase()) {
 			//if so, mark as a switch and break the loop:
			shouldSwitch = true;
			break;
	          	}
		}
		else{
			if (Number(x.innerHTML.split(' ')[0]) > Number(y.innerHTML.split(' ')[0])) {
				//if so, mark as a switch and break the loop:
				shouldSwitch = true;
				break;
			}

		}
	}
	else{
		if (numbers == 0){
                        if (x.innerHTML.toLowerCase() < y.innerHTML.toLowerCase()) {
                        //if so, mark as a switch and break the loop:
                        shouldSwitch = true;
                        break;
                        }
                }
                else{
			if (Number(x.innerHTML.split(' ')[0]) < Number(y.innerHTML.split(' ')[0])) {
                                //if so, mark as a switch and break the loop:
                                shouldSwitch = true;
                                break;
                        }

                }






         }





    }
    if (shouldSwitch) {
      /*If a switch has been marked, make the switch
      and mark that a switch has been done:*/
      rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
      switching = true;
    }
  }
}
</script>
" >>  "$pathToWebDir/$steamName-$steamId.html"

echo "</body></html>"  >>  "$pathToWebDir/$steamName-$steamId.html"
echo "Generated website: $steamName-$steamId.html"

echo > $pathToWebDir/all.php
#for y in $pathToWebDir/*; do

$pathToScript/makeallphp.sh
#ls -1 $pathToWebDir/ | while read y; do
#	echo "Y: $y"
#	if [[ $y != "all.php" ]] && [[ $y == *".php"* ]] && [[ $y != *"-raw.php"* ]] && [[ $y != "" ]]; then
#		echo "Y2: $y"
#		echo "<p><a href='$y'>$y</a></p>" >> $pathToWebDir/all.php
#	fi
#done


