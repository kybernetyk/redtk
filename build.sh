#!/bin/sh
rm -f redtk
xcodebuild && ln -s build/Release/redtk redtk && echo "build finished. have fun with ./redtk"

