#!/bin/bash

# Specify opt and bin directory for binary data
OPT=rssPresso/opt/rsspresso
BIN=rssPresso/usr/bin

# Bundle information for deleting previous bundles
DATA=data
LIB=lib
EXECUTABLE=rsspresso

# Go to the opt directory
cd $OPT

# Remove data folder, if it exists
if [ -d $DATA ]; then
    rm -r $DATA
fi

# Remove lib folder, if it exists
if [ -d $LIB ]; then
    rm -r $LIB
fi

# Remove executable, if it exists
if [ -f $EXECUTABLE ]; then
    rm $EXECUTABLE
fi

# Go to Debian project directory (rsspresso/opt/rssPresso)
cd ../../..

# Define link
EXEC=$BIN/rsspresso

# Delete old link, if it exists
if [ -L $EXEC ]; then
    rm $EXEC
fi

# Specify the final app name
FINAL=rssPresso-Linux.deb

# If the final app exists, remove it
if [ -f $FINAL ]; then
    rm $FINAL
fi
