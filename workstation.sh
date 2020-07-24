#!/bin/bash
set -o nounset
set -o errexit

hostnamectl  set-hostname  workstation.lw.com

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

cat <<EOF > /etc/yum.repos.d/ose.repo 
[ose]
baseurl=ftp://192.168.43.12/
gpgcheck=0
EOF

ssh-keygen -f ~/.ssh/id_rsa -N ''

for host in master.lw.com node1.lw.com node2.lw.com registry.lw.com workstation.lw.com ; do ssh-copy-id -i ~/.ssh/id_rsa.pub $host; done

yum install atomic-openshift-utils

mkdir /ws

cat <<EOF > /ws/ansible.cfg
[defaults]
remote_user = root
inventory = ./inventory
log_path = ./ansible.log
host_key_checking = False
EOF

cat <<EOF > /ws/inventory
[workstations]
workstation.lw.com

[nfs]
registry.lw.com

[masters]
master.lw.com

[etcd]
master.lw.com

[nodes]
master.lw.com
node1.lw.com
node2.lw.com

[OSEv3:children]
masters
etcd
nodes
nfs

#Variables needed by the prepare_install.yml playbook.
[nodes:vars]
#registry_local=registry.lw.com
registry_local=registry.access.redhat.com
use_overlay2_driver=true
insecure_registry=false
run_docker_offline=true
docker_storage_device=/dev/sdb

[OSEv3:vars]
#General Cluster Variables
openshift_deployment_type=openshift-enterprise
openshift_release=v3.9
openshift_image_tag=v3.9.14
openshift_disable_check=disk_availability,docker_storage,memory_availability


#Cluster Authentication Variables
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider', 'filename': '/etc/origin/master/htpasswd'}]
openshift_master_htpasswd_users={'admin':'$apr1$Vd4/F6nT$xYB.UFGvcZeWPdMoAXSZJ1', 'developer': '$apr1$jhQYVWRa$A6LOPTN0dkSYnsGEhaHr4.'}


#OpenShift Networking Variables
os_firewall_use_firewalld=true
openshift_master_api_port=443
openshift_master_console_port=443
openshift_master_default_subdomain=myapp.lw.com


#NFS is an unsupported configuration
openshift_enable_unsupported_configurations=true

#OCR configuration variables
openshift_hosted_registry_storage_kind=nfs
openshift_hosted_registry_storage_access_modes=['ReadWriteMany']
openshift_hosted_registry_storage_nfs_directory=/exports
openshift_hosted_registry_storage_nfs_options='*(rw,root_squash)'
openshift_hosted_registry_storage_volume_name=registry
openshift_hosted_registry_storage_volume_size=40Gi

#OAB's etcd configuration variables
openshift_hosted_etcd_storage_kind=nfs
openshift_hosted_etcd_storage_nfs_options="*(rw,root_squash,sync,no_wdelay)"
openshift_hosted_etcd_storage_nfs_directory=/exports
openshift_hosted_etcd_storage_volume_name=etcd-vol2
openshift_hosted_etcd_storage_access_modes=["ReadWriteOnce"]
openshift_hosted_etcd_storage_volume_size=1G
openshift_hosted_etcd_storage_labels={'storage': 'etcd'}


#Modifications Needed for a Disconnected Install
oreg_url=registry.access.redhat.com/openshift3/ose-${component}:${version}
openshift_examples_modify_imagestreams=true
#openshift_docker_additional_registries=registry.lw.com
openshift_docker_additional_registries=registry.access.redhat.com
openshift_docker_blocked_registries=docker.io
#openshift_docker_blocked_registries=registry.access.redhat.com,docker.io


#Image Prefixes
openshift_web_console_prefix=registry.access.redhat.com/openshift3/ose-
openshift_cockpit_deployer_prefix='registry.access.redhat.com/openshift3/'
openshift_service_catalog_image_prefix=registry.access.redhat.com/openshift3/ose-
template_service_broker_prefix=registry.access.redhat.com/openshift3/ose-
ansible_service_broker_image_prefix=registry.access.redhat.com/openshift3/ose-
ansible_service_broker_etcd_image_prefix=registry.access.redhat.com/rhel7/

[nodes]
master.lw.com
node1.lw.com openshift_node_labels="{'region':'infra', 'node-role.kubernetes.io/compute':'true'}"
node2.lw.com openshift_node_labels="{'region':'infra', 'node-role.kubernetes.io/compute':'true'}"
EOF

#ansible nodes --list-hosts  ==> to check the nodes list
#ansible node -m command -a id ==> to check connectivity

# Before installation chech eveything is fine.
cd /ws/
ansible-playbook /usr/share/ansible/openshift-ansible/playbook/prerequisites.yml 

#OpenShift installation
cd /ws/
ansible-playbook /usr/share/ansible/openshift-ansible/playbook/deploy_cluster.yml



