#!/bin/bash
#Author: Kayzad Patel - RTT Systems Engineering
#Version 1.2
#This script removes Mcafee and Solidcore agent from selected servers
## disable sadmin user services #### 
echo "Disabling sadmin services"
    /usr/sbin/sadmin disable;
    sleep 20;
## stop and delete the solidcore services #####
echo "stopping and deleting  solidcore services"
if [ -x "/usr/local/mcafee/solidcore/scripts/scsrvc"];
then
    /usr/local/mcafee/solidcore/scripts/scsrvc stop
    /usr/local/mcafee/solidcore/tools/cleanup_inventory
fi
echo "stopping and deleting more  solidcore services"
    /etc/init.d/cma unload SOLIDCOR5000_LNX
    sleep 5; 
    chkconfig --del scsrvc	
### Removes RPM packages ####
echo "removing those wonderful solidcore RPMs"
    /bin/rpm --erase solidcoreS3 --noscripts
    sleep 10; 
   /bin/rpm --erase solidcoreS3-kmod --noscripts
    sleep 10;
#### Removes directory and dependencies #####
echo " argh, deleting all mcafee directories"
    /bin/rm --recursive --force /etc/mcafee/solidcore
    /bin/rm --recursive --force /var/log/mcafee/solidcore
    /bin/rm --recursive --force /usr/local/mcafee/solidcore
    /bin/rm --recursive --force /opt/bitrock/solidcoreS3-*
    /bin/rm --force /tmp/solidcore.log
    /bin/rm --force /tmp/.scsrvc-lock
    /bin/rm --recursive --force /mcafee/
    /bin/rm --recursive --force /usr/bin/sadmin
	
echo "Removing Mcafee RPMS"
sleep 5;

    /bin/rpm --erase MFEcma
    sleep 10;    
    /bin/rpm --erase MFErt
    sleep 10;	
if [ -d "/opt/McAfee/cma" ]; 
then
     /bin/rm --recursive --force /opt/McAfee/cma/
fi
if [ -d "/etc/cma.d"];
then
    /bin/rm --recursive --force /etc/cma.d/
fi
exit 0;
