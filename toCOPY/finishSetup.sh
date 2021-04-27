#!/bin/bash

sed -i "s/user=username/user=${OBSUSER}/g" ${HOME}/.config/osc/oscrc
sed -i "s/pass=password/pass=${OBSPASS}/g" ${HOME}/.config/osc/oscrc

cat <<EOF
To ease checkout do:
    eval \$(ssh-agent)
    ssh-add
To start a fresh source tree:
    cd \$MY_REPO_ROOT_DIR
    repo init -u https://github.com/hbai-wr/starlingx-manifest.git -b f/debian11 -m deb_default.xml
    repo sync
Or manual download if network issue:
    cd \$MY_REPO_ROOT_DIR
    git clone -b f/debian11 https://github.com/hbai-wr/build-tools.git
    mkdir stx; cd stx
    git clone -b f/debian11 https://github.com/hbai-wr/integ.git
To build package:
    cd \$MY_WORKSPACE
    build-pkgs [-l local] <Package Name>
EOF

[ -d ${MY_WORKSPACE} ] && {
    mkdir -p ${MY_WORKSPACE}
}
cd ${MY_WORKSPACE}
