#!/bin/bash

# Specify the output name
OUTPUT=rssPresso-Linux-Portable.tar.gz
FINAL=../../../../../installers/rssPresso-Linux-Portable.tar.gz

# Go into bundle directory and create the archive
cd ../build/linux/x64/release/bundle
tar -czf $OUTPUT data lib rsspresso

# If creating the archive was successful, move the archive
if [ -f "$OUTPUT" ]; then
    mv $OUTPUT $FINAL
fi
