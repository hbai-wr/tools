#!/bin/bash

sed -i "s/user=username/user=${OBSUSER}/g" ${HOME}/.config/osc/oscrc
sed -i "s/pass=password/pass=${OBSPASS}/g" ${HOME}/.config/osc/oscrc

cat <<EOF
To ease checkout do:
    eval \$(ssh-agent)
    ssh-add
To start a fresh source tree:
    cd \$MY_REPO_ROOT_DIR
    repo init -u https://opendev.org/starlingx/manifest.git -m default.xml
To setup local builder:
    cd \$MY_PKG_BUILD_DIR
    setup_local_builder
To build all packages:
    cd \$MY_BUILD_DIR
    build-pkgs or build-pkgs <pkglist>
To make an iso:
    build-iso
EOF

[ -d ${MY_WORKSPACE} ] && {
    mkdir -p ${MY_WORKSPACE}
}
cd ${MY_WORKSPACE}
