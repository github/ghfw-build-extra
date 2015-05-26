SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)"

# update any/all upstream packages
pacman -Syu --noconfirm 

# add git-tfs to the environment
echo "installing git-tfs pre-requisite..."
pushd git-tfs > /dev/null
makepkg -f
gitTfsPackage=$(ls -t git-tfs-* | head -n 1)
pacman -U --noconfirm $gitTfsPackage
popd

# add github-extra to the environment
echo "installing github-extra pre-requisite..."
pushd github-extra > /dev/null
makepkg -f
githubExtraPackage=$(ls -t github-extra-* | head -n 1)
pacman -U --noconfirm $githubExtraPackage
popd

# use the current git version as the installer version
gitversion=$(git --version | egrep -o '[0-9]*.[0-9]*.[0-9]*.windows.[0-9]*')
version="${gitversion/windows./}"

# run the portable installer
$SCRIPT_PATH/portable/release.sh $version git-tfs github-extra