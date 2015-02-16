FROM ubuntu:14.04
MAINTAINER Gorka Lerchundi Osa <glertxundi@gmail.com>

##
## ROOTFS
##

# root filesystem
COPY rootfs /

# fix-attrs
ADD https://github.com/glerchundi/fix-attrs/releases/download/v0.3.0/fix-attrs-0.3.0-linux-amd64 /usr/bin/fix-attrs

# provide exec permission to basic utils
RUN chmod +x /usr/bin/apt-cleanup      \
             /usr/bin/apt-dpkg-wrapper \
             /usr/bin/apt-get-install  \
             /usr/bin/with-contenv     \
             /usr/bin/ts               \
             /usr/bin/fix-attrs

# create *min files for apt* and dpkg* in order to avoid issues with locales
# and interactive interfaces
RUN ls /usr/bin/apt* /usr/bin/dpkg* |                                    \
    while read line; do                                                  \
      min=$line-min;                                                     \
      printf '#!/bin/sh\n/usr/bin/apt-dpkg-wrapper '$line' $@\n' > $min; \
      chmod +x $min;                                                     \
    done

##
## PREPARE
##

# temporarily disable dpkg fsync to make building faster.
RUN if [ ! -e /etc/dpkg/dpkg.cfg.d/docker-apt-speedup ]; then         \
	  echo force-unsafe-io > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup; \
    fi

# prevent initramfs updates from trying to run grub and lilo.
# https://journal.paul.querna.org/articles/2013/10/15/docker-ubuntu-on-rackspace/
# http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=594189
ENV INITRD no

# enable Ubuntu Universe and Multiverse.
RUN sed -i 's/^#\s*\(deb.*universe\)$/\1/g' /etc/apt/sources.list   && \
    sed -i 's/^#\s*\(deb.*multiverse\)$/\1/g' /etc/apt/sources.list && \
    apt-get-min update

# fix some issues with APT packages.
# see https://github.com/dotcloud/docker/issues/1024
RUN dpkg-divert-min --local --rename --add /sbin/initctl && \
    ln -sf /bin/true /sbin/initctl

# replace the 'ischroot' tool to make it always return true.
# prevent initscripts updates from breaking /dev/shm.
# https://journal.paul.querna.org/articles/2013/10/15/docker-ubuntu-on-rackspace/
# https://bugs.launchpad.net/launchpad/+bug/974584
RUN dpkg-divert-min --local --rename --add /usr/bin/ischroot && \
    ln -sf /bin/true /usr/bin/ischroot

# install HTTPS support for APT.
RUN apt-get-install-min apt-transport-https ca-certificates

# install add-apt-repository
RUN apt-get-install-min software-properties-common

# upgrade all packages.
RUN apt-get-min dist-upgrade -y --no-install-recommends

# fix locale.
ENV LANG en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
RUN apt-get-install-min language-pack-en        && \
    locale-gen en_US                            && \
    update-locale LANG=$LANG LC_CTYPE=$LC_CTYPE

# execline
ADD https://github.com/glerchundi/container-s6-builder/releases/download/v1.0.0/execline-2.0.2.0-linux-amd64.tar.gz /tmp/execline.tar.gz
RUN tar xvfz /tmp/execline.tar.gz -C /

# s6 init system
ADD https://github.com/glerchundi/container-s6-builder/releases/download/v1.0.0/s6-2.1.0.1-linux-amd64.tar.gz /tmp/s6.tar.gz
RUN tar xvfz /tmp/s6.tar.gz -C /

# s6 portable utils
ADD https://github.com/glerchundi/container-s6-builder/releases/download/v1.0.0/s6-portable-utils-2.0.0.1-linux-amd64.tar.gz /tmp/s6-portable-utils.tar.gz
RUN tar xvfz /tmp/s6-portable-utils.tar.gz -C /

##
## INIT
##

RUN chmod +x /init
CMD ["/init"]

##
## CLEANUP
##

RUN apt-cleanup
