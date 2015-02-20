FROM ubuntu:precise
MAINTAINER Igor Serko <igor.serko@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get -y --force-yes install quilt devscripts autoconf
RUN apt-get -y --force-yes build-dep openssh-server
ADD build_package.sh /var/tmp/build_package.sh
ADD openssh-5.9p1.ubuntu.ack.patch /var/tmp/openssh-5.9p1.ubuntu.ack.patch

WORKDIR /var/tmp
