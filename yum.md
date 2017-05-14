# Installing yum in the chroot environment

The chroot will not have yum installed in it by default. This makes upgrading and installing new software a pain. We can add yum to it very
easily. We're going to use yum to install yum. 

The `config` and `installroot` flags can be used to tell yum where to perform operations on. To install yum, set these flags equal to the 
path of the chroot
```
sudo bash
yum --config=/var/chroots/centos-7 --installroot=/var/chroots/centos-7/ install yum
```

Now you need DNS resolution in your chroot. You can copy `/etc/resolv.conf` to the chroot to do this.
```
cp /etc/resolv.conf /var/chroots/centos-7/etc/resolv.conf
```

Finally you'll want the epel to allows for more packages. Chroot into the environment and install it
```
chroot /var/chroots/centos-7
wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm
rpm -ivh epel-release-7-9.noarch.rpm
rm epel-release-7-9.noarch.rpm
```
