# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Copyright (C) 2021 WindRiver Corporation
#

FROM debian:bullseye

# username you will docker exec into the container as.
# It should NOT be your host username so you can easily tell
# if you are in our out of the container.
ARG MYUNAME=builder
ARG MYUID=1000
ARG MY_EMAIL=
ENV container=docker

# Without this, init won't start the enabled services and exec'ing and starting
# them reports "Failed to get D-Bus connection: Operation not permitted".
VOLUME /run /tmp

RUN echo "deb-src http://deb.debian.org/debian bullseye main" >> /etc/apt/sources.list
# Download required dependencies by mirror/build processes.
RUN groupadd -g 751 cgts && \
    apt-get update && apt-get install -y \
        sudo \
        autoconf-archive \
        autogen \
        automake \
        autoconf \
        libtool \
        make \
        bc \
        bison \
        flex \
        gcc \
        gettext \
        git \
        libtool \
        libxml2 \
        net-tools \
        sudo \
        systemd \
        syslinux \
        wget \
        vim \
	build-essential \
	fakeroot \
        live-build \
        pbuilder \
        debootstrap \
        devscripts \
        schroot \
	cowbuilder \
	debmake \
        sbuild \
        emacs \
        httpie \
        po4a \
        osc

RUN useradd -r -u $MYUID -g cgts -m $MYUNAME && \
    ln -s /home/$MYUNAME/.ssh /mySSH
# This image requires a set of scripts and helpers
# for working correctly, in this section they are
# copied inside the image.
COPY toCOPY/finishSetup.sh /usr/local/bin
COPY toCOPY/repo /usr/local/bin
COPY toCOPY/setup_local_builder /usr/local/bin
RUN chmod a+x /usr/local/bin/*
COPY toCOPY/.inputrc /home/$MYUNAME/
COPY toCOPY/oscrc /home/$MYUNAME/.config/osc/oscrc
RUN chown -R $MYUNAME:cgts /home/$MYUNAME/.config
COPY toCOPY/conf.py /usr/lib/python3/dist-packages/osc/conf.py

# Genrate a git configuration file in order to save an extra step
# for end users, this file is required by "repo" tool.
RUN chown $MYUNAME /home/$MYUNAME && \
    if [ -z $MY_EMAIL ]; then MY_EMAIL=$MYUNAME@opendev.org; fi && \
    runuser -u $MYUNAME -- git config --global user.email $MY_EMAIL && \
    runuser -u $MYUNAME -- git config --global user.name $MYUNAME && \
    runuser -u $MYUNAME -- git config --global color.ui false

RUN echo "$MYUNAME ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

# When we run 'init' below, it will run systemd, and systemd requires RTMIN+3
# to exit cleanly. By default, docker stop uses SIGTERM, which systemd ignores.
STOPSIGNAL RTMIN+3
