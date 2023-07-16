#!/bin/bash
commit_hash="234a03d7790061aff8aed5a12850899ea6f780a7"
repo=$(printenv REPO)
cd /home/linux-cachyos_builder
git clone https://aur.archlinux.org/linux-cachyos.git &&
cd linux-cachyos
echo "Checkout specified commit..."
git checkout $commit_hash &&
echo "Compiling kernel..."
env _processor_opt="sandybridge" \
    _disable_debug=y \
    _NUMAdisable=y \
    _nr_cpus=4 \
    _use_auto_optimization='' \
    _localmodcfg=y \
    _cc_harder=y \
    makepkg &&
    echo "Logining in to GitHub..."
echo "file(s) size : ${du -sh ./*.pkg.tar.zst}"
printenv GITHUB_KEY | gh auth login --with-token
minor=$(grep _minor PKGBUILD | head -1 | cut -c 8-)
major=$(grep _major PKGBUILD | head -1 | cut -c 8-)
pkgrel=$(grep pkgrel PKGBUILD | head -1 | cut -c 8-)
version="$major.$minor-$pkgrel"
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
