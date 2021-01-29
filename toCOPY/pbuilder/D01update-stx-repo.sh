#!/bin/sh

STX_REPO="/localdisk/loadbuild/pbuilder/result"

(cd ${STX_REPO} ; apt-ftparchive packages . > Packages)
(cd ${STX_REPO} ; apt-ftparchive release ./ > Release)

echo "stx repo update done."

apt-get update
