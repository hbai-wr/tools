#!/bin/sh

STX_REPO="${MY_WORKSPACE}/build-root/pbuilder/result"

(cd ${STX_REPO} ; apt-ftparchive packages . > Packages)
(cd ${STX_REPO} ; apt-ftparchive release ./ > Release)

apt-get update
