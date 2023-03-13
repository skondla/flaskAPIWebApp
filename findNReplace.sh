#!/bin/bash
#Author:skondla@me.com
#Purpose: Find and replace a string recursively in all directories under current directory

find . -type f -name "*.sh" -print0 | xargs -0 sed -i '' -e 's/myDB/newDB/g'


#find . -type f -name "*.sh" | xargs -0 sed -i '' -e 's/mydb1/myDB/g'
#find . -type f -name "*.sh" -print0 | xargs -0 sed -i '' -e 's/mydb1/myDB/g'
#find . -type f -name "*.py" -print0 | xargs -0 sed -i '' -e 's/mydb1/myDB/g'
#find . -type f -name "*.sh" -print0 | xargs -0 sed -i '' -e 's/mydb1/myDB/g'
#find . -type f -name "*.org" -print0 | xargs -0 sed -i '' -e 's/mydb1/myDB/g'
#find . -type f -name "*.old" -print0 | xargs -0 sed -i '' -e 's/mydb1/myDB/g'
#find . -type f -name "*.sh*" -print0 | xargs -0 sed -i '' -e 's/mydb1/myDB/g'
#find . -type f -name "*.cron*" -print0 | xargs -0 sed -i '' -e 's/mydb1/myDB/g'
#find . -type f -name "cron.*" -print0 | xargs -0 sed -i '' -e 's/mydb1/myDB/g'
#find . -type f -name "cron*.*" -print0 | xargs -0 sed -i '' -e 's/mydb1/myDB/g'
#find . -type f -name "*.sql" -print0 | xargs -0 sed -i '' -e 's/mydb1/myDB/g'
#find . -type f -name "README.md" -print0 | xargs -0 sed -i '' -e 's/mydb1/myDB/g'