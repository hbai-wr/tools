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
# Copyright (C) 2019 Intel Corporation
#

FROM debian:buster

# Proxy configuration
#ENV http_proxy  "http://your.actual_http_proxy.com:your_port"
#ENV https_proxy "https://your.actual_https_proxy.com:your_port"
#ENV ftp_proxy   "http://your.actual_ftp_proxy.com:your_port"

#RUN echo "proxy=$http_proxy" >> /etc/yum.conf && \
#    echo -e "export http_proxy=$http_proxy\nexport https_proxy=$https_proxy\n\
#export ftp_proxy=$ftp_proxy" >> /root/.bashrc

# username you will docker exec into the container as.
# It should NOT be your host username so you can easily tell
# if you are in our out of the container.
ARG MYUNAME=builder
ARG MYUID=1000
# CentOS & EPEL URLs that match the base image
# Override these with --build-arg if you have a mirror
ARG MY_EMAIL=

ENV container=docker

# Without this, init won't start the enabled services and exec'ing and starting
# them reports "Failed to get D-Bus connection: Operation not permitted".
VOLUME /run /tmp

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
        createrepo \
        flex \
        isomd5sum \
        gcc \
        gettext \
        git \
        libguestfs-tools \
        libtool \
        libxml2 \
        net-tools \
        squashfs-tools \
        sudo \
        systemd \
        syslinux \
        udisks2 \
        wget \
        live-build

# This image requires a set of scripts and helpers
# for working correctly, in this section they are
# copied inside the image.
COPY toCOPY/finishSetup.sh /usr/local/bin
COPY toCOPY/populate_downloads.sh /usr/local/bin
COPY toCOPY/generate-local-repo.sh /usr/local/bin
COPY toCOPY/generate-centos-repo.sh /usr/local/bin
COPY toCOPY/lst_utils.sh /usr/local/bin
COPY toCOPY/.inputrc /home/$MYUNAME/
COPY toCOPY/builder-constraints.txt /home/$MYUNAME/

# Thes are included for backward compatibility, and
# should be removed after a reasonable time.
COPY toCOPY/generate-cgcs-tis-repo /usr/local/bin
COPY toCOPY/generate-cgcs-centos-repo.sh /usr/local/bin

# pip installs
#RUN pip3 install -c /home/$MYUNAME/builder-constraints.txt python-subunit junitxml --upgrade && \
#    pip3 install -c /home/$MYUNAME/builder-constraints.txt tox --upgrade

# installing go and setting paths
ENV GOPATH="/usr/local/go"
ENV PATH="${GOPATH}/bin:${PATH}"
RUN apt-get install -y golang && \
    mkdir -p ${GOPATH}/bin && \
    curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh

# mock time
# forcing chroots since a couple of packages naughtily insist on network access and
# we dont have nspawn and networks happy together.
#RUN useradd -s /sbin/nologin -u 9001 -g 9001 mockbuild && \
#    rmdir /var/lib/mock && \
#    ln -s /localdisk/loadbuild/mock /var/lib/mock && \
#    rmdir /var/cache/mock && \
#    ln -s /localdisk/loadbuild/mock-cache /var/cache/mock && \
#    echo "config_opts['use_nspawn'] = False" >> /etc/mock/site-defaults.cfg && \
#    echo "config_opts['rpmbuild_networking'] = True" >> /etc/mock/site-defaults.cfg && \
#    echo  >> /etc/mock/site-defaults.cfg

#  ENV setup
RUN echo "# Load stx-builder configuration" >> /etc/profile.d/stx-builder-conf.sh && \
    echo "if [[ -r \${HOME}/buildrc ]]; then" >> /etc/profile.d/stx-builder-conf.sh && \
    echo "    source \${HOME}/buildrc" >> /etc/profile.d/stx-builder-conf.sh && \
    echo "    export PROJECT SRC_BUILD_ENVIRONMENT MYPROJECTNAME MYUNAME" >> /etc/profile.d/stx-builder-conf.sh && \
    echo "    export MY_BUILD_CFG MY_BUILD_CFG_RT MY_BUILD_CFG_STD MY_BUILD_DIR MY_BUILD_ENVIRONMENT MY_BUILD_ENVIRONMENT_FILE MY_BUILD_ENVIRONMENT_FILE_RT MY_BUILD_ENVIRONMENT_FILE_STD MY_DEBUG_BUILD_CFG_RT MY_DEBUG_BUILD_CFG_STD MY_LOCAL_DISK MY_MOCK_ROOT MY_REPO MY_REPO_ROOT_DIR MY_SRC_RPM_BUILD_DIR MY_RELEASE MY_WORKSPACE LAYER" >> /etc/profile.d/stx-builder-conf.sh && \
    echo "fi" >> /etc/profile.d/stx-builder-conf.sh && \
    echo "export FORMAL_BUILD=0" >> /etc/profile.d/stx-builder-conf.sh && \
    echo "export PATH=\$MY_REPO/build-tools:\$PATH" >> /etc/profile.d/stx-builder-conf.sh

# centos locales are broken. this needs to be run after the last yum install/update
#RUN localedef -i en_US -f UTF-8 en_US.UTF-8

# setup
RUN mkdir -p /www/run && \
    mkdir -p /www/logs && \
    mkdir -p /www/home && \
    mkdir -p /www/root/htdocs/localdisk && \
    chown -R $MYUID:cgts /www && \
    ln -s /localdisk/loadbuild /www/root/htdocs/localdisk/loadbuild && \
    ln -s /import/mirrors/CentOS /www/root/htdocs/CentOS && \
    ln -s /import/mirrors/fedora /www/root/htdocs/fedora && \
    ln -s /localdisk/designer /www/root/htdocs/localdisk/designer

# Systemd Enablement
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*

RUN useradd -r -u $MYUID -g cgts -m $MYUNAME && \
    ln -s /home/$MYUNAME/.ssh /mySSH

# now that we are doing systemd, make the startup script be in bashrc
# also we need to SHADOW the udev centric mkefiboot script with a sudo centric one
RUN echo "bash -C /usr/local/bin/finishSetup.sh" >> /home/$MYUNAME/.bashrc && \
    echo "export PATH=/usr/local/bin:/localdisk/designer/$MYUNAME/bin:\$PATH" >> /home/$MYUNAME/.bashrc && \
    chmod a+x /usr/local/bin/*

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
