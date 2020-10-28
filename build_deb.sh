#!/bin/sh
# Script to build .deb package

if [ $# -eq 0 ]
then
  echo Usage: build_deb.sh package_name
  exit 1
fi

rm -r deb
mkdir -p "deb/usr/bin"
mkdir -p "deb/usr/share/applications"
mkdir -p "deb/usr/share/doc/$1"
mkdir -p "deb/usr/share/man/man1"

chmod -R 0755 deb

cp -r DEBIAN deb
cp "$1" deb/usr/bin
gzip -n --best -c changelog > "deb/usr/share/doc/$1/changelog.gz"
chmod 0644 "deb/usr/share/doc/$1/changelog.gz"
gzip -n --best -c $1.man > "deb/usr/share/man/man1/$1.1.gz"
chmod 0644 "deb/usr/share/man/man1/$1.1.gz"
cp copyright "deb/usr/share/doc/$1/"
cp desktop "deb/usr/share/applications/$1/$1.desktop"
chmod 
fakeroot dpkg-deb --build deb $1.deb && lintian $1.deb && rm -r deb
