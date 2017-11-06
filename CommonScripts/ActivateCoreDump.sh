#!/bin/bash

DIR=/var/core
PATTERN=core-%e.%p

if [ ! -d "$DIR" ]; then
    mkdir "$DIR"
fi
chmod 777 "$DIR"

    echo "root       hard        core        unlimited" > /etc/security/limits.d/core.conf
    echo "root       soft        core        unlimited" >> /etc/security/limits.d/core.conf

    sed -i '/#DefaultLimitCORE/ c\DefaultLimitCORE=infinity' /etc/systemd/system.conf

    echo "kernel.core_pattern=$DIR/$PATTERN" > /etc/sysctl.d/core.conf
    echo "kernel.core_uses_pid=1" >> /etc/sysctl.d/core.conf
    echo "fs.suid_dumpable=2" >> /etc/sysctl.d/core.conf

   echo "Please Reboot the server to enable core.dump ..!!!!!"
   echo "Do you wish to reboot (y/n) ?"
read yn

yy=${yn:0:1}
if [ $yy == "y" ] || [ $yy == "Y" ];then
reboot
exit;
else
#fi
#if [ $y == "n" ] || [ $yy == "N" ];then
#echo "core.dump will enable after reboot the system";
echo "$DIR/$PATTERN" > /proc/sys/kernel/core_pattern
echo 1 > /proc/sys/kernel/core_uses_pid
ulimit -c unlimited
exit;
fi


	

