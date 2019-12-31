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
for i in $(ls /home/osmc/git/steamtracker/users); do
	echo "Getting site for: $i"
	/home/osmc/git/steamtracker/site2DB.sh $i
	#/home/osmc/git/steamtracker/getsite.sh $i
	echo "Calculating months for: $i"
#	/home/osmc/git/steamtracker/calcMonth.sh $i
	/home/osmc/git/steamtracker/calcMonthFromDB.sh $i
	echo "Generating website for: $i"
	/home/osmc/git/steamtracker/genWebSmallFromDB.sh $i
#	/home/osmc/git/steamtracker/generateWeb.sh $i
done

