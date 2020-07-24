#!/bin/bash
set -o nounset
set -o errexit

hostnamectl  set-hostname  master.lw.com

cat <<EOF > /etc/selinux/config
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=permissive
# SELINUXTYPE= can take one of three two values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected. 
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted 
EOF

mkdir /dvd

mount /dev/cdrom  /dvd/

cat <<EOF > /etc/yum.repos.d/dvd.repo 
[local_yum]
baseurl=file:///dvd
gpgcheck=0
EOF

cat <<EOF >> /etc/fstab
/dev/cdrom  /dvd    iso9660 defaults    0   0
EOF

yum install vim net-tools bash-completion -y

systemctl  restart NetworkManager

exec bash

#put ftp server ip here
cat <<EOF > /etc/yum.repos.d/ose.repo 
[ose]
baseurl=ftp://192.168.43.12/
gpgcheck=0
EOF