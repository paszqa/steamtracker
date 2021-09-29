#!/bin/bash
steamId=$1
currentDate=$(date +%Y-%m-%d)
pathToScript="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
mkdir -p $pathToScript/users/$steamId
if [ -f $pathToScript/users/$steamId/datejoined.txt ]; then
	$pathToScript/getuserinfo.sh $steamid
	echo "User exists"
	exit 1;
else
	echo $currentDate > $pathToScript/users/$steamId/datejoined.txt
	$pathToScript/getuserinfo.sh $steamId
	exit 0;
fi
