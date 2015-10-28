#!/bin/sh

# Build the portable Git Shell

test -z "$1" && {
	echo "Usage: $0 <version> [optional components]"
	exit 1
}

die () {
	echo "$*" >&1
	exit 1
}

ARCH="$(uname -m)"
case "$ARCH" in
i686)
	BITNESS=32
	;;
x86_64)
	BITNESS=64
	;;
*)
	die "Unhandled architecture: $ARCH"
	;;
esac
VERSION=$1
shift
TARGET="$HOME"/PortableGit.7z
OPTS7="-m0=lzma -mx=9 -md=64M"
#TMPPACK=/tmp.7z
SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)"

case "$SCRIPT_PATH" in
*" "*)
	die "This script cannot handle spaces in $SCRIPT_PATH"
	;;
esac


# Generate a couple of files dynamically

mkdir -p "$SCRIPT_PATH/root/etc" ||
die "Could not make etc/ directory"

mkdir -p "$SCRIPT_PATH/root/tmp" ||
die "Could not make tmp/ directory"

cp $SCRIPT_PATH/../post-install.bat $SCRIPT_PATH/root/ ||
die "Could not copy post-install script"

# Make a list of files to include
LIST="$(ARCH=$ARCH BITNESS=$BITNESS \
	PACKAGE_VERSIONS_FILE="$SCRIPT_PATH"/root/etc/package-versions.txt \
	sh "$SCRIPT_PATH"/../make-file-list.sh "$@")" ||
die "Could not generate file list"

# fingerprint the tip so we can version this installer correctly
git rev-parse HEAD | tr -d '\n' > "$SCRIPT_PATH/root/VERSION"

# 7-Zip will strip absolute paths completely... therefore, we can add another
# root directory like this:

LIST="$LIST $SCRIPT_PATH/root/*"

# Make the self-extracting package

type 7za ||
pacman -Sy --noconfirm p7zip ||
die "Could not install 7-Zip"

cd / && 7za a $OPTS7 $TARGET $LIST
echo "Success! You will find the new installer at \"$TARGET\"."

rm -rf $SCRIPT_PATH/root 