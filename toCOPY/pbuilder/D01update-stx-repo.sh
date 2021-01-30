#!/bin/sh

STX_LOCAL_REPO="/localdisk/loadbuild/pbuilder/result/deps/"
(cp /localdisk/loadbuild/pbuilder/result/*.deb ${STX_LOCAL_REPO})
(cd ${STX_LOCAL_REPO} ; apt-ftparchive packages . > Packages)
(cd ${STX_LOCAL_REPO} ; apt-ftparchive release ./ > Release)

echo "stx local repo update done."

apt-get update
