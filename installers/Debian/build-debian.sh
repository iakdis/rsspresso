#!/bin/bash

# Specify opt and bin directory for binary data
OPT=rssPresso/opt/rsspresso
BIN=rssPresso/usr/bin

# Bundle information for deleting previous bundles
DATA=data
LIB=lib
EXECUTABLE=rsspresso
INSTALLERS=installers/Debian

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

# Go to Flutter project directory (rsspresso/opt/rssPresso/Debian/installers)
cd ../../../../..

# Copy final bundle into opt directory
cp -r build/linux/x64/release/bundle/* $INSTALLERS/$OPT

# Specify the automatically generated output name in addition to the final name to which the file will be renamed to
OUTPUT=rssPresso.deb
FINAL=../rssPresso-Linux.deb
EXEC=$BIN/rsspresso

cd $INSTALLERS

# Delete old link
if [ -f $EXEC ]; then
    rm $EXEC
fi

# Create link
cd $BIN
ln -s ../../opt/rsspresso/rsspresso rsspresso
cd ../../..

# Build Debian package
dpkg-deb --build rssPresso

# If the build was successful, rename the .deb file
if [ -f "$OUTPUT" ]; then
    mv $OUTPUT $FINAL
fi
