#!/bin/bash
set -ex
# taken from https://marc.xn--wckerlin-0za.ch/computer/blog/ssh_and_ldap
# original author marc@waeckerlin.org
# with some modifications by igor.serko@gmail.com
 
export EMAIL=marc@waeckerlin.org
export NAME="Marc Wäckerlin"
 
renamepackage() {
  from=$1
  to=$2
  for file in $(find debian -name "*${from}*"); do
    mv ${file} ${file//${from}/${to}}
  done
  for file in $(find debian -exec grep -l ${from} {} ';'); do
    sed -i "s/${from}/${to}/g" ${file}
  done
  sed -i "/Package: *${to} *$/,/^$/s/Conflicts:.*/&, ${from}/" debian/control
  sed -i "/Package: *${to} *$/,/^$/s/Replaces:.*/&, ${from}/" debian/control
  sed -i "/Package: *${to} *$/,/^$/s/Provides:.*/&, ${from}/" debian/control
}

if [ -z "$(which schroot)" ]; then
    echo "ERROR: Install schroot in order to run the script"
    exit 1
fi
 
# add source-repository and install all necessary packages
schroot -c ${distro}_${arch} -u root -d / -- sed -i '/^deb-src/d;/^deb /{p;s/^deb/deb-src/}' /etc/apt/sources.list
schroot -c ${distro}_${arch} -u root -d / -- apt-get update
schroot -c ${distro}_${arch} -u root -d / -- apt-get -y --force-yes install quilt devscripts
schroot -c ${distro}_${arch} -u root -d / -- apt-get -y --force-yes build-dep openssh-server
# can't find a good way to get the chroot dir so I'm hardcoding it
cp build_package.sh /opt/chroots/precise_amd64/var/tmp
cp openssh-5.9p1.ubuntu.ack.patch /opt/chroots/precise_amd64/var/tmp

schroot -c ${distro}_${arch} -d /var/tmp -- /var/tmp/build_package.sh
