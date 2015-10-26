# add git-tfs to the environment
echo "installing git-tfs pre-requisite..."
pushd git-tfs > /dev/null
makepkg-mingw -f
gitTfsPackage=$(ls -t git-tfs-* | head -n 1)
pacman -U --noconfirm $gitTfsPackage
popd

# add github-extra to the environment
echo "installing github-extra pre-requisite..."
pushd github-extra > /dev/null
makepkg-mingw -f
githubExtraPackage=$(ls -t github-extra-* | head -n 1)
pacman -U --noconfirm $githubExtraPackage
popd
