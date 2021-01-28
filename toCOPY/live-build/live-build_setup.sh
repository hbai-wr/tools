#!/bin/bash

echo "Live-build Environment Preparing..."

[ -z ${MY_WORKSPACE} ] && {
     source ${HOME}/buildrc
}

# pbuilder env initialize
MY_LBROOT="${MY_WORKSPACE}/build-root/lbiso"
[ ! -d ${MY_LBROOT} ] && {
    sudo mkdir -p ${MY_LBROOT}
}

cd ${MY_LBROOT}

sudo lb config  \
  --architectures amd64 \
  --binary-images iso-hybrid \
  --distribution bullseye \
  --linux-flavours amd64 \
  --debian-installer true \
  --apt-recommends false

sleep 2

sudo cp ${HOME}/live-build/bullseye.list.chroot ./config/archives/
sudo cp ${HOME}/live-build/bullseye.pref.chroot ./config/archives/
sudo cp ${HOME}/live-build/0001-add-gpg-apt-key.hook.chroot ./config/hooks/normal/

echo "Live-build Environment Setup Done."
