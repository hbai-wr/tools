#!/bin/sh

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
mkdir ${MY_BUILDROOT}/pbuilder/hooks >> /dev/null 2>&1
mkdir ${MY_BUILDROOT}/pbuilder/aptcache >> /dev/null 2>&1
mkdir ${MY_BUILDROOT}/pbuilder/build >> /dev/null 2>&1
mkdir ${MY_BUILDROOT}/pbuilder/pbuildd >> /dev/null 2>&1
mkdir ${MY_BUILDROOT}/pbuilder/ccache >> /dev/null 2>&1
mkdir ${MY_BUILDROOT}/pbuilder/pbuilder-mnt >> /dev/null 2>&1
mkdir ${MY_BUILDROOT}/pbuilder/result >> /dev/null 2>&1

sudo rm -rf /var/cache/pbuilder
sudo ln -s ${MY_BUILDROOT}/pbuilder /var/cache/pbuilder

sudo rm -rf /localdisk/loadbuild/pbuilder
sudo ln -s ${MY_BUILDROOT}/pbuilder /localdisk/loadbuild/pbuilder

sudo cp ${HOME}/pbuilder/D01update-stx-repo.sh ${MY_BUILDROOT}/pbuilder/hooks/
sudo cp ${HOME}/pbuilder/pbuilder_build_pkg.sh ${MY_BUILDROOT}/pbuilder/
sudo cp ${HOME}/pbuilder/pbuilderrc /etc/pbuilderrc

echo "Pbuilder Environment Setup Done."

cd ${MY_BUILDROOT}
