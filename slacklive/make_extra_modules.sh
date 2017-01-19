MAKEMOD=makemod
LIVESLACKBDIR=~/Downloads/liveslak/

if [ ! -f 0066-anaconda2-4.2.0-x86_64.sxz ]; then 
    cd
    echo "#####################################"
    echo "CREATING anaconda MODULE ... "
    if [ ! -d /tmp/modtemp/opt ]; then 
	mkdir -p /tmp/modtemp/opt
    fi
    echo "Copying anaconda2 to /tmp/modtemp/opt/ ..."
    cp -auvf /opt/anaconda2 /tmp/modtemp/opt/
    echo "Creating a local profile to modify the path for all users ... "
    mkdir -p /tmp/modtemp/etc/profile.d
    echo 'export PATH="/opt/anaconda2/bin:$PATH"' > /tmp/modtemp/etc/profile.d/anaconda.sh
    chmod -x /tmp/modtemp/etc/profile.d/anaconda.sh
    echo "Creating liveslack module ... "
    bash $LIVESLACKBDIR/$MAKEMOD -i  /tmp/modtemp/ 0066-anaconda2-4.2.0-x86_64.sxz
    echo "Done anaconda module."
    echo "You can test the module contents with the command : "
    echo "unsquashfs -l 0066-anaconda2-4.2.0-x86_64.sxz"
    echo "#####################################"
    echo
fi

BNAME=valgrind-3.12.0-x86_64-1_SBo
if [ ! -f 0067-${BNAME}.sxz ]; then
    echo "#####################################"
    echo "CREATING valgrind MODULE"
    if [ ! /tmp/$BNAME.tgz ]; then 
	mkdir -p /tmp/valgrind &&
	    cd /tmp/valgrind &&
	    wget -c https://slackbuilds.org/slackbuilds/14.2/development/valgrind.tar.gz &&
	    tar xf valgrind.tar.gz &&
	    cd valgrind &&
	    wget -c http://www.valgrind.org/downloads/valgrind-3.12.0.tar.bz2 &&
	    bash valgrind.SlackBuild
    fi
    cd
    bash $LIVESLACKBDIR/$MAKEMOD -i /tmp/${BNAME}.tgz 0067-${BNAME}.sxz 
    echo "Done valgrind module."
    echo "You can test the module contents with the command : "
    echo "unsquashfs -l 0067-${BNAME}.sxz"
    echo "#####################################"
    echo 
fi

if [ ! -f 0068-customconfig-0.0.1-x86_64.sxz ]; then
    echo "#####################################"
    echo "CREATING config MODULE"
    BDIR=$(mktemp -p /tmp/)
    mkdir -p $BDIR/etc/profile.d/
    echo "export LESS='-eRX' " >> $BDIR/etc/profile.d/less_custom_config.sh
    chmod +x $BDIR/etc/profile.d/less_custom_config.sh
    mkdir -p $BDIR/etc/rc.local
    echo "# ln -sf /etc/X11/xinit/xinitrc{.xfce,}" >> $BDIR/etc/rc.local
    echo "# loadkeys la-latin1" >> $BDIR/etc/rc.local
    bash $LIVESLACKBDIR/$MAKEMOD -i  $BDIR/   0068-customconfig-0.0.1-x86_64.sxz
    echo "Done config module."
    echo "You can test the module contents with the command : "
    echo "unsquashfs -l 0068-customconfig-0.0.1-x86_64.sxz"
    echo "#####################################"
    echo 
fi
    
