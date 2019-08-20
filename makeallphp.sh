#!/bin/bash
echo > /var/www/html/steamtracker/all.php
ls -1 /var/www/html/steamtracker/ | while read y; do
#        echo "Y: $y"
#       if [[ $y != "all.php" ]] && [[ $y == *".php"* ]] && [[ $y != "-raw.php" ]]; then
	if [[ $y != "all.php" ]] && [[ $y == *".php"* ]] && [[ ${y} != *"-raw.php"* ]] && [[ $y != *"top5-ever.php"* ]]; then
#                echo "........Y2: $y"
                echo "<p><a href='$y'>$y</a></p>" >> /var/www/html/steamtracker/all.php
        fi
done
