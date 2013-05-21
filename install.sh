#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

echo -e "+------------------------+\n| ADDING COUNTRY FILTERS |\n+------------------------+"
FILTERDIR=`grep "FILTERDIR=" flows | cut -d\" -f2`
mkdir -p $FILTERDIR
echo "Filter directory $FILTERDIR created"
cp -a filters/country/ $FILTERDIR
num=`ls $FILTERDIR/country | wc -l`
echo -e "Added $num country filters\n"

echo -e "+-----------------------+\n| CREATING SSH KEY PAIR |\n+-----------------------+"
PRIVKEYPATH=`grep "PRIVKEY=" flows | cut -d\" -f2`
PRIVKEYDIR=${PRIVKEYPATH%/*}
PRIVKEY=${PRIVKEYPATH##*/}
mkdir -p $PRIVKEYDIR
ssh-keygen -t rsa -N "" -C "Flows key" -f $PRIVKEYPATH
chmod g+r $PRIVKEYPATH
echo -e "WARNING: Read permission on the private keys has been granted for all users on the local system. This is to allow automatic setup of parallell processing for all users. If you are not comfortable with this, I would suggest you either create a group of users that get read permission, or you manually set up the ssh configuration for each user.\n"
echo "You need to manually add the public key ($PRIVKEY.pub) to the authorized_keys file of each node in the cluster"
