#!/bin/bash

lastDays=40
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
echo "" > "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "" > "/var/www/html/steamtracker/$steamName-$steamId-raw.php"
#generate html
#header
echo '<html><meta charset="UTF-8"><head><style>' >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "body { font-family: Calibri, Arial;
background-repeat: no-repeat;
background-attachment: fixed;
height: 100%;
	    background: rgba(250,244,237,1);
	    background: -moz-linear-gradient(top, rgba(250,244,237,1) 0%, rgba(227,183,136,1) 70%, rgba(168,92,0,1) 100%);
	    background: -webkit-gradient(left top, left bottom, color-stop(0%, rgba(250,244,237,1)), color-stop(70%, rgba(227,183,136,1)), color-stop(100%, rgba(168,92,0,1)));
	    background: -webkit-linear-gradient(top, rgba(250,244,237,1) 0%, rgba(227,183,136,1) 70%, rgba(168,92,0,1) 100%);
	    background: -o-linear-gradient(top, rgba(250,244,237,1) 0%, rgba(227,183,136,1) 70%, rgba(168,92,0,1) 100%);
	    background: -ms-linear-gradient(top, rgba(250,244,237,1) 0%, rgba(227,183,136,1) 70%, rgba(168,92,0,1) 100%);
	    background: linear-gradient(to bottom, rgba(250,244,237,1) 0%, rgba(227,183,136,1) 70%, rgba(168,92,0,1) 100%);
	    filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#faf4ed', endColorstr='#a85c00', GradientType=0 );
}" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "div.main { width:100%;}" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "div.leftmain { vertical-align: top; display: inline-block; border: 0px solid transparent; width: 70%;}" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "div.rightmain { vertical-align: top; display: inline-block; border: 0px solid transparent; width: 29%;}" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "div.userinfo { margin-left: 2%; width: 95%; border-radius: 10px; padding: 15px 15px 15px 15px; 
background: -webkit-gradient(left top, right top, color-stop(0%, rgba(255,174,75,1)), color-stop(17%, rgba(247,228,207,1)), color-stop(34%, rgba(255,174,75,1)), color-stop(100%, rgba(168,92,0,1)));
background: -webkit-linear-gradient(left, rgba(255,174,75,1) 0%, rgba(247,228,207,1) 17%, rgba(255,174,75,1) 34%, rgba(168,92,0,1) 100%);
background: -o-linear-gradient(left, rgba(255,174,75,1) 0%, rgba(247,228,207,1) 17%, rgba(255,174,75,1) 34%, rgba(168,92,0,1) 100%);
background: -ms-linear-gradient(left, rgba(255,174,75,1) 0%, rgba(247,228,207,1) 17%, rgba(255,174,75,1) 34%, rgba(168,92,0,1) 100%);
background: linear-gradient(to right, rgba(255,174,75,1) 0%, rgba(247,228,207,1) 17%, rgba(255,174,75,1) 34%, rgba(168,92,0,1) 100%);
filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#ffae4b', endColorstr='#a85c00', GradientType=1 );
}
" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "div.username { font-size: 35px; color: white; text-shadow: 2px 2px #444; width: 100%;}" >> "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "div.datejoined { color: #999; font-size: 20px; width: 50%;}" >> "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "table{ width: 100%; border: 2px solid transparent; border-collapse: separate; background-color: #fff; border-spacing: 3px;}" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
#echo "table.top5{ background-color: transparent; }" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td{ text-align: center; border: 0px solid #777; border-radius: 5px;}" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "th{ border: 0px solid #000; border-radius: 5px; -o-transition:.5s; -ms-transition:.5s; -moz-transition:.5s; -webkit-transition:.5s; transition:.5s;}" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "th:hover{ -o-transition:.5s; -ms-transition:.5s; -moz-transition:.5s; -webkit-transition:.5s; transition:.5s;}" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "th.firstrow{ background-color: #e68a00; text-align: center;}" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "th.firstrow:hover{ background-color: #ffc266;}">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "th.dates{ background-color: #e68a00; text-align: center; width: 40px;}" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "th.dates:hover{ background-color: #ffc266; text-align: center; width: 40px;}" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td {  -o-transition:.5s; -ms-transition:.5s; -moz-transition:.5s; -webkit-transition:.5s; transition:.5s;}">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td#larger{ font-size: 25px; }" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td:hover {  -o-transition:.5s; -ms-transition:.5s; -moz-transition:.5s; -webkit-transition:.5s; transition:.5s;}" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.id{ background-color: #ffd9b3;}" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.id:hover{ background-color: #fff2e6;}" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "img.imglarge{ border-radius: 10px; max-width: 100%; height: 20px; -o-transition:.5s; -ms-transition:.5s; -moz-transition:.5s; -webkit-transition:.5s; transition:.5s; }" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "img.imglarge:hover{ filter: brightness(1.4); -o-transition:.5s; -ms-transition:.5s; -moz-transition:.5s; -webkit-transition:.5s; transition:.5s; max-width: 100%; height: 20px;}" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.game{ text-align: left; background-color: transparent;}" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.game:hover{ text-align: left; background-color: transparent;}" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.joined{ text-align: center; background-color: #ffff66;}" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.joined:hover{ text-align: center; background-color: #ffffb3;}" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.total{ text-align: center; background-color: #ffb366;}" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.total:hover{ text-align: center; background-color: #ffd9b3;}" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.na{ background-color: #a5a5a5;}" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.na:hover{ background-color: #d9d9d9;}" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.zero{ background-color: #ffffff;}" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.zero:hover{ background-color: #ffffff;}" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.low{ background-color: #eeffcc; }">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.low:hover{ background-color: #eeffcc; }">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.medium{ background-color: #ddff99; }">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.medium:hover{ background-color: #ddff99; }">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.high{ background-color: #ccff66; }">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.high:hover{ background-color: #ccff66; }">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.veryhigh{ background-color: #99e600; }">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.veryhigh:hover{ background-color: #99e600; }">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.dark1{ background-color: #88cc00; }">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.dark1:hover{ background-color: #88cc00; }">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.dark2{ background-color: #77b300; }">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.dark2:hover{ background-color: #77b300; }">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.dark3{ background-color: #669900; }">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.dark3:hover{ background-color: #669900; }">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.dark4{ background-color: #446600; }">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.dark4:hover{ background-color: #446600; }">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.dark5{ background-color: #334d00; }">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.dark5:hover{ background-color: #334d00; }">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.dark6{ background-color: #223300; }">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.dark6:hover{ background-color: #223300; }">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.dark7{ background-color: #000000; }">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.dark7:hover{ background-color: #000000; }">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "table.myTable td{ overflow: hidden; white-space: nowrap; width: 15px; font-size: 5px; }" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "tr{ -o-transition:.5s; -ms-transition:.5s; -moz-transition:.5s; -webkit-transition:.5s; transition:.5s; background-color: transparent; border-radius: 5px;}">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "tr:hover{ -o-transition:.5s; -ms-transition:.5s; -moz-transition:.5s; -webkit-transition:.5s; transition:.5s; background-color: transparent; filter: drop-shadow(4px 4px 4px #888);}">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "p.dateday{ font-size: 7px; font-weight: normal; line-height: 18px; margin: 0px;}">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "p.datemonth{ font-size: 4px; font-weight: normal; line-height: 10px; margin: 0px;}">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "p.dateyear{ font-size: 4px; font-weight: normal; line-height: 10px; margin: 0px;}">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
#top5
echo "div.top5 { vertical-align: top; display: inline-block; width: 49%; }">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "table.top5{ width: 100%; background-color: transparent; }" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td.top5game { width: 50%; text-align: left; background-color: transparent;}" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "td #id { font-size: 25px; color: #fff; text-shadow: 2px 2px #000; }" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "img.top5 { max-width: 100%; height: auto; }" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
#echo "td.top5hours { width: 231px; ft; }" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
#echo "tr:hover{ background-color: #00f5f5; border: 2px solid #fff; }" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "</style></head>" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "<body>" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"

#echo "<div class='userinfo'><div class='username'>$(tail -1 $pathToScript/users/$steamId/userinfo.txt | awk -F';' '{print $2}')</div>"  >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
#echo "<div class='datejoined'>Joined @ $dateJoined</div></div>"  >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "<div class='main'><div class='leftmain'>" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "<table id=\"myTable\"><tr>"  >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
#echo "<th id='A' class='firstrow' onclick=\"if(this.id=='A'){ sortTable(0,'asc',1); this.id='B';}else{sortTable(0,'desc',1); this.id='A';}\" style='width:50px;'>ID</th>'
echo "<th id='A' class='firstrow' onclick=\"if(this.id=='A'){ sortTable(1,'asc',0); this.id='B';}else{sortTable(1,'desc',0); this.id='A';}\" style='width: 70px;'>Game</th>">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
dateArray=()
whichtable=0
for i in $(seq 0 $lastDays); do
	temp=$(($lastDays - $i))
	thisDate=$(date -d "$currentDate -$temp day" +%Y-%m-%d)
	
	dateArray+=("$thisDate")
	if [ $(date -d $thisDate +%s) -gt $(date -d $dateJoined +%s) ]; then
		echo "<th id='A' class='dates' onclick=\"if(this.id=='A'){ sortTable($(($whichtable+1)),'asc',1); this.id='B';}else{sortTable($(($whichtable+1)),'desc',1); this.id='A';}\"><p class='dateday'>$(date -d $thisDate +%d)</p><p class='datemonth'>$(date -d $thisDate +%b)</p><p class='dateyear'>$(date -d $thisDate +%Y)</p></th>" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
		whichtable=$(($whichtable+1))
	else
		echo "<th id='A' class='dates'><p class='dateday'>$(date -d $thisDate +%d)</p><p class='datemonth'>$(date -d $thisDate +%b)</p><p class='dateyear'>$(date -d $thisDate +%Y)</p></th>" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
		whichtable=$(($whichtable+1))
	fi

	if [ $i == $lastDays ]; then
		echo "<th id='A' class='dates' onclick=\"if(this.id=='A'){ sortTable($(($whichtable+1)),'asc',1); this.id='B';}else{sortTable($(($whichtable+1)),'desc',1); this.id='A';}\">PLAYED<br>RECENTLY</th>" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
		echo "<th id='A' class='dates' onclick=\"if(this.id=='A'){ sortTable($(($whichtable+2)),'asc',1); this.id='B';}else{sortTable($(($whichtable+2)),'desc',1); this.id='A';}\">PLAYED<br>TOTAL </th></tr>" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
	fi
		
done
#echo "<th class='firstrow'>RECENT TOTAL</th>" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
#echo "</tr>" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
#echo "</table>" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"

#echo "</body></html>"  >>  /var/www/html/steamtracker/$steamName-$steamId.php


##GENERATE GAMELIST
echo "" > $pathToGameList
if [ -f $pathToPlayed ]; then
	cat $pathToPlayed|awk -F';' '{print $2}'|sort -u >> $pathToGameList
else
	echo "" > $pathToPlayed
fi

#GENERATE RAW DATA
for appId in $(ls $pathToScript/users/$steamId/|grep -viE 'csv|xml|txt'); do
	if [ $(cat $pathToScript/users/$steamId/$appId/$currentDate | awk -F';' '{print $3}') -gt 0 ]; then
		echo -n "$appId;$(cat $pathToScript/users/$steamId/$appId/info.txt);$(cat $pathToScript/users/$steamId/$appId/$currentDate | awk -F';' '{print $3}');" >> "/var/www/html/steamtracker/$steamName-$steamId-raw.php"
		recentPlayedTotal=0
        for i in $(seq 0 $lastDays); do
			if [ $(date -d ${dateArray[i]} +%s) -gt $(date -d $dateJoined +%s) ]; then
				if [ -f $pathToScript/users/$steamId/$appId/${dateArray[i]} ]; then
					timePlayed=$(cat $pathToScript/users/$steamId/$appId/${dateArray[i]} | awk -F";" '{print $2}')
#					totalTimePlayed=$(cat $pathToScript/users/$steamId/$appId/$currentDate | awk -F";" '{print $3}')
					if [ ${dateArray[i]} != $(cat $pathToScript/users/$steamId/datejoined.txt) ]; then
						recentPlayedTotal=$(($recentPlayedTotal + $timePlayed))
					fi
#					cat $pathToScript/users/$steamId/$appId/${dateArray[i]}
#					echo "RAW.... tp:$timePlayed steamName:$steamName steamId:$steamId "
					echo -n "$timePlayed;" >>  "/var/www/html/steamtracker/$steamName-$steamId-raw.php"
				else
					echo -n "N/A;" >>  "/var/www/html/steamtracker/$steamName-$steamId-raw.php"
				fi

			fi
		done
		echo "$recentPlayedTotal" >>  "/var/www/html/steamtracker/$steamName-$steamId-raw.php"
	fi
done


#GET TOP 5 MOST PLAYED OVERALL
#SELECT * FROM (SELECT `id`,MAX(date),`appid`,`playedtotal` FROM `trackedtimes`.`76561198000030995` GROUP BY `appid`) tmp ORDER BY `playedtotal` DESC
echo -n "" > $pathToScript/users/$steamId/top5-ever.txt
#mysql -u loser -pDupa1234 -e "SELECT * FROM (SELECT `id`,MAX(date),`appid`,`playedtotal` FROM `trackedtimes`.`$steamId` GROUP BY `appid`) tmp ORDER BY `playedtotal` DESC LIMIT 5" | awk -F\\t '{print "\""$1"\";"$2";"$3"}'
#mysql -u loser -pDupa1234 -e "SELECT * FROM (SELECT \`id\`,MAX(date),\`appid\`,\`playedtotal\` FROM \`trackedtimes\`.\`76561198000030995\` GROUP BY \`appid\`) tmp ORDER BY \`playedtotal\` DESC LIMIT 5" | awk -F\\t '{print ""$3";;"$4}'
mysql -u loser -pDupa1234 -e "SELECT * FROM (SELECT \`id\`,MAX(date),\`appid\`,\`playedtotal\` FROM \`trackedtimes\`.\`$steamId\` GROUP BY \`appid\`) tmp ORDER BY \`playedtotal\` DESC LIMIT 5" trackedtimes | grep -vi 'id' | awk -F\\t '{print ""$3";;"$4";"}' >> $pathToScript/users/$steamId/top5-ever.txt



#cat /var/www/html/steamtracker/$steamName-$steamId-raw.php | sort -t';' -k3 -r -n >> $pathToScript/users/$steamId/top5-ever.txt

#GET TOP 5 FROM EACH MONTH

#while read line; do
	#appId=$(echo $line | awk -F";" '{print $1)')
	#gamename=$(echo $line | awk -F";" '{print $2)')
	#echo "<tr><td class='id'>$appId</td><td class='game'>$gamename</td>"
#done < /var/www/html/steamtracker/$steamName-$steamId-raw.php
	

#BUILD UI
#mysql -u loser -pDupa1234 -e "SELECT DISTINCT \`appid\` FROM \`76561198000030995\` WHERE \`date\` > '2019-08-13' AND \`playedtoday\` > 0" trackedtimes
for appId in $(mysql -u loser -pDupa1234 -e "SELECT DISTINCT \`appid\` FROM \`$steamId\` WHERE \`date\` >= '$firstDate' AND \`playedtoday\` ORDER BY \`playedtotal\`" trackedtimes | grep -vi 'id'); do
	echo "<td class='game'><img class='imglarge' src='https://steamcdn-a.akamaihd.net/steam/apps/$appId/capsule_231x87.jpg'></td>">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
	recentPlayedTotal=0
	for i in $(seq 0 $lastDays); do
		if [ $(date -d ${dateArray[i]} +%s) -gt $(date -d $dateJoined +%s) ]; then
			#echo "mysql -u loser -pDupa1234 -e SELECT * FROM \`$steamId\` WHERE \`date\` >= '$firstDate' AND \`appid\` = $appId trackedtimes | grep -vi 'id'| awk -F\\t '{print $5}'"
			timePlayed=$(mysql -u loser -pDupa1234 -e "SELECT * FROM \`$steamId\` WHERE \`date\` = '${dateArray[i]}' AND \`appid\` = $appId" trackedtimes | grep -vi 'id' | awk -F\\t '{print $5}')
			#echo "---TPA1--"
			#echo "TPA: $timePlayedArray"
			#echo "---TPA---"

			#for timePlayed in $(echo $timePlayedArray); do
			#echo "RPT+TP:$recentPlayedTotal + $timePlayed"
			echo "TP:$timePlayed"
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
			echo -n "<td class='$tdclass' title='<?php echo round($timePlayed/60,2) ?>'> </td>" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
			#echo "<td>$timePlayed ;$i</td>" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
			#done
		elif [ $(date -d ${dateArray[i]} +%s) -eq $(date -d $dateJoined +%s) ]; then
			#print "joined!!"
			echo "<td class='joined' title='Joined!'></td>" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
		else
			#print n/a
			echo "<td class='na' title='N/A'></td>" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
		fi
	done
        echo "<td class='id'><?php echo round($recentPlayedTotal/60,2) ?></td>"  >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
	totalPlayed=$(mysql -u loser -pDupa1234 -e "SELECT \`playedtotal\` FROM \`trackedtimes\`.\`$steamId\` WHERE \`appid\` = '$appId' ORDER BY \`playedtotal\` DESC LIMIT 1" trackedtimes | grep -vi 'played')
        echo "<td class='total'><?php echo round($totalPlayed/60,2) ?></td>" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
#	echo "<td class='id'>x</td>"  >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
#	echo "<td class='total'>y</td>" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"

        echo "</tr>">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
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
#			echo "<td class='game'><img class='imglarge' src='https://steamcdn-a.akamaihd.net/steam/apps/$appId/capsule_231x87.jpg'></td>">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
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
#						echo -n "<td class='$tdclass'><?php echo round($timePlayed/60,2) ?></td>" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
#					else
#
#						echo "<td class='na'>N/A</td>" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
#					fi
#				elif [ $(date -d ${dateArray[i]} +%s) -eq $(date -d $dateJoined +%s) ]; then
#					echo "<td class='joined'>Joined!</td>" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
#				else
#					echo "<td class='na'>N/A</td>" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
#				fi
#			done
#
#			echo "<td class='id'><?php echo round($recentPlayedTotal/60,2) ?></td>"  >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
#			echo "<td class='total'><?php echo round($totalPlayed/60,2) ?></td>" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
#
#			echo "</tr>">>  "/var/www/html/steamtracker/$steamName-$steamId.php"
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
#		echo "<tr><td>$appId</td><td>$gameTitle</td><td></td><td></td><td></td><td></td><td>$thisDayPlayed</td><td></td></tr>" >>  /var/www/html/steamtracker/$steamName-$steamId.php
#	fi
#	echo $line >>  /var/www/html/steamtracker/$steamName-$steamId.php
#done < $pathToPlayed

echo "</table></div><div class='rightmain'>" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"


echo "<div class='userinfo'><div class='username'>$(tail -1 $pathToScript/users/$steamId/userinfo.txt | awk -F';' '{print $2}')</div>"  >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "<div class='datejoined'>Joined @ $dateJoined</div></div>"  >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
#BUILD TOP 5 OVERALL
#SELECT * FROM (SELECT `id`,MAX(date),`appid`,`playedtotal` FROM `trackedtimes`.`76561198000030995` GROUP BY `appid`) tmp ORDER BY `playedtotal` DESC
#echo "<br>TOP 5 OVERALL<br>"  >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "<div class='top5'><table class='top5'>" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
counter=0
while read i; do #for i in $(cat /var/www/html/steamtracker/$steamId/top5-ever.txt | head -5); do
	counter=$(($counter + 1))
#	echo "<tr><td>$i</td></tr>" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
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

		echo "<tr><td class='top5game'><img class='top5' src='https://steamcdn-a.akamaihd.net/steam/apps/$appId/capsule_231x87.jpg'></td><td id='larger' class=\"$tdclass\"><?php echo round($timePlayed/60,2) ?></td></tr>" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
#echo "<tr><td class='top5game'><img class='top5' src='https://steamcdn-a.akamaihd.net/steam/apps/$appId/capsule_231x87.jpg'></td><td id='larger' class=\"$tdclass\">z</td></tr>" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
	fi
	if [ $counter -gt 5 ]; then
		break
	fi
done < $pathToScript/users/$steamId/top5-ever.txt
echo "</table></div>" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
#BUILD TOP 5 each month
#echo "<br>TOP 5 MONTH<br>">> "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "<div class='top5'><table class='top5'>" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
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
		echo "<tr><td class='top5game'><img class='top5' src='https://steamcdn-a.akamaihd.net/steam/apps/$appId/capsule_231x87.jpg'></td><td id='larger' class=\"$tdclass\"><?php echo round($timePlayed/60,2) ?></td></tr>" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
#echo "<tr><td class='top5game'><img class='top5' src='https://steamcdn-a.akamaihd.net/steam/apps/$appId/capsule_231x87.jpg'></td><td id='larger' class=\"$tdclass\">f</td></tr>" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"

#		echo "<tr><td>$appId</td><td>$gameName</td><td>$gameTime</td></tr>" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
	fi
done < /home/osmc/git/steamtracker/users/$steamId/2019-08-top5.txt
echo "</table></div>" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "</div></div>" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"

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
" >>  "/var/www/html/steamtracker/$steamName-$steamId.php"

echo "</body></html>"  >>  "/var/www/html/steamtracker/$steamName-$steamId.php"
echo "Generated website: $steamName-$steamId.php"

echo > /var/www/html/steamtracker/all.php
#for y in /var/www/html/steamtracker/*; do

$pathToScript/makeallphp.sh
#ls -1 /var/www/html/steamtracker/ | while read y; do
#	echo "Y: $y"
#	if [[ $y != "all.php" ]] && [[ $y == *".php"* ]] && [[ $y != *"-raw.php"* ]] && [[ $y != "" ]]; then
#		echo "Y2: $y"
#		echo "<p><a href='$y'>$y</a></p>" >> /var/www/html/steamtracker/all.php
#	fi
#done


