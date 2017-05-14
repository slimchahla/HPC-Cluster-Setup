# Installing PDSH on CentOS 7 warewulf cluster
Sometime you need to execute a command on all your nodes. If you only have a few, it's not too much trouble to do it one by one, but you'll
quicky find this tedious. [PDSH](https://github.com/grondo/pdsh) is a multithreaded remote shell client which executes commands on multiple
remote hosts in parallel. This allows you to quickly execute commands on all your nodes at once.

Make sure warewulf is working and yum works in the chroot before you do this.

First escalate yourself and install pdsh on your headnode.
```
sudo bash
yum install pdsh
```

Then tell pdsh to use SSH and where to find the list of machines.
```
echo export PDSH_RCMD_TYPE='ssh' > /etc/profile.d/pdsh.sh
echo export WCOLL='/etc/pdsh/machines' >> /etc/profile.d/pdsh.sh
```

Now create the directory.
```
mkdir /etc/pdsh
```

Now open `/etc/pdsh/machines` in a text edtior and add the IP or hostname (hostname is better) of each node you have (except the head node). 
Each entry should be newline seperated. Example:
```
c1
c2
c3
```

Chroot into the chroot environment and install pdsh. Finally, repackage the VNFS
```
chroot /var/chroots/centos-7
yum install pdsh
exit
wwvnfs --chroot /var/chroots/centos-7
```

Reboot the nodes and they'll all have PDSH ready to go. To execute a command on all nodes just append `pdsh` to the front of the command.
```
pdsh hostname
```
