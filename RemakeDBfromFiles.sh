/bin/bash
#change user id
steamId=$1
ls users/$steamId/site_* |awk -F'/site_' '{print $2}'|awk -F'.xml' '{print $1}'|while read line ; do echo ./site2DB.sh $steamId $line ; done
