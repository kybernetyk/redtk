#!/bin/sh
rm -f red
xcodebuild && ln -s build/Release/redtk redtk && echo "build finished. have fun with ./redtk"

