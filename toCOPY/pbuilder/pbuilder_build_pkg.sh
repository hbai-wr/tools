#!/bin/bash
# Deb Builder script.

set -e

#we covered /etc/pbuilderrc and try to use the default config
#so below may should not pass to pbuilder command
DISTRIBUTION="bullseye"
ARCHITECTURE="amd64"
BASEDIRECTORY="/localdisk/loadbuild/builder/pbuilder"
TGZBASEFILE="${BASEDIRECTORY}/pbuilder/${DISTRIBUTION}-${ARCHITECTURE}-base.tgz"
MIRROR=ftp.debian.org
HOOKDIR=${BASEDIRECTORY}/pbuilder/hooks
AVOIDLIST="${BASEDIRECTORY}/AVOID.LST"
ROOTCOMMAND=sudo

NOBUILDDEP=${BASEDIRECTORY}/FAILED/NOBUILDDEP
FAILED=${BASEDIRECTORY}/FAILED
DEPWAIT=${BASEDIRECTORY}/DEPWAIT
SUCCESS=${BASEDIRECTORY}/SUCCESS

mkdir -p "$FAILED" || true
mkdir -p "$DEPWAIT" || true
mkdir -p "$SUCCESS" || true
mkdir -p ${BASEDIRECTORY}/WORKING || true 
mkdir -p ${BASEDIRECTORY}/STATUS || true 
mkdir -p "$NOBUILDDEP" || true
BUILDRESULTDIR=${BASEDIRECTORY}/result
mkdir -p "$BUILDRESULTDIR" || true
mkdir -p "${APTCACHE}" || true

STATUSFILE=${BASEDIRECTORY}/STATUS/$(hostname)-$$
BUILDTMP=${BASEDIRECTORY}/tmp-b-$(hostname)-$$

function usage () {
    echo
    echo "Usage:"
    echo "$0 [Options] --pbuilder-init"
    echo
}

function status () {
    echo "$@" > $STATUSFILE
    echo "$@"
}

function buildone() {
    local PROGNAME="$1"
    local LOGFILE=${BASEDIRECTORY}/WORKING/"$PROGNAME.log"

    status "building $PROGNAME"
    mkdir $BUILDTMP || true
    (
	cd $BUILDTMP
	# make sure that the deb-src has been enabled in build container
	apt-get source -d $PROGNAME
	if sudo pbuilder build --hookdir "${HOOKDIR}" --logfile "$LOGFILE" *.dsc; then
	    mv "$LOGFILE" "$SUCCESS"
	    echo Build successful
	else
	    if grep "^E: pbuilder: Could not satisfy build-dependency." $LOGFILE > /dev/null; then
		mv "$LOGFILE" "$DEPWAIT"
		echo Dependency cannot be satisfied.
	    elif [ $(awk '/ -> Attempting to parse the build-deps/,/^ -> Finished parsing the build-deps/{print $0}' $LOGFILE | wc -l ) = "2" ]; then
		echo "Missing build-deps"
		mv "$LOGFILE" "$NOBUILDDEP"
	    elif grep '^E: Could not satisfy build-dependency' "$LOGFILE" > /dev/null ; then
		echo "Build-dep wait" 
		mv "$LOGFILE" "$DEPWAIT"
	    elif grep '^E: pbuilder-satisfydepends failed.' "$LOGFILE" > /dev/null ; then
		echo "Build-dep satisfaction failed on other package's installation"
		mv "$LOGFILE" "$DEPWAIT"
	    else
		mv "$LOGFILE" "$FAILED"
		echo Build failed
	    fi
	fi
    )
    status "finished building $PROGNAME"
    rm -rf $BUILDTMP;
}

#$ROOTCOMMAND dselect update
#$ROOTCOMMAND pbuilder update 

#$USERPKGLSIT="./pkg.lst"
if [ ! -f "./.tgzlock" ]; then
    echo "Try to clean the old tgz file if exists!"
    [ -f ${TGZBASEFILE} ] && sudo rm ${TGZBASEFILE}
    sudo pbuilder --create --distribution ${DISTRIBUTION} --architecture ${ARCHITECTURE} --basetgz ${TGZBASEFILE}
    [ $? == 0 ] && touch ./.tgzlock;
fi

for A in dnsmasq; do
    # this part needs to be atomic
    status "considering $A"
    if grep "^$A$" $AVOIDLIST; then
	echo Skip.
	continue
    fi
    if echo "$A" | grep "^kernel-image"; then
    	echo I hate kernel images.
	continue
    fi

    if [ $(find ${BASEDIRECTORY} -name $A.log | wc -l ) = "1" ]; then
	echo Already build tried for "$A"
	continue
    fi
    # end of atomic.

    #build_package_prepard $A

    #waitingroutine
    buildone $A

    #update_inject_apt $A
done
