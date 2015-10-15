#!/bin/bash
# Clone from the Fedora 22 image
#FROM fedora:22

MAINTAINER Jan Pazdziora

# Install FreeIPA server
mkdir -p /run/lock ; dnf install -y freeipa-server bind bind-dyndb-ldap perl && dnf clean all

#cp dbus.service /etc/systemd/system/dbus.service
ln -sf dbus.service /etc/systemd/system/messagebus.service
#cp httpd.service /etc/systemd/system/httpd.service

#cp systemctl /usr/bin/systemctl
#cp systemctl-socket-daemon /usr/bin/systemctl-socket-daemon

#cp ipa-server-configure-first /usr/sbin/ipa-server-configure-first

chmod -v +x systemctl systemctl-socket-daemon ipa-server-configure-first

groupadd -g 389 dirsrv ; useradd -u 389 -g 389 -c 'DS System User' -d '/var/lib/dirsrv' --no-create-home -s '/sbin/nologin' dirsrv

cp volume-data-list /etc/volume-data-list
cp volume-data-mv-list /etc/volume-data-mv-list
set -e ; cd / ; mkdir /data-template ; cat /etc/volume-data-list | while read i ; do echo $i ; if [ -e $i ] ; then tar cf - .$i | ( cd /data-template && tar xf - ) ; fi ; mkdir -p $( dirname $i ) ; if [ "$i" == /var/log/ ] ; then mv /var/log /var/log-removed ; else rm -rf $i ; fi ; ln -sf /data${i%/} ${i%/} ; done
cp volume-data-autoupdate /etc/volume-data-autoupdate
rm -rf /var/log-removed
mv /data-template/etc/dirsrv/schema /usr/share/dirsrv/schema && ln -s /usr/share/dirsrv/schema /data-template/etc/dirsrv/schema
echo 0.5 > /etc/volume-version
uuidgen > /data-template/build-id

#EXPOSE 53/udp 53 80 443 389 636 88 464 88/udp 464/udp 123/udp 7389 9443 9444 9445

#VOLUME /data

#ENTRYPOINT /usr/sbin/ipa-server-configure-first
./ipa-server-configure-first
