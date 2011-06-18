#!/bin/sh
rm -f redtk
xcodebuild && ln -s build/Release/redtoolkit redtk && echo "build finished. have fun with ./redtk"

