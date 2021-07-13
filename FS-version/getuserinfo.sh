#!/bin/bash

#########################################################################
#Set variables
if [ -z $2 ]; then
	currentDate=$(date +%Y-%m-%d)
else
	currentDate=$2
fi
pathToScript="/home/osmc/git/steamtracker"
#pasza
#steamId=76561198000030995
#pri
#steamId=76561197994977404
steamId=$1

#########################################################################
touch $pathToScript/users/$steamId/userinfo.txt

#Check if date entry exists already
dateExists=0
for oneDate in $(cat $pathToScript/users/$steamId/userinfo.txt|grep $currentDate|awk -F';' '{print $1}'); do
	if [ $oneDate == $currentDate ]; then
		dateExists=1
	fi
done

############################################################################
#If date doesnt exist, then query for username and add it to userinfo.txt for user
if [ $dateExists != 1 ]; then
	username=$(curl -s "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=EB73438BE5A148D08473BFDFC8D6EEBC&steamids=$steamId"|awk -F'"personaname":"' '{print $2}'|awk -F'","' '{print $1}')
	echo "$currentDate;$username" >> $pathToScript/users/$steamId/userinfo.txt
fi
