#!/bin/bash

# Specify AppDir directory for AppImage data
APPDIR=rssPresso.AppDir

# Bundle information for deleting previous bundles
DATA=data
LIB=lib
EXECUTABLE=rsspresso

# Go to the AppImage data directory 
cd $APPDIR

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

# Go to installers/AppImage directory
cd ..

# Specify the final app name
FINAL=rssPresso-Linux.AppImage

# If the final app exists, remove it
if [ -f $FINAL ]; then
    rm $FINAL
fi
