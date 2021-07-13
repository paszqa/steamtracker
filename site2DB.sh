#!/bin/bash

#########################################################################

#Set variables
if [ -z $2 ]; then
        currentDate=$(date +%Y-%m-%d)
else
        currentDate=$2
fi
	#currentDate=$(date +%Y-%m-%d)
previousDate=$(date -d "$currentDate -1 day" +%Y-%m-%d)
pathToScript="/home/pi/steamtracker"
	#pasza
	#steamId=76561198000030995
	#pri
	#steamId=76561197994977404
steamId=$1
filename=$pathToScript/users/$steamId/site_$currentDate.xml
filenameTemp=$pathToScript/users/$steamId/tmp_$currentDate.xml
joinedDate=$(cat $pathToScript/users/$steamId/datejoined.txt)
currentMonth=$(echo $currentDate | awk -F'-' '{print $1"-"$2}')
joinedMonth=$(echo $joinedDate | awk -F'-' '{print $1"-"$2}')
#filenamePrevTemp=$pathToScript/users/$steamId/tmp_$previousDate.xml
#########################################################################
#Get user info (run script)
$pathToScript/getuserinfo.sh $steamId

##########################################################################
#Create dir for steam users if doesn't exist
mkdir -p $pathToScript/users/$steamId
#Get user info to file (name on steam)
$pathToScript/getuserinfo.sh $steamId
#Get file from Steam API and preare formatted tmp file
if [ -f "$filename" ]; then
	echo "File already exists: $filename"
else
	echo -n "Getting file from Steam API to: $filename..."
	curl "http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=EB73438BE5A148D08473BFDFC8D6EEBC&steamid=$steamId&format=xml&include_appinfo=1&include_played_free_games=1" > $filename
	#REMOVE NEWLINES AND TABS AND SHIT
	cat $filename |grep -ivE "xml version|game_count|response>|<games>|</games>|<message>"|tr -d '\n'|tr -d '\t' > $filenameTemp
	#ADD NEWLINES TO XML AT END OF MESSAGE
	sed -i 's#</message>#</message>\n#g' $filenameTemp
	#REMOVE AMPS
	sed -i 's#\&amp;#\&#g' $filenameTemp
	#FIX APOSTROPHES
	sed -i "s#\&apos;#'#g" $filenameTemp
	echo "Done."
fi

#cat todaysite_nospaces.xml | awk -F'</message>' '{print $2}'|awk -F'appid>' '{print $2}'|tr -d '<'|tr -d '/'; echo ""
echo -n "Checking if DB exists..."
mysql -u loser -pdupa -e "CREATE TABLE IF NOT EXISTS \`$steamId\` ( \`id\` INT NOT NULL AUTO_INCREMENT , \`date\` DATE NOT NULL , \`appId\` INT NOT NULL , \`playedTotal\` INT NOT NULL , \`playedToday\` INT NOT NULL, \`playedThisMonth\` INT NOT NULL, PRIMARY KEY (\`id\`)) ENGINE = InnoDB;" trackedtimes
echo -n "Analyzing $filenameTemp..."
while read line; do
        if [[ $line != "" ]] && [[ $line != " " ]]; then
		#set vars for current line
                appId=$(echo $line|awk -F'appid>' '{print $2}'|tr -d '<'|tr -d '/')
                todayGameTime=$(echo $line|awk -F'playtime_forever>' '{print $2}'|tr -d '<'|tr -d '/')
                gameTitle=$(echo $line|awk -F'name>' '{print $2}'|tr -d '<'|tr -d '/')
                folder=$pathToScript/users/$steamId/$appId
                mkdir -p $folder
		
		echo " "
		echo "----------------------------------"
		echo "appId: "$appId
		echo "todayGameTime: "$todayGameTime
		echo "gameTitle: "$gameTitle
		#check if previous datefile exists, if not, set yesterday to 0
#		mysql -u loser -pDupa1234 -e "SELECT \`playedToday\` FROM \`76561198034881605\` WHERE \`appId\` = '286160' ORDER BY \`date\` DESC LIMIT 1" trackedtimes| grep -vi 'played'
#		echo "mysql -u loser -pDupa1234 -e \"SELECT \`playedTotal\` FROM \`$steamId\` WHERE \`appId\` = '$appId' ORDER BY \`date\` DESC LIMIT 1\" trackedtimes| grep -vi 'played'"
#		echo "---------"
		#queryResult=$(mysql -u loser -pDupa1234 -e "SELECT \`playedTotal\` FROM \`$steamId\` WHERE \`appId\` = '$appId' AND \`date\` < '$currentDate' ORDER BY \`date\` DESC LIMIT 1" trackedtimes| grep -vi 'played')
		queryResult=$(mysql -u loser -pdupa -e "SELECT \`playedTotal\` FROM \`$steamId\` WHERE \`appId\` = '$appId' ORDER BY \`date\` DESC LIMIT 1" trackedtimes| grep -vi 'played')
		

		queryResultLines=$(echo $queryResult | wc -l)
#		echo "QR:$queryResult"
#		echo "--"
#		echo "QRL:$queryResultLines"
		if [[ $(echo $queryResult | wc -l) -lt 1 ]] || [[ $queryResult -eq "" ]]; then
			yesterdayGameTime=0
		else
			yesterdayGameTime=$queryResult
		fi

		###PLAYED THIS MONTH
		echo "Start - 1"
		if [ $currentDate == $joinedDate ]; then
			echo "Step 1.5"
			lastMonthTotal=$todayGameTime
			playedTodayOnly=0
			echo "Step 1.5: "$lastMonthTotal
		elif [ $joinedMonth == $currentMonth ]; then
			echo "Step 2"
			lastMonthTotal=$(mysql -uloser -pdupa -e "SELECT \`playedTotal\` FROM \`$steamId\` WHERE \`appId\` = '$appId' AND \`date\` = '$joinedDate'" trackedtimes|grep -vi played)
			echo "Step 2: "$lastMonthTotal
		else
			echo "Step 3"
			lastDayOfPreviousMonth=$(mysql -u loser -pdupa -e "SELECT LAST_DAY('$currentDate' - INTERVAL 1 MONTH)" trackedtimes |grep -vi last);
			echo "LAST DAY OF PREV:"$lastDayOfPreviousMonth" STEAMID:"$steamId" APPID:"$appId
			lastMonthTotal=$(mysql -u loser -pdupa -e "SELECT \`playedTotal\` FROM \`$steamId\` WHERE \`appId\` = '$appId' AND \`date\` <= $lastDayOfPreviousMonth ORDER BY \`date\` DESC LIMIT 1" trackedtimes)
		fi
		echo "Step 4"
#		if [ $(echo $lastMonthTotal|wc -l) -lt 1 ]; then
		if [ -z $lastMonthTotal ]; then 
			echo "Step 5"
			lastMonthTotal=0
		fi
		echo "PTM start"
		echo "LMT:::"$lastMonthTotal
		playedThisMonth=$(echo "$todayGameTime - $lastMonthTotal"|bc)
		echo "PTM:::: "$playedThisMonth
#		filenamePrev="$pathToScript/users/$steamId/$appId/$previousDate"
#                if [ -f "$filenamePrev" ]; then
#                        yesterdayGameTime=$(cat $filenamePrev| awk -F";" '{ print $3 }')
#                else
#                        yesterdayGameTime=0
#                fi
#		echo "$todayGameTime - $yesterdayGameTime"
#		echo "$todayGameTime - $yesterdayGameTime" | bc
		if [ $currentDate != $joinedDate ]; then
			echo "Step 6.1"
	                playedTodayOnly=$(echo "$todayGameTime - $yesterdayGameTime" | bc)
		else
			echo "Step 6.2"
			playedTodayOnly=0
		fi

                #write game info
                echo $gameTitle > $pathToScript/users/$steamId/$appId/info.txt
                #write playtime info to DB
                #echo "$currentDate;$playedTodayOnly;$todayGameTime" > $pathToScript/users/$steamId/$appId/$currentDate
#		echo "LINE:$line"
		echo "TGT:$todayGameTime"
		echo "YGT:$yesterdayGameTime"
#		echo "QR:$queryResult"
		echo "PTO:$playedTodayOnly"
		echo "PTM:$playedThisMonth"
		echo "CD: $currentDate"
		echo "DJ: "$(cat $pathToScript/users/$steamId/datejoined.txt)
		if [ $playedTodayOnly -gt 0 ] || ([ $todayGameTime -gt 0 ] && [ $currentDate == $joinedDate ]); then
			echo "Step 7"
			if [ $(mysql -u loser -pdupa -e "SELECT * FROM \`$steamId\` WHERE \`appId\` = '$appId' AND \`date\` = '$currentDate'" trackedtimes | grep -vi 'id'| wc -l) -lt 1 ]; then
				echo "Step 8 - "$currentDate
				mysql -u loser -pdupa -e "INSERT INTO \`$steamId\` (\`date\`, \`appId\`, \`playedTotal\`, \`playedToday\`, \`playedThisMonth\`) VALUES ('$currentDate', '$appId', '$todayGameTime', '$playedTodayOnly', '$playedThisMonth'); " trackedtimes
#			else
#				 mysql -u loser -pDupa1234 -e "DELETE FROM \`$steamId\` WHERE \`appId\` = '$appId' AND \`date\` = '$currentDate'" trackedtimes
#				 mysql -u loser -pDupa1234 -e "INSERT INTO \`$steamId\` (\`id\`, \`date\`, \`appId\`, \`playedTotal\`, \`playedToday\`) VALUES ('', '$currentDate', '$appId', '$todayGameTime', '$playedTodayOnly'); " trackedtimes

			fi
		fi
        fi
done < $filenameTemp
echo "Done."

