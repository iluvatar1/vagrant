#!/bin/env bash

# fix PATH to remove anaconda stuff
export PATH=/usr/local/sbin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin:/usr/games:/usr/lib64/kde4/libexec:/usr/lib64/qt/bin:/usr/share/texmf/bin
\
################################################################################
COMPILE=${COMPILE:-NO}
PKG="keepassx sshfs-fuse autossh xfce4-xkb-plugin flashplayer-plugin slim monit fail2ban corkscrew pip parallel wol valgrind openmpi modules cppcheck iotop gperftools"

pm () {
    echo "  -> $1"
}

setup () {
    if hash slpkg &> /dev/null; then
        pm "Updating slpkg ..."
        source /root/.bashrc
        slpkg upgrade
    else
        pm "ERROR: slpkg not installed. Exiting"
        exit 1
    fi
}

install_binary_packages () {
    BASEURL="http://157.245.132.188/PACKAGES/slackware64-current/"
    cd /tmp || exit
    rm -f "PACKAGES.txt" 2>/dev/null
    wget -c -nc "$BASEURL/PACKAGES.txt" 2> /dev/null
    while read -r line; do
	pm "Installing (from binary): $line"
	bname=${line%.*}
	pm "  basename: $bname"
	if [ ! -e "/var/log/packages/$bname" ]; then
	    wget -c -nc "$BASEURL/$line"
	    installpkg "$line"
	else
	    pm "Already installed: $line"
	fi
    done < PACKAGES.txt
}

install_with_slpkg_compile () {
    rm -f /var/log/slpkg.log
    slpkg update >> /var/log/slpkg.log
    for pkg in "${PKG[*]}"; do
	    pm "Installing (with slpkg): $pkg"
	    slpkg -s sbo "$pkg" --rebuild >> /var/log/slpkg.log
    done
}

aux_slbuild () {
    cd /tmp
    wget "$1"
    wget "$2"
    slname="$(basename $1)"
    pkgname="$(basename $2)"
    slpkg -a "$slname" "$pkgname"
    unset $VERSION
}

install_from_source_new_version () {
    export VERSION=6.1.0
    aux_slbuild https://slackbuilds.org/slackbuilds/14.2/academic/octave.tar.gz  https://mirror.cedia.org.ec/gnu/octave/octave-6.1.0.tar.lz
}

install_latest_firefox() {
    MSG="Installing latest firefox ..."
    pm "$MSG"
    sleep 2
    if [ x"" != x"$(firefox --version | grep esr)" ]; then
	    cd || exit
	    if [ ! -d $HOME/repos/ ]; then
	        mkdir -p $HOME/repos
	    fi
	    cd $HOME/repos || exit
	    if [ ! -d computer-labs ]; then
	        git clone https://github.com/iluvatar1/computer-labs
	    fi
	    cd computer-labs || exit
	    bash packages/latest-firefox.sh -i
	    pm "Done"
    else
	    pm "Already installed: $(firefox --version)"
    fi
}

install_perf () {
    MSG="Installing perf ..."
    pm "$MSG"
    sleep 2
    if ! hash perf 2>/dev/null; then
	    cd /usr/src/linux/tools/perf || exit
	    VERSION=$(uname -r) make -j 2 prefix=/usr/local install
	    pm "Done"
    else
	    pm "Already installed"
    fi
}



################################################################################
# MAIN

setup
# install qt5 from slack
slpkg -s slack qt5 icu4c

if [ "NO" = "$COMPILE" ]; then
    install_binary_packages
else
    install_with_slpkg_compile
fi

#install_latest_firefox
install_perf
# install some big packages already compiled by alien
slpkg -s alien libreoffice inkscape vlc poppler-compat

rm -f /tmp/*tgz 2>/dev/null
