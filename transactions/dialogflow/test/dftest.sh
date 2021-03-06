#!/bin/bash

# Keep track of PWD, before switching to script directory
# All commands are run relative to script directory
OLD_DIR=$PWD
CURRENT_DIR=$(dirname "$BASH_SOURCE")
cd $CURRENT_DIR

# Unzip zipped agent to ensure same as unzipped
echo "Checking zipped and unzipped agents are identical..."
unzip ../agent.zip -d _test_unzipped > /dev/null 2>&1
agent_diff=$(diff -r _test_unzipped ../agent)
if [[ $? != 0 ]]; then
    echo "Error: Make sure the zipped and unzipped agents are identical"
    rm -rf _test_unzipped
    exit 1
fi
echo "Success: Agents are identical"
rm -rf _test_unzipped

# Check whether strings match intents as intended
# Currently does a very naive grep for string inclusion
dialog=dialog.csv
all_intents_matched=true
OLDIFS=$IFS
IFS=,
while read training_phrase intent
do
	echo "Checking phrase $training_phrase matches $intent..."
	# Get matched filename as a string
    matched_path=$(grep $training_phrase ../agent/intents/$intent.json)
    if [[ $? != 0 ]]; then
        echo "Error: Intent not matched for $training_phrase"
        all_intents_matched=false
    fi
done < $dialog

if [[ $all_intents_matched = true ]]; then
    echo "Success: dialog.csv matched all intents"
fi
IFS=$OLDIFS

cd $OLD_DIR