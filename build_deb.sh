#!/bin/sh
# Script to build .deb package

PACKAGE=rdum

if [ $# -gt 0 ]
then
  PACKAGE=$1
fi

rm -r deb
mkdir -p "deb/usr/bin"
mkdir -p "deb/usr/share/applications"
mkdir -p "deb/usr/share/doc/$PACKAGE"
mkdir -p "deb/usr/share/man/man1"

chmod -R 0755 deb

cp -r DEBIAN deb
cp "$PACKAGE" deb/usr/bin
chmod 755 "deb/usr/bin/$PACKAGE"
gzip -n --best -c changelog > "deb/usr/share/doc/$PACKAGE/changelog.gz"
chmod 0644 "deb/usr/share/doc/$PACKAGE/changelog.gz"
gzip -n --best -c $PACKAGE.man > "deb/usr/share/man/man1/$PACKAGE.1.gz"
chmod 0644 "deb/usr/share/man/man1/$PACKAGE.1.gz"
cp copyright "deb/usr/share/doc/$PACKAGE/"
chmod 0644 "deb/usr/share/doc/$PACKAGE/copyright"
cp desktop "deb/usr/share/applications/$PACKAGE.desktop"
chmod 0644 "deb/usr/share/applications/$PACKAGE.desktop"
fakeroot dpkg-deb --build deb $PACKAGE.deb && lintian $PACKAGE.deb && rm -r deb
