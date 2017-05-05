# Installing Warewulf on CentOS 7
Installing Warewulf involves downloading the software and compiling. After, it needs to be configured to operate with your environment. This guide was made orignally by [30jon](https://github.com/30jon) before I editied it and made my own changes.

First, escalate yourself and make sure your system is up to date. We also need to install some dependencies.
```
sudo su
yum upgrade
yum groups install Development\ Tools
yum install epel-release libselinux-devel libacl-devel libattr-devel mod_perl xinetd
```
Next you'll want to download the software from the SVN repository. I like to rename the folder from "trunk" to "warewulf"
```
svn checkout https://warewulf.lbl.gov/svn/trunk
mv trunk warewulf
```
We're going to use a function to help us accelerate compiling. This allows us to execute multiple commands with only one command
```
function buildit { cd $1 && ./autogen.sh && make dist-gzip && make distcheck && cp -fa warewulf-*.tar.gz ~/rpmbuild/SOURCES && rpmbuild -bb ./*.spec; cd $OLDPWD; }
```
The RPMs we build need a place to go. We'll create a directory for them.
```
mkdir -p /root/rpmbuild/SOURCES
```
CD into the directory then compile and install the warewulf modules. This will also install any other programs we need such as MariaDB, a dhcp server, and tftp.
```
cd warewulf
buildit common
yum install ~/rpmbuild/RPMS/noarch/warewulf-common-*
buildit provision
yum install ~/rpmbuild/RPMS/x86_64/warewulf-provision-*
buildit vnfs
yum install ~/rpmbuild/RPMS/noarch/warewulf-vnfs-*
buildit cluster
yum install ~/rpmbuild/RPMS/x86_64/warewulf-cluster-*
```

Next, we need to tell warewulf what network adapter to work with. Open `/etc/warewulf/provision.conf` with a text editor and change the network device to the network adapter you'd like it to use. In my case it was `enp0s25`.

Auto configure the DHCP server. Then run the init program for warewulf.
```
wwsh dhcp update
wwinit all
```

Then we need to enable tftp and allow it through the firewall
```
systemctl enable tftp
systemctl start tftp
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --zone=public --add-port=69/udp --permanent
firewall-cmd --reload
```

Now we need to create the chroot environment (Warewulf calls them VNFS) that all the nodes will boot from. This allows us edit a VNFS instead of needing to access every single node and edit them. We will name the VNFS "centos-7" and it will be stored under /var/chroots
```
wwmkchroot centos-7 /var/chroots/centos-7
wwvnfs --chroot /var/chroots/centos-7
wwbootstrap `uname -r`
```

With the environment created, now we can begin to add our nodes. This can be done by adding them one by one, but the easier way is to use an auto scanning function built into warewulf. It takes an IP address as a flag and increments the IP as it goes. If you want a node to have a different IP, you will need to add it manually, or edit it later. The command `wwnodescan` is the utility for this. The `netdev` flag is the adpater to use. The `ipaddr` is what IP to assign to the first node. The `netmask` flag is the subnet mask of the network adapter. The `vnfs` flag is the name of the chroot envrironment to use. The `bootstrap` flag sets what kernel to use for booting the node. The last thing to do is name the node. `c[1-10]` will look for 10 nodes that will be named c1, c2, c3, etc.
```
wwnodescan --netdev=enp0s25 --ipaddr=192.168.1.3 --netmask=255.255.255.0 --vnfs=centos-7 --bootstrap=`uname -r` c[1-3]
```
