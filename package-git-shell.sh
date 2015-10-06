SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)"

# use the current git version as the installer version
gitversion=$(git --version | egrep -o '[0-9]*.[0-9]*.[0-9]*.windows.[0-9]*')
version="${gitversion/windows./}"

# run the portable installer
$SCRIPT_PATH/git-shell/release.sh $version git-tfs github-extra