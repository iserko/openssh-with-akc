#!/bin/bash -ex

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
 
# download the sources of openssh-server - not with sudo
apt-get source openssh-server
 
# download the akc patch file
wget -O openssh-akc.patch --no-check-certificate 'https://marc.xn--wckerlin-0za.ch/_media/computer/blog/openssh-5.9p1.ubuntu.ack.patch'
 
# go to the downloaded and extracted directory
cd openssh-5.9p1
 
# add the new patch to the build using quilt
quilt push -a || true
quilt new openssh-akc.patch
quilt add $(patch --dry-run -p1 < ../openssh-akc.patch  | sed -n 's,patching file ,,p')
patch -p1 < ../openssh-akc.patch
quilt add configure config.h.in
autoconf
autoheader
quilt refresh
quilt pop -a
# append "confflags += --with-authorized-keys-command" to the deban rules, just after "confflags += --with-pam"
sed -i '/confflags *+= *--with-pam/aconfflags += --with-authorized-keys-command' debian/rules
## refresh configure file before calling configure
#sed -i '/^override_dh_auto_configure:/a\\taclocal && autoconf' debian/rules
# There's a bug in consolekit
sed -i '/confflags *+= *--with-consolekit/d' debian/rules
 
# rename package name to contain akc
renamepackage openssh-server openssh-akc-server
# Fix dependency on openssh-client, so building openssh-akc-client is not necessary
sed -i "/Package: *openssh-akc-server *$/,/^$/s/\(Depends:.*\) openssh-client[^,]*,\(.*\)/\1\2/" debian/control
# otherwise we'd need to provide openssh-akc-client:
#   renamepackage openssh-client openssh-akc-client
 
# Fix (build-) dependencies for old distributions: remove minimal versions
sed -i 's/ (>[^)]*),/,/g' debian/control
 
# create a new build version - enter a change-tect, e.g. "applied akc patch"
debchange -i "apply akc patch"
 
# rebuild debian packages
schroot -p -c ${distro}_${arch} -- debuild -us -uc -i -I
