#!/bin/env bash

###############################################################################
# Functions definitions
###############################################################################
check_live_user () {
    MSG="Checking if live user exists, otherwise creating it ..."
    echo "$MSG"
    sleep 2
    #if [ ! -d /home/live ]; then
    if [ x""==x"$(grep live /etc/passwd)" ]; then
	    useradd -d /home/live -G audio,cdrom,floppy,plugdev,video -m -s /bin/bash live
	    echo live:live | chpasswd
	    echo "Done."
    else
	    echo "User already exists."
    fi
}

config_shell_prompt () {
    # Install bash it
    echo "Configuring bashit"
    if [ ! -d /home/live/.bash_it ]; then
        cd /home/live || exit
        sudo -u live git clone --depth=1 https://github.com/Bash-it/bash-it.git /home/live/.bash_it
        sudo -u live /home/live/.bash_it/install.sh --silent
    else
        echo "Already configured"
    fi
}

###############################################################################
# Main 
###############################################################################
rm -f /var/log/log-install.txt 2>/dev/null
{
    cd "$HOME/repos/computer-labs/configurations"
    bash config_slackware.sh 
    COMPILE=NO bash ../packages/install_packages_slackware.sh
    check_live_user
    sudo -u live bash install_and_setup_doom_emacs.sh
    config_shell_prompt
    #sudo -u live bash fix_tz_xfce4.sh
} &>> /var/log/log-install.txt
