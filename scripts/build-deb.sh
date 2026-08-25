#!/bin/sh
set -eu

version=2.3.1
revision=1
script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
repo_dir=$(CDPATH='' cd -- "$script_dir/.." && pwd)
output_dir=${1:-"$repo_dir/dist"}
work_dir=$(mktemp -d)
package_root="$work_dir/ch9344-dkms_${version}-${revision}_all"

cleanup() {
	rm -rf -- "$work_dir"
}
trap cleanup EXIT HUP INT TERM

mkdir -p "$output_dir" "$package_root/DEBIAN" \
	"$package_root/usr/src/ch9344-$version"

install -m 0644 "$repo_dir/packaging/control" "$package_root/DEBIAN/control"
install -m 0755 "$repo_dir/packaging/postinst" "$package_root/DEBIAN/postinst"
install -m 0755 "$repo_dir/packaging/prerm" "$package_root/DEBIAN/prerm"
install -m 0755 "$repo_dir/packaging/postrm" "$package_root/DEBIAN/postrm"

cp -a "$repo_dir/packaging/root/." "$package_root/"
install -m 0644 "$repo_dir/driver/Makefile" \
	"$repo_dir/driver/ch9344.c" "$repo_dir/driver/ch9344.h" \
	"$repo_dir/driver/dkms.conf" "$package_root/usr/src/ch9344-$version/"

artifact="$output_dir/ch9344-dkms_${version}-${revision}_all.deb"
dpkg-deb --build --root-owner-group "$package_root" "$artifact"
sha256sum "$artifact"
