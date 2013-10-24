#!/bin/bash
set -ex
# taken from https://marc.xn--wckerlin-0za.ch/computer/blog/ssh_and_ldap
# original author marc@waeckerlin.org
# with some modifications by igor.serko@gmail.com
 
if [ -z "$(which schroot)" ]; then
    echo "ERROR: Install schroot in order to run the script"
    exit 1
fi
 
# removing contents of tmp dir in the chroot
rm -rf /opt/chroots/precise_amd64/var/tmp/*
# add source-repository and install all necessary packages
schroot -c ${distro}_${arch} -u root -d / -- sed -i '/^deb-src/d;/^deb /{p;s/^deb/deb-src/}' /etc/apt/sources.list
schroot -c ${distro}_${arch} -u root -d / -- apt-get update
schroot -c ${distro}_${arch} -u root -d / -- apt-get -y --force-yes install quilt devscripts autoconf
schroot -c ${distro}_${arch} -u root -d / -- apt-get -y --force-yes build-dep openssh-server
# can't find a good way to get the chroot dir so I'm hardcoding it
cp build_package.sh /opt/chroots/precise_amd64/var/tmp
cp openssh-5.9p1.ubuntu.ack.patch /opt/chroots/precise_amd64/var/tmp
schroot -c ${distro}_${arch} -d /var/tmp -- /var/tmp/build_package.sh
DEBFILE=$(ls -1 /opt/chroots/precise_amd64/var/tmp/openssh-akc-server_*.deb)
mv $DEBFILE .
FILENAME=$(basename $DEBFILE)
echo "Debian package available at $FILENAME"
