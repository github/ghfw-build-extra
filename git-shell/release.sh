#!/bin/sh

# Build the portable Git Shell

die () {
	echo "$*" >&1
	exit 1
}

output_directory="$HOME"
while test $# -gt 0
do
	case "$1" in
	--output)
		shift
		output_directory="$1"
		;;
	--output=*)
		output_directory="${1#*=}"
		;;
	-*)
		die "Unknown option: $1"
		;;
	*)
		break
	esac
	shift
done

test $# -gt 0 ||
die "Usage: $0 [--output=<directory>] <version> [optional components]"

test -d "$output_directory" ||
die "Directory inaccessible: '$output_directory'"

ARCH="$(uname -m)"
case "$ARCH" in
i686)
	BITNESS=32
	MD_ARG=128M
	;;
x86_64)
	BITNESS=64
	MD_ARG=256M
	;;
*)
	die "Unhandled architecture: $ARCH"
	;;
esac
VERSION=$1
shift
TARGET="$output_directory"/PortableGit.7z
OPTS7="-m0=lzma -mx=9 -md=$MD_ARG -mfb=273 -ms=256M "

SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)"

case "$SCRIPT_PATH" in
*" "*)
	die "This script cannot handle spaces in $SCRIPT_PATH"
	;;
esac


# Generate a couple of files dynamically

cp "$SCRIPT_PATH/../LICENSE.txt" "$SCRIPT_PATH/root/" ||
die "Could not copy license file"

mkdir -p "$SCRIPT_PATH/root/etc" ||
die "Could not make etc/ directory"

mkdir -p "$SCRIPT_PATH/root/tmp" ||
die "Could not make tmp/ directory"

mkdir -p "$SCRIPT_PATH/root/bin" ||
die "Could not make bin/ directory"

cp /cmd/git.exe "$SCRIPT_PATH/root/bin/git.exe" &&
cp /mingw$BITNESS/share/git/compat-bash.exe "$SCRIPT_PATH/root/bin/bash.exe" &&
cp /mingw$BITNESS/share/git/compat-bash.exe "$SCRIPT_PATH/root/bin/sh.exe" ||
die "Could not install bin/ redirectors"

cp "$SCRIPT_PATH/../post-install.bat" "$SCRIPT_PATH/root/" ||
die "Could not copy post-install script"

mkdir -p "$SCRIPT_PATH/root/mingw$BITNESS/etc" &&
cp /mingw$BITNESS/etc/gitconfig \
	"$SCRIPT_PATH/root/mingw$BITNESS/etc/gitconfig" &&
git config -f "$SCRIPT_PATH/root/mingw$BITNESS/etc/gitconfig" \
	credential.helper manager ||
die "Could not configure Git-Credential-Manager as default"

# Make a list of files to include
LIST="$(ARCH=$ARCH BITNESS=$BITNESS \
	PACKAGE_VERSIONS_FILE="$SCRIPT_PATH"/root/etc/package-versions.txt \
	sh "$SCRIPT_PATH"/../make-file-list.sh "$@" |
	grep -v "^mingw$BITNESS/etc/gitconfig$")" ||
die "Could not generate file list"

rm -rf "$SCRIPT_PATH/root/mingw$BITNESS/libexec/git-core" &&
mkdir -p "$SCRIPT_PATH/root/mingw$BITNESS/libexec/git-core" &&
ln $(echo "$LIST" | sed -n "s|^mingw$BITNESS/bin/[^/]*\.dll$|/&|p") \
	"$SCRIPT_PATH/root/mingw$BITNESS/libexec/git-core/" ||
die "Could not copy .dll files into libexec/git-core/"

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