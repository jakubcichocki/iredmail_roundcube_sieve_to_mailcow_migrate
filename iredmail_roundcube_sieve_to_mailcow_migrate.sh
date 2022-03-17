#!/bin/bash
# Quick bash tool for migrate iRedmail roundcube sieve to mailcow sieve
# Author: Jakub Cichocki <j.cichocki@cogitech.pl>

VMAIL_DIR=/var/vmail/vmail1
SieveSymlink=sieve/dovecot.sieve
SieveSvbin=sieve/dovecot.svbin
CowmailSieveDir=/var/vmail/vmail1/sieve/

for d in */ ; do
    DOMAIN=${d:0:-1};
    echo 'Migrate for' $DOMAIN;
    cd $VMAIL_DIR/$DOMAIN;
    for u in */ ; do 
	USERNAME=${u:0:-1}@$DOMAIN
    	echo Migration $USERNAME
	if [ -d $u ] 
	then 
		cd $u
		if [ -L $SieveSymlink ]; then
			SieveRealFile=$(readlink -n  $SieveSymlink)
                	SieveFileName=$(basename $SieveRealFile)
			echo Remove old symlink $SieveSymlink
			rm $SieveSymlink
			echo Create new symlink $SieveFileName to ${CowmailSieveDir}${USERNAME}.sieve
			ln -s $VMAIL_DIR/$DOMAIN/$USERNAME/sieve/$SieveFileName ${CowmailSieveDir}${USERNAME}.sieve
			echo Move sbvin file
			mv $SieveSvbin  ${CowmailSieveDir}${USERNAME}.svbin
		 	cd ../
		else
			echo Sieve for $USERNAME not exist, skip
			cd ../
		fi
	fi
    done
    cd ../
done
echo Set sieve permission
chown 5000:5000 ${CowmailSieveDir}*
