#!/bin/bash

# Map function
# See: http://onthebalcony.wordpress.com/2008/03/08/just-for-fun-map-as-higher-order-function-in-bash/
map () {
  if [ $# -le 1 ]; then
    return
  else
    local f=$1
    local x=$2
    shift 2
    local xs=$@

    $f $x

    map "$f" $xs
  fi
}

# Find a library
# Usage: findlib Path Arch Name
findlib () {
  find -L "${1}/${2}" -name "lib${3}.a"
}

# Libraries to include inside the Framework
NAME="Poco"
INCLUDE_PATH="Includes"
LIBRARY_PATH="Libraries"
LIBRARY_NAMES="PocoFoundation PocoNet PocoJSON"
ARCHITECTURES="armv6 armv7 i686"
FRAMEWORK="Frameworks/${NAME}.framework"

# Output framework path
echo "Creating Framework at ${FRAMEWORK}"
rm -rf "${FRAMEWORK}"
mkdir -p "${FRAMEWORK}/Versions/A/Headers/"
mkdir -p "${FRAMEWORK}/Versions/A/Resources"

# Find library names
for ARCH in $ARCHITECTURES; do
  echo "Combining libraries for arch $ARCH"

  # Find library files
  LIBRARY_FILES=`map "findlib $LIBRARY_PATH $ARCH" $LIBRARY_NAMES`

  # Link them together in one fat-ass library
  libtool -static -o "$LIBRARY_PATH/$ARCH/lib${NAME}.a" $LIBRARY_FILES
done

# Generate universal library for the device and simulator
echo "Building universal library"
lipo `find -L $LIBRARY_PATH -name "lib${NAME}.a"` -create -output "${FRAMEWORK}/Versions/A/${NAME}"

# Copy headers
for LIBRARY in $LIBRARY_NAMES; do
  echo "Copying headers for ${LIBRARY}"
  cp -Rf "${INCLUDE_PATH}/${LIBRARY}/"* "${FRAMEWORK}/Versions/A/Headers/"
done

# Move files to appropriate locations in framework paths.
echo "Creating symlinks"
ln -s "A" "${FRAMEWORK}/Versions/Current" &&
ln -s "Versions/Current/Headers" "${FRAMEWORK}/Headers" &&
ln -s "Versions/Current/Resources" "${FRAMEWORK}/Resources" &&
ln -s "Versions/Current/${NAME}" "${FRAMEWORK}/${NAME}"
