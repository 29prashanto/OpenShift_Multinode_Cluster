OpenShift MultiNode Cluster
===========================

Virtual Machine Configuration:
------------------------------

* CPU >= `2`
* RAM >= `4GB`
* Storage:
    * `100GB` 
    * `10GB`
* Network Card: `Bridge`
* Static IP
    * yum-server IP : `192.168.43.12`
    * Master IP : `192.168.43.13`
    * Registry IP : `192.168.43.14`
    * Node 1 IP : `192.168.43.15`
    * Node 2 IP : `192.168.43.16`
    * Workstation IP : `192.168.43.17`
    * DNS : `192.168.43.12`
    * Gateway : `192.168.43.1`



![alt text](https://raw.githubusercontent.com/29prashanto/OpenShift_Multinode_Cluster/master/OpenShift%20Multinode%20%20Cluster.png "OpenShift Cluster")

### Script Sequence
* `First VM`
  ``` sh
  [root@yumserver.lw.com ~]# chmod +x yum_dns.sh
  [root@yumserver.lw.com ~]# ./yum_dns.sh
  ```
* `Second VM`
  ``` sh
  [root@registry.lw.com ~]# chmod +x registry.sh
  [root@registry.lw.com ~]# ./registry.sh
  ```
* `Third VM`
  ``` sh
  [root@master.lw.com ~]# chmod +x master.sh
  [root@master.lw.com ~]# ./master.sh
  ```
* `Fourth VM`
  ``` sh
  [root@node1.lw.com ~]# chmod +x node1.sh
  [root@node1.lw.com ~]# ./node1.sh
  ```
* `Fifth VM`
  ``` sh
  [root@node2.lw.com ~]# chmod +x node2.sh
  [root@node2.lw.com ~]# ./node2.sh
  ```
* `Sixth VM`
  ```sh
  [root@workstation.lw.com ~]# chmod +x workstation.sh
  [root@workstation.lw.com ~]# ./workstation.sh
  ```
*Note :* `Workstation.lw.com` is used for Openshift Cluster installation. 
