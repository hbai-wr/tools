#!/bin/bash

# Load tbuilder configuration
if [[ -r ${HOME}/buildrc ]]; then
    source ${HOME}/buildrc
fi

# make the place we will clone into
. /etc/profile.d/stx-builder-conf.sh
echo "MY_REPO=$MY_REPO"
mkdir -p $MY_REPO
mkdir -p $MY_WORKSPACE

cat <<EOF
Using ${SOURCE_REMOTE_URI} for build

To ease checkout do:
    eval \$(ssh-agent)
    ssh-add
To start a fresh source tree:
    cd \$MY_REPO_ROOT_DIR
    repo init -u https://opendev.org/starlingx/manifest.git -m default.xml
To build all packages:
    cd \$MY_REPO
    build-pkgs or build-pkgs <pkglist>
To make an iso:
    build-iso
EOF

# pbuilder setup
#source ${HOME}/pbuilder/pbuilder_setup.sh

# live-build setup
#. ${HOME}/live-build/live-build_setup.sh
