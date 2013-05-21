#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

echo -e "+---------------------------+\n| INITIALIZING |\n+---------------------------+"
CMDLOGPATH=`grep "CMD_LOG_FILE=" flows | cut -d\" -f2`
CMDLOGDIR=${CMDLOGPATH%/*}
CMDLOGFILE=${CMDLOGPATH##*/}
mkdir -p $CMDLOGDIR
touch $CMDLOGPATH
chmod a+w $CMDLOGPATH
echo "* Created command log $CMDLOGPATH"
echo "  WARNING: You may want to restrict write permission to this file to only allow users of this script"

FILTERDIR=`grep "FILTERDIR=" flows | cut -d\" -f2`
mkdir -p $FILTERDIR
echo "* Created filter directory $FILTERDIR"
cp -a filters/country/ $FILTERDIR
num=`ls $FILTERDIR/country | wc -l`
echo "  Added $num country filters"

CACHE=`grep "CACHE_DIR=" flows | cut -d\" -f2`
mkdir -p $CACHE
echo "* Created cache directory $CACHE"

cp man1.flows /usr/local/man/man1/
echo "* Created man entry for flows script"

echo -e "\n+-----------------------+\n| CREATING SSH KEY PAIR |\n+-----------------------+"
PRIVKEYPATH=`grep "PRIVKEY=" flows | cut -d\" -f2`
PRIVKEYDIR=${PRIVKEYPATH%/*}
PRIVKEY=${PRIVKEYPATH##*/}
mkdir -p $PRIVKEYDIR
ssh-keygen -t rsa -N "" -C "Flows key" -f $PRIVKEYPATH
chmod a+r $PRIVKEYPATH
echo -e "Host *\n\tTCPKeepAlive yes\n\tServerAliveInterval 60\nHost node01*\n\tIdentityFile ~/.ssh/$PRIVKEY\nHost node02*\n\tIdentityFile ~/.ssh/$PRIVKEY" > $PRIVKEYDIR/config
echo -e "WARNING: Read permission on the private keys has been granted for all users on the local system. This is to allow automatic setup of parallell processing for all users. If you are not comfortable with this, I would suggest you either create a group of users that get read permission, or you manually set up the ssh configuration for each user.\n"
echo "You need to manually add the public key ($PRIVKEY.pub) to the authorized_keys file of each node in the cluster. Then update $PRIVKEYDIR/config with the corresponding nodes."
