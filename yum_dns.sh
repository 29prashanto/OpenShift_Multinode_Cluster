#!/bin/bash
set -o nounset
set -o errexit

hostnamectl  set-hostname  yumserver.lw.com

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

#ftp-server

yum install vsftpd -y

systemctl  start  vsftpd

systemctl  enable  vsftpd

systemctl  stop firewalld.service 

systemctl   disable firewalld.service 

mkdir /var/ftp/optional

#yum install python3 -y
#pip install gdown
#Replace ******************** with googledrive share id

# gdown   --id   *************************    --output    rhel-7-server-optional-20180417.iso
mount -o loop rhel-7-server-optional-20180417.iso   /var/ftp/optional/

mkdir /var/ftp/rhscl
# gdown   --id   *************************    --output    rhel-server-rhscl-7-20180417.iso
mount -o loop rhel-server-rhscl-7-20180417.iso  /var/ftp/rhscl/

mkdir /var/ftp/updates
# gdown   --id   *************************    --output    rhel-7.5-server-updates-20180417.iso
mount -o loop rhel-7.5-server-updates-20180417.iso  /var/ftp/updates/

mkdir /var/ftp/ose
# gdown   --id   *************************    --output    rhel-7-server-ose-3.9-x86_64-20180329.iso
mount -o loop rhel-7-server-ose-3.9-x86_64-20180329.iso /var/ftp/ose/

mkdir /var/ftp/additional
# gdown   --id   *************************    --output    rhel-7-server-additional-20180417.iso
mount -o loop rhel-7-server-additional-20180417.iso /var/ftp/additional/

mkdir /var/ftp/supplementary
# gdown   --id   *************************    --output    rhel-7-server-supplementary-20180417.iso
mount -o loop rhel-7-server-supplementary-20180417.iso /var/ftp/supplementary/

cat <<EOF >> /etc/fstab
/root/rhel-7-server-optional-20180417.iso                 /var/ftp/optional/    iso9660         loop        0 0
/root/rhel-server-rhscl-7-20180417.iso                   /var/ftp/rhscl/        iso9660         loop        0 0
/root/rhel-7.5-server-updates-20180417.iso              /var/ftp/updates/       iso9660         loop        0 0
/root/rhel-7-server-ose-3.9-x86_64-20180329.iso        /var/ftp/ose/            iso9660         loop        0 0
/root/rhel-7-server-additional-20180417.iso           /var/ftp/additional/      iso9660         loop        0 0
/root/rhel-7-server-supplementary-20180417.iso       /var/ftp/supplementary/    iso9660         loop        0 0
EOF

mount -a

yum install createrepo -y

createrepo -v /var/ftp/

#DNS-server

yum install dnsmasq -y
systemctl start dnsmasq
systemctl enable dnsmasq

cat <<EOF >> /etc/hosts
192.168.43.13      master.lw.com        master
192.168.43.15      node1.lw.com         node1
192.168.43.16      node2.lw.com         node2
192.168.43.14      registry.lw.com      registry
192.168.43.17      workstation.lw.com   workstation
EOF

#dns_forwarder
cat <<EOF >> /etc/dnsmasq.conf
resolv-file=/etc/realdns
EOF

cat <<EOF  >> /etc/realdns
nameserver 8.8.8.8
EOF

systemctl restart dnsmasq

# /myapp.lw.com will resolve to master ip
cat <<EOF >> /etc/dnsmasq.conf
address=/myapp.lw.com/192.168.43.13
EOF

systemctl restart dnsmasq



