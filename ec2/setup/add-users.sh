#!/bin/bash

echo "[YODA] Run add-users.sh ..."

USERS="
jlroot
"

# Adding our default sys admin users with there wheel priviledges and ssh keys

# first make our wheel user group available for sudo

if [ ! -f "/yoda/ec2/etc/sudoers_wheel" ]; then
    # no wheel cfg for sudoers available, dont mess with users yet
    exit 0
fi

cp /yoda/ec2/etc/sudoers_wheel /etc/sudoers.d/sudoers_wheel
chown root:root /etc/sudoers.d/sudoers_wheel
chmod 440 /etc/sudoers.d/sudoers_wheel

# now create our users
add_user() {
    tuser=$1

    test="$(grep ^${tuser}: /etc/passwd)"
    if [ -n "${test}" ]; then
	echo "User ${tuser} is on the system, contact root"
	return 1
    fi
    
    if [ ! -f "/yoda/ec2/etc/ssh_pubkeys/$tuser.pub" ]; then
	echo "Like to add user $tuser, but couldnt find his ssh public key..."
	return 0
    fi

    USERDIR="/home/$tuser"

    echo "add user $tuser"
    /usr/sbin/useradd -m $tuser
    mkdir $USERDIR/.ssh
    touch $USERDIR/.ssh/authorized_keys

    cat /yoda/ec2/etc/ssh_pubkeys/$tuser.pub >> $USERDIR/.ssh/authorized_keys

    chown $tuser:$tuser -R $USERDIR/.ssh
#    chmod 600 $USERDIR/.ssh/authorized_keys
#    chmod 700 $USERDIR/.ssh

    /usr/sbin/usermod -a -G wheel $tuser

    return 1
}

for newuser in $USERS; do
    add_user $newuser
    if [ $? == 1 ]; then
	echo "[YODA] Created new wheel user $newuser."
	if [ $newuser = "jlroot" ]; then
	    # check if pub key correct created so we can delete the ec2 default user "ec2-user"
	    OK=`cmp --silent /yoda/ec2/etc/ssh_pubkeys/jlroot.pub /home/jlroot/.ssh/authorized_keys || echo "NOT OK"`

	    if [ "x$OK" = "x" ]; then
		echo "[YODA] !!! New jlroot master account created and ssh seems fine !!!"
		echo "[YODA] !!! Deleting the default ec2 user 'ec2-user' !!!"
		userdel -r ec2-user
	    else
		echo "[YODA] New jlroot users ssh key seems corrupt. Use default ec2 user 'ec2-user' to connect and fix."
	    fi
	fi
	
	chmod 600 /home/$newuser/.ssh/authorized_keys
	chmod 700 /home/$newuser/.ssh
    fi
done

