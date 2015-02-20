openssh-with-akc
================

This repository is a simpler version of creating a patched version of OpenSSH with the ability to
use AuthorizedKeysCommand. The patch and `build_package.sh` were taken from
https://marc.waeckerlin.org/computer/index#the_authorizedkeyscommand_akc_patch


Instructions
------------

1. install Docker
1. `docker build -t openssh-with-akc .`
1. `docker run --env distro=precise --env arch=amd64 -ti --name openssh-with-akc-container openssh-with-akc /var/tmp/build_package.sh`
1. record the filename you saw in the logs ... ex. `openssh-akc-server_5.9p1-5ubuntu1.5_amd64.deb`
1. `docker cp openssh-with-akc-container:/var/tmp/<FILENAME> <FILENAME>`
1. `docker rm openssh-with-akc-container`
