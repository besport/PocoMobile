#!/bin/bash

# Author: François-Xavier Thomas <fx.thomas@gmail.com>
# Author: Be Sport 2012

# Update Poco
git submodule update

# Build Poco
cd Source/

# Build iPhone libraries
./configure --config=iPhone --no-tests --no-samples --omit=...
make IPHONE_SDK_VERSION_MIN=3.0 POCO_TARGET_OSARCH=armv6 -s -j2
make IPHONE_SDK_VERSION_MIN=3.2 POCO_TARGET_OSARCH=armv7 -s -j2
make IPHONE_SDK_VERSION_MIN=3.2 POCO_TARGET_OSARCH=armv7s -s -j2

# Build iPhone simulator libraries
./configure --config=iPhoneSimulator --no-tests --no-samples --omit=...
make -s -j2
