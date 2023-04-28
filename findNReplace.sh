#!/bin/bash
#Author:skondla@me.com
#Purpose: Find and replace a string recursively in all directories under current directory

find . -type f -name "*.sh" -print0 | xargs -0 sed -i '' -e 's/myDB/newDB/g'
