FROM phusion/baseimage:0.9.16
MAINTAINER Gorka Lerchundi Osa <glertxundi@gmail.com>

#
# common
#

ENV HOME /root
CMD ["/sbin/my_init"]

#
# custom
#

ADD assets/.bashrc $HOME/
ADD assets/apt-get-install-min /usr/bin/
RUN chmod +x /usr/bin/apt-get-install-min

# basic tools
RUN apt-get update && \
    apt-get-install-min htop

#
# cleanup
#

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
