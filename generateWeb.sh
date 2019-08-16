#!/bin/bash

lastDays=3
currentDate=$(date +%Y-%m-%d)
firstDate=$(date -d "$currentDate -$lastDays day" +%Y-%m-%d)
steamId=$1
pathToScript="/home/osmc/git/steamtracker"
steamName=$(tail -1 $pathToScript/users/$steamId/userinfo.txt|awk -F';' '{print $2}')
#steamNameWithoutSpaces=$(echo $steamName|tr -d' '|tr -d '-'|tr -d';'|tr -d'/')
pathToPlayed="/home/osmc/git/steamtracker/users/$steamId/played.csv"
pathToGameList="/home/osmc/git/steamtracker/users/$steamId/gamelist.csv"
dateJoined=$(cat $pathToScript/users/$steamId/datejoined.txt)
#clear html
echo "" > "/var/www/html/steamtracker/$steamName-$steamId.html"
echo "" > "/var/www/html/steamtracker/$steamName-$steamId-raw.html"
#generate html
#header
echo '<html><meta charset="UTF-8"><head><style>' >>  "/var/www/html/steamtracker/$steamName-$steamId.html"
echo "body { font-family: Calibri, Arial; }" >>  "/var/www/html/steamtracker/$steamName-$steamId.html"
echo "table{ border: 2px solid #777; border-collapse: collapse; background-color: #c5c5c5;}" >>  "/var/www/html/steamtracker/$steamName-$steamId.html"
echo "td{ border: 2px solid #777;}" >>  "/var/www/html/steamtracker/$steamName-$steamId.html"
echo "th{ border: 2px solid #000;}" >>  "/var/www/html/steamtracker/$steamName-$steamId.html"
echo "th.firstrow{ background-color: #e67300; text-align: center;}" >>  "/var/www/html/steamtracker/$steamName-$steamId.html"
echo "th.firstrow:hover{  background-color: #e67333;}">>  "/var/www/html/steamtracker/$steamName-$steamId.html"
echo "td.id{ background-color: #ffd9b3;}" >>  "/var/www/html/steamtracker/$steamName-$steamId.html"
echo "td.game{ background-color: #ffb366;}" >>  "/var/www/html/steamtracker/$steamName-$steamId.html"
echo "td.na{ background-color: #a5a5a5;}" >>  "/var/www/html/steamtracker/$steamName-$steamId.html"
echo "td.zero{ background-color: #d5d5d5;}" >>  "/var/www/html/steamtracker/$steamName-$steamId.html"
echo "td.low{ background-color: #f2ffcc; }">>  "/var/www/html/steamtracker/$steamName-$steamId.html"
echo "td.medium{ background-color: #dfff80; }">>  "/var/www/html/steamtracker/$steamName-$steamId.html"
echo "td.high{ background-color: #99cc00; }">>  "/var/www/html/steamtracker/$steamName-$steamId.html"
echo "td.veryhigh{ background-color: #608000; }">>  "/var/www/html/steamtracker/$steamName-$steamId.html"
#echo "tr:hover{ background-color: #00f5f5; border: 2px solid #fff; }" >>  "/var/www/html/steamtracker/$steamName-$steamId.html"
echo "</style></head>" >>  "/var/www/html/steamtracker/$steamName-$steamId.html"
echo "<body>" >>  "/var/www/html/steamtracker/$steamName-$steamId.html"

echo "<p>Username: $(tail -1 $pathToScript/users/$steamId/userinfo.txt | awk -F';' '{print $2}')</p>"  >>  "/var/www/html/steamtracker/$steamName-$steamId.html"
echo "<p>Date joined: $dateJoined</p>"  >>  "/var/www/html/steamtracker/$steamName-$steamId.html"
echo "<table id=\"myTable\"><tr>"  >>  "/var/www/html/steamtracker/$steamName-$steamId.html"
echo "<th id='A' class='firstrow' onclick=\"if(this.id=='A'){ sortTable(0,'asc',1); this.id='B';}else{sortTable(0,'desc',1); this.id='A';}\" style='width:50px;'>ID</th><th id='A' class='firstrow' onclick=\"if(this.id=='A'){ sortTable(1,'asc',0); this.id='B';}else{sortTable(1,'desc',0); this.id='A';}\" style='width: 200px;'>Game</th>">>  "/var/www/html/steamtracker/$steamName-$steamId.html"
dateArray=()
for i in $(seq 0 $lastDays); do
	temp=$(($lastDays - $i))
	thisDate=$(date -d "$currentDate -$temp day" +%Y-%m-%d)

	dateArray+=("$thisDate")
	if [ $(date -d $thisDate +%s) -ge $(date -d $dateJoined +%s) ]; then
		echo "<th id='A' class='firstrow' onclick=\"if(this.id=='A'){ sortTable($(($i+2)),'asc',1); this.id='B';}else{sortTable($(($i+2)),'desc',1); this.id='A';}\">$thisDate</th>" >>  "/var/www/html/steamtracker/$steamName-$steamId.html"
	fi
	if [ $i == $lastDays ]; then
		echo "<th id='A' class='firstrow' onclick=\"if(this.id=='A'){ sortTable($(($i+3)),'asc',1); this.id='B';}else{sortTable($(($i+3)),'desc',1); this.id='A';}\">RECENT TOTAL</th></tr>" >>  "/var/www/html/steamtracker/$steamName-$steamId.html"
	fi
done
#echo "<th class='firstrow'>RECENT TOTAL</th>" >>  "/var/www/html/steamtracker/$steamName-$steamId.html"
#echo "</tr>" >>  "/var/www/html/steamtracker/$steamName-$steamId.html"
#echo "</table>" >>  "/var/www/html/steamtracker/$steamName-$steamId.html"

#echo "</body></html>"  >>  /var/www/html/steamtracker/$steamName-$steamId.html


##GENERATE GAMELIST
echo "" > $pathToGameList
cat $pathToPlayed|awk -F';' '{print $2}'|sort -u >> $pathToGameList

#GENERATE RAW DATA
for appId in $(ls $pathToScript/users/$steamId/|grep -viE 'csv|xml|txt'); do
	if [ $(cat $pathToScript/users/$steamId/$appId/$currentDate | awk -F';' '{print $3}') -gt 0 ]; then
		echo -n "$appId;$(cat $pathToScript/users/$steamId/$appId/info.txt);" >> "/var/www/html/steamtracker/$steamName-$steamId-raw.html"
		recentPlayedTotal=0
                for i in $(seq 0 $lastDays); do
			if [ $(date -d ${dateArray[i]} +%s) -ge $(date -d $dateJoined +%s) ]; then
				if [ -f $pathToScript/users/$steamId/$appId/${dateArray[i]} ]; then
					timePlayed=$(cat $pathToScript/users/$steamId/$appId/${dateArray[i]} | awk -F';' '{print $2}')
					if [ ${dateArray[i]} != $(cat $pathToScript/users/$steamId/datejoined.txt) ]; then
						recentPlayedTotal=$(($recentPlayedTotal + $timePlayed))
					fi
					echo -n "$timeplayed;" >>  "/var/www/html/steamtracker/$steamName-$steamId-raw.html"
				else
					echo -n "N/A;" >>  "/var/www/html/steamtracker/$steamName-$steamId-raw.html"
				fi
			fi
		done
		echo "$recentPlayedTotal" >>  "/var/www/html/steamtracker/$steamName-$steamId-raw.html"
	fi
done
echo "-=-=-=-=-=-=-=-=------------"
for appId in $(ls $pathToScript/users/$steamId/|grep -viE 'csv|xml|txt'); do
	if [ $(cat $pathToScript/users/$steamId/$appId/$currentDate | awk -F';' '{print $3}') -gt 0 ]; then
		echo "<tr><td class='id'>$appId</td><td class='game'>$(cat $pathToScript/users/$steamId/$appId/info.txt)</td>">>  "/var/www/html/steamtracker/$steamName-$steamId.html"
		#echo -n "$appId;$(cat $pathToScript/users/$steamId/$appId/info.txt);"
		recentPlayedTotal=0
		for i in $(seq 0 $lastDays); do
			if [ $(date -d ${dateArray[i]} +%s) -ge $(date -d $dateJoined +%s) ]; then
				if [ -f $pathToScript/users/$steamId/$appId/${dateArray[i]} ]; then
	
					timePlayed=$(cat $pathToScript/users/$steamId/$appId/${dateArray[i]} | awk -F';' '{print $2}')
					totalPlayed=$(cat $pathToScript/users/$steamId/$appId/${dateArray[i]} | awk -F';' '{print $3}')
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

					if [ ${dateArray[i]} != $(cat $pathToScript/users/$steamId/datejoined.txt) ]; then
						recentPlayedTotal=$(($recentPlayedTotal + $timePlayed))
					fi
					echo -n "<td class='$tdclass'>$timePlayed ($totalPlayed)</td>" >>  "/var/www/html/steamtracker/$steamName-$steamId.html"
				else

					echo "<td class='na'>N/A</td>" >>  "/var/www/html/steamtracker/$steamName-$steamId.html"
				fi

			fi
		done

		echo "<td class='id'>$recentPlayedTotal</td>"  >>  "/var/www/html/steamtracker/$steamName-$steamId.html"

		echo "</tr>">>  "/var/www/html/steamtracker/$steamName-$steamId.html"
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

echo "</table>" >>  "/var/www/html/steamtracker/$steamName-$steamId.html"
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
" >>  "/var/www/html/steamtracker/$steamName-$steamId.html"
echo "</body></html>"  >>  "/var/www/html/steamtracker/$steamName-$steamId.html"
echo "Generated website: $steamName-$steamId.html"

echo > /var/www/html/steamtracker/all.php
#for y in /var/www/html/steamtracker/*; do
ls -1 /var/www/html/steamtracker/ | while read y; do
	#echo $y
	if [ "$y" != "all.php" ]; then
		echo "<p><a href='$y'>$y</a></p>" >> /var/www/html/steamtracker/all.php
	fi
done

