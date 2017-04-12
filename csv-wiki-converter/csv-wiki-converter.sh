#!/bin/bash

printUsage(){
	echo "Usage:"
	echo "csv-wiki-converter.sh INPUTFILE OUTPUTFILE"
	echo "Use semicolon as field separator"
	echo "Make sure there is no semicolon contained in your data"
}

# Check for parameters
if [ "$#" -ne 2 ]
	then 
		printUsage
		echo "Missing or too many Arguments"
		exit 1
fi

# Environment
configfile=settings.cfg
INPUT="$1"
OUTPUT="$2"
index=1
class=$(egrep "^class=.*$" $configfile | sed 's/class=//g')
sortable=$(egrep "^sortable=.*$" $configfile | sed 's/sortable=//g')
first=1

# Unify encoding
dos2unix $INPUT > /dev/null 2>&1

# Read from settings
if [ $sortable -eq 1 ]; then
	sortable="sortable "
else
	sortable=""
fi

echo "{| class=\"$sortable$class\"" >> $OUTPUT

# Read through input csv
cat "$INPUT" | while read LINE; do
	# First line for table header
	if [ $first -eq 1 ]; then
		prefix="!|"
		first=0
	else 
		prefix="||"
	fi
	# Get amount of fields
	counter=$(echo "$LINE" | awk 'BEGIN{ FS = ";" } ; { print NF }')
	# Go through each field
	for i in $(seq 1 $counter); do
		field=$(echo "$LINE" | awk 'BEGIN { FS = ";" } ; { print $"'"$index"'" }')
		echo "$prefix $field" >> $OUTPUT
		index=$(($index+1))
	done
		echo "|-" >> $OUTPUT
	# Reset index
	index=1
done

echo "|}" >> $OUTPUT
