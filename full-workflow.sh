#!/bin/bash
#Pasza
#/home/osmc/git/steamtracker/getsite.sh 76561198000030995
#Pribovich
#/home/osmc/git/steamtracker/getsite.sh 76561197994977404
#Vyqe
#/home/osmc/git/steamtracker/getsite.sh 76561198004729616
#random z neta
#/home/osmc/git/steamtracker/getsite.sh 76561198260204439
#Trauma
#/home/osmc/git/steamtracker/getsite.sh 76561198034881605
#Rathma
#/home/osmc/git/steamtracker/getsite.sh 76561198009810227
pathToScript="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
dbuser=$1
dbpass=$2
if [ -z $3 ]; then
	for i in $(ls $pathToScript/users); do
		echo "Getting site for: $i"
		$pathToScript/site2DB.sh $i $1 $2
		echo "Calculating months for: $i"
		$pathToScript/calcMonthFromDB.sh $i $1 $2
		echo "Generating website for: $i"
		$pathToScript/genWebSmallFromDB.sh $i $1 $2
	done
else
	i=$3
	echo "Getting site for: $i"
	$pathToScript/site2DB.sh $i $1 $2
	echo "Calculating months for: $i"
	$pathToScript/calcMonthFromDB.sh $i $1 $2
	echo "Generating website for: $i"
	$pathToScript/genWebSmallFromDB.sh $i $1 $2
fi

