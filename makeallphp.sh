#!/bin/bash
pathToWebDir="/var/www/localhost/steamtracker"
echo > $pathToWebDir/all.html
ls -1 $pathToWebDir/ | while read y; do
#        echo "Y: $y"
#       if [[ $y != "all.php" ]] && [[ $y == *".php"* ]] && [[ $y != "-raw.php" ]]; then
	if [[ $y != "all.html" ]] && [[ $y == *".html"* ]] && [[ ${y} != *"-raw.php"* ]] && [[ $y != *"top5-ever.php"* ]]; then
#                echo "........Y2: $y"
                echo "<p><a href='$y'>$y</a></p>" >> $pathToWebDir/all.html
        fi
done
