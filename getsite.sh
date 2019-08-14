#!/bin/bash

#Set variables
currentDate=$(date +%Y-%m-%d)
#pasza
#steamId=76561198000030995
#pri
#steamId=76561197994977404
steamId=$1
filename=$steamId/site_$currentDate.xml
filenameTemp=$steamId/tmp_$currentDate.xml
#Filesystem ops
mkdir -p $steamId
rm -f report
touch report
curl "http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=EB73438BE5A148D08473BFDFC8D6EEBC&steamid=$steamId&format=xml&include_appinfo=1&include_played_free_games=1" > $filename
#REMOVE NEWLINES AND TABS AND SHIT
cat $filename |grep -ivE "xml version|game_count|response>|<games>|</games>|<message>"|tr -d '\n'|tr -d '\t' > $filenameTemp
#ADD NEWLINES TO XML AT END OF MESSAGE
sed -i 's#</message>#</message>\n#g' $filenameTemp
#REMOVE AMPS
sed -i 's#\&amp;#\&#g' $filenameTemp
#FIX APOSTROPHES
sed -i "s#\&apos;#'#g" $filenameTemp

#cat todaysite_nospaces.xml | awk -F'</message>' '{print $2}'|awk -F'appid>' '{print $2}'|tr -d '<'|tr -d '/'; echo ""
while read line; do
#	echo "X"
#	echo "RUN: $line" >> ids_only
	if [[ $line != "" ]] && [[ $line != " " ]]; then
		appId=$(echo $line|awk -F'appid>' '{print $2}'|tr -d '<'|tr -d '/')
		playtime=$(echo $line|awk -F'playtime_forever>' '{print $2}'|tr -d '<'|tr -d '/')
		gameTitle=$(echo $line|awk -F'name>' '{print $2}'|tr -d '<'|tr -d '/')
		mkdir -p $steamId/$appId
		echo $gameTitle > $steamId/$appId/info.txt
		echo "$currentDate;$playtime" > $steamId/$appId/$currentDate
	fi
done < $filenameTemp

