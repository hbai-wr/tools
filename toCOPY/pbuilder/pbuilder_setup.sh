#!/bin/bash

echo "Pbuilder Environment Preparing..."

[ -z ${MY_WORKSPACE} ] && {
    source ${HOME}/buildrc
}
# pbuilder env initialize
MY_BUILDROOT="${MY_WORKSPACE}/build-root/builder"
[ ! -d ${MY_BUILDROOT} ] && {
    mkdir -p ${MY_BUILDROOT}
}
mkdir ${MY_BUILDROOT}/pbuilder >> /dev/null 2>&1
mkdir ${MY_BUILDROOT}/pbuilder/{hooks,aptcache,build,ccache,pbuilder-mnt,result}
mkdir ${MY_BUILDROOT}/pbuilder/result/deps >> /dev/null 2>&1
cd ${MY_BUILDROOT}/pbuilder/result/deps
apt-ftparchive packages . > Packages
apt-ftparchive release ./ > Release

sudo rm -rf /var/cache/pbuilder
sudo ln -s ${MY_BUILDROOT}/pbuilder /var/cache/pbuilder

sudo rm -rf /localdisk/loadbuild/pbuilder
sudo ln -s ${MY_BUILDROOT}/pbuilder /localdisk/loadbuild/pbuilder

sudo cp ${HOME}/pbuilder/D01update-stx-repo.sh ${MY_BUILDROOT}/pbuilder/hooks/
sudo cp ${HOME}/pbuilder/build-pkg ${MY_BUILDROOT}/pbuilder/
sudo cp ${HOME}/pbuilder/pbuilderrc /etc/pbuilderrc

echo "Pbuilder Environment Setup Done."

cd ${MY_BUILDROOT}
