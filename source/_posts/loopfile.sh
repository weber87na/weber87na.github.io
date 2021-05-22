#!/bin/bash
FILES=$(ls *.md)
for f in $FILES
do
	# echo "Processing $f file..."
	echo "sed ':a;N;\$!ba; s/---/---\n\&nbsp;\n<!-- more -->/2' $f > $f-changed.txt && mv $f-changed.txt $f"
	# take action on each file. $f store current file name
	# cat $f
done
