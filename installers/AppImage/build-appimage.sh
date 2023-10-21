#!/bin/bash

# Specify AppDir directory for AppImage data
APPDIR=rssPresso.AppDir

# Bundle information for deleting previous bundles
DATA=data
LIB=lib
EXECUTABLE=rsspresso
INSTALLERS=installers/AppImage

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

# Go to Flutter project directory (AppImage/installers/rsspresso)
cd ../../..

# Copy final bundle into installer directory
cp -r build/linux/x64/release/bundle/* $INSTALLERS/$APPDIR

# Specify the automatically generated output name in addition to the final name to which the file will be renamed to
OUTPUT=rssPresso-x86_64.AppImage
FINAL=../rssPresso-Linux.AppImage
APPIMAGETOOL=appimagetool-x86_64.AppImage
DESKTOP=com.iakmds.rssPresso.desktop

cd $INSTALLERS

# Update duplicate desktop file inside usr/share
cp -f $APPDIR/$DESKTOP $APPDIR/usr/share/applications

# If the appimagetool does not exist in this directory, download it and make it executable
if ! [ -f $APPIMAGETOOL ]; then
    wget "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
    chmod a+x $APPIMAGETOOL
fi

# If the appimagetool exists by now, try to build the AppImage
if [ -f $APPIMAGETOOL ]; then
    ./$APPIMAGETOOL $APPDIR

    # If the build was successful, rename the AppImage
    if [ -f "$OUTPUT" ]; then
        mv $OUTPUT $FINAL
    fi
else
    echo "Build was not successful"
fi
