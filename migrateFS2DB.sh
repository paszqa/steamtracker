#!/bin/bash
## SCRIPT TO
##MIGRATE FROM FS TO DB

steamId=$1
pathToScript="/home/osmc/git/steamtracker"
mysql -u loser -pDupa1234 -e "CREATE TABLE IF NOT EXISTS \`$steamId\` ( \`id\` INT NOT NULL AUTO_INCREMENT , \`date\` DATE NOT NULL , \`appId\` INT NOT NULL , \`playedTotal\` INT NOT NULL , \`playedToday\` INT NOT NULL , PRIMARY KEY (\`id\`)) ENGINE = InnoDB;" trackedtimes

#CREATE TABLE `1111`.`testab` ( `id` INT NOT NULL AUTO_INCREMENT , `date` DATE NOT NULL , `appId` INT NOT NULL , `playedTotal` INT NOT NULL , `playedToday` INT NOT NULL , PRIMARY KEY (`id`)) ENGINE = InnoDB;
echo "Migrating data for $steamId..."
for appId in $(ls $pathToScript/users/$steamId/ | grep -viE "csv|txt|xml"); do
	echo "AppId: $appId"
	for oneDate in $(ls $pathToScript/users/$steamId/$appId/ | grep -viE "csv|txt|xml"); do
		playedTotal=$(cat $pathToScript/users/$steamId/$appId/$oneDate | awk -F';' '{print $3}')
		playedToday=$(cat $pathToScript/users/$steamId/$appId/$oneDate | awk -F';' '{print $2}')
		if [ $playedToday -gt 0 ]; then
			if [ $oneDate == $(cat $pathToScript/users/$steamId/datejoined.txt) ]; then
				playedToday=0
			fi
			if [ $(mysql -u loser -pDupa1234 -e "SELECT * FROM \`$steamId\` WHERE \`appId\` = '$appId' AND \`date\` = '$oneDate'" trackedtimes | grep -vi 'id'| wc -l) -lt 1 ]; then
				mysql -u loser -pDupa1234 -e "INSERT INTO \`$steamId\` (\`id\`, \`date\`, \`appId\`, \`playedTotal\`, \`playedToday\`) VALUES ('', '$oneDate', '$appId', '$playedTotal', '$playedToday'); " trackedtimes
			fi
		fi
#		echo "SELECT * FROM \`$steamId\` WHERE \`appid\` = $appId; $oneDate"
		#mysql -u loser -pDupa1234 -e "SELECT * FROM \`$steamId\` WHERE `appid` = $appId;" trackedtimes
	done
done

