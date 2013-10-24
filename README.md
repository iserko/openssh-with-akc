openssh-with-akc
================

Instructions
------------

1. Install schroot `sudo apt-get install schroot`
1. Create chroot directory `mkdir -p /opt/chroots/precise_amd64`
1. Change ownership `chown -R jenkins:jenkins /opt/chroots/precise_amd64`
1. Prepare the chroot `debootstrap --variant=buildd --arch=amd64 precise /opt/chroots/precise_amd64 http://gb.archive.ubuntu.com/ubuntu/`
1. In my case I had `at` installed on my server so I had to uninstall it from the chroot `schroot -c precise_amd64 -u root -d / -- apt-get -f --force-yes remove at`
1. Create your Jenkins job
1. As the build step for the jenkins job use: `env distro=precise arch=amd64 jenkins_akc_patch.sh`
