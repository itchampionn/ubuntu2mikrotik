#!/bin/bash

ADDRESS=`ip addr show enp0s3 | grep global | cut -d' ' -f 6 | head -n 1`
GATEWAY=`ip route list | grep default | cut -d' ' -f 3`
# Raw disk image https://mikrotik.com/download#chr
VERSIONCHR=7.11.2
 
wget -4 https://download.mikrotik.com/routeros/$VERSIONCHR/chr-$VERSIONCHR.img.zip -O chr.img.zip
gunzip -c chr.img.zip > chr.img
mount -o loop,offset=33571840 chr.img /mnt
apt install -y pwgen coreutils
PASSWORD=$(pwgen 12 1)
echo "Username: admin"
echo "Password: $PASSWORD"
echo "/ip address add address=$ADDRESS interface=[/interface ethernet find where name=ether1]" > /mnt/rw/autorun.scr
echo "/ip route add gateway=$GATEWAY" >> /mnt/rw/autorun.scr
echo "/ip service disable telnet" >> /mnt/rw/autorun.scr
echo "/user set 0 name=admin password=$PASSWORD" >> /mnt/rw/autorun.scr
echo "/ip dns set server=8.8.8.8,1.1.1.1" >> /mnt/rw/autorun.scr
# remount all mounted filesystems to read-only mode
echo u > /proc/sysrq-trigger
dd if=chr.img bs=1024 of=/dev/vda
echo "sync disk"
# synchronize all mounted filesystems
echo s > /proc/sysrq-trigger
echo "Sleep 60 seconds"
read -t 60 -u 1
echo "Ok, reboot"
# perform an immediate OS reboot similar to the RESET button (without synchronising and unmounting file systems)
echo b > /proc/sysrq-trigger
