#!/bin/bash
commit_hash="234a03d7790061aff8aed5a12850899ea6f780a7"
repo=$(printenv REPO)
cd /home/linux-cachyos_builder
git clone https://aur.archlinux.org/linux-cachyos.git &&
cd linux-cachyos
echo "Checkout specified commit..."
git checkout $commit_hash &&
echo "Compiling kernel..."
env MAKEFLAGS="-s" \ 
    _processor_opt="sandybridge" \
    _disable_debug=y \
    _NUMAdisable=y \
    _nr_cpus=4 \
    _use_auto_optimization='' \
    makepkg --nocolor --noconfirm --noprogressbar --needed --syncdeps &&
    echo "Logining in to GitHub..."
echo "file(s) size : ${du -sh ./*.pkg.tar.zst}"
printenv GITHUB_KEY | gh auth login --with-token
#version=`git log --format=%B -n 1 $commit_hash | awk -F '-' 'NR==1{print "v"$1}'`
version='6.4.3-1'
gh release view "$version" --repo "$repo"
tag_exists=$?
if test $tag_exists -eq 0; then
    echo "Tag already exists!"
    echo "Removing previous release..."
    gh release delete "$version" -y --cleanup-tag --repo "$repo"
else
    echo "Tag does not exist!"
fi
echo "Releasing $version binaries into $repo"
gh release create "$version" ./*.pkg.tar.zst --repo "$repo" &&
echo "Released!"
echo "Loging out from Github..."
gh auth logout -h github.com
