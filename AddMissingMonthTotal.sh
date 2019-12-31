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
pathToScript="/home/osmc/git/steamtracker"
        #pasza
        steamId=76561198000030995
        #pri
        #steamId=76561197994977404
#steamId=$1

joinedDate=$(cat $pathToScript/users/$steamId/datejoined.txt)

##CHECK IF JOINED THIS MONTH
if [[ $(echo $joinedDate | awk -F'-' '{print $1"-"$2}') == $(echo $currentDate | awk -F'-' '{print $1"-"$2}') ]]; then
	lastMonthPlayed=0
	echo "THIS MONTH STARTED"
fi

##GET LAST DAY OF PREVIOUS MONTH
echo "CURR:$currentDate"
firstCurr=$(echo $currentDate | awk -F'-' '{print $1 "-" $2"-01"}')
echo "FIRST OF CURR:$firstCurr"
#lastDayOfPreviousMonth=$(mysql -uloser -pDupa1234 -e "SELECT LAST_DAY()) - INTERVAL 1 MONTH)");
#lastDayOfPreviousMonth=$(mysql -uloser -pDupa1234 -e "SELECT NOW()")
#echo "LAST: $lastDayOfPreviousMonth"
##GET LIST OF TODAY'S GAMES

for appId in $(mysql -uloser -pDupa1234 -e "SELECT \`appId\` FROM \`$steamId\` WHERE \`date\` = '$currentDate'" trackedtimes | grep -vi appid); do
	echo "X:"$appId
	if [[ $(echo $joinedDate | awk -F'-' '{print $1"-"$2}') == $(echo $currentDate | awk -F'-' '{print $1"-"$2}') ]]; then
		echo "OOO"
		lastMonthTotal=$(mysql -uloser -pDupa1234 -e "SELECT \`playedTotal\` FROM \`$steamId\` WHERE \`appId\` = '$appId' AND \`date\` = '$joinedDate'" trackedtimes|grep -vi played)
	else
		lastMonthTotal=$(mysql -uloser -pDupa1234 -e "SELECT \`playedTotal\` FROM \`$steamId\` WHERE \`appId\` = '$appId' AND \`date\` < '$firstCurr' ORDER BY \`date\` DESC LIMIT 1" trackedtimes|grep -vi played)
	fi
	if [[ -z $lastMonthTotal ]]; then
		lastMonthTotal=0
	fi
	echo "LAST M: $lastMonthTotal"
	playedTotal=$(mysql -uloser -pDupa1234 -e "SELECT \`playedTotal\` FROM \`$steamId\` WHERE \`appId\` = '$appId' AND \`date\` = '$currentDate'" trackedtimes|grep -vi played)
	echo "TOTAL: $playedTotal"
	thisMonth=$(echo "$playedTotal - $lastMonthTotal"|bc)
	echo "THIS MONTH: $thisMonth"
	echo "----------------------------------------------"
	mysql -uloser -pDupa1234 -e "UPDATE \`$steamId\` SET \`playedThisMonth\` = '$thisMonth' WHERE \`appId\` = '$appId' AND \`date\` = '$currentDate'" trackedtimes
done

#mysql -u loser -pDupa1234 -e "SELECT \`appid\`,\`playedTotal\` FROM \`$steamId\` WHERE \`date\` = '$joinedDate'" trackedtimes
#echo $debugtest
