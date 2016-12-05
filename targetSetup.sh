#!/bin/bash

# targetSetup.sh
# FunPhotos
#
# Created by Paul Welch on 11/25/10.
# Copyright 2010 MetriWorks Inc. All rights reserved.

echo .targetSetup: $TARGET_NAME

if [ "$TARGET_NAME" = "FunPhotosLite" ]; then
	echo Copy Lite Icon
	cp icon_lite.png icon.png
else
	echo Copy Full Icon
	cp icon_full.png icon.png
fi

#
