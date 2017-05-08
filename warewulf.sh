#!/bin/bash

#Checks that arguemnt 1 is a valid interface by checking ifconfig
check_interface() {
    #Check that the passed in network interface exists
    #The awk command will ignore the first line else output the first column
    for interface in `ifconfig -s | awk '{if(NR!=1)print $1}'`; do
        if [ $interface = $1 ]; then
            return 0
        fi
    done
    #Return 1 specifying it wasn't found
    return 1
}

#Check for root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 
    exit 1
fi

#Check that argument for network interface was provided
if [ $# -eq 0 ]; then
    echo "You need to supply the network interface you'd like warewulf to use"
    echo "Example: ./warewulf_setup.sh enp0s25"
    exit 1
fi

#Call check_interface to verify arguemnt
check_interface $1
RETURN_CODE=$?

#Check return code to see if interface exists
if [ "$RETURN_CODE" -eq "1" ]; then
    echo "Network interface $1 does not exist."
    exit 1
fi

# Make sure your system is up to date
# Install dependencies
yum upgrade -y
yum groups install Development\ Tools -y
yum install epel-release libselinux-devel libacl-devel libattr-devel mod_perl xinetd -y

# Download the software from the SVN repository.
# Rename the folder from "trunk" to "warewulf"
svn checkout https://warewulf.lbl.gov/svn/trunk
mv trunk warewulf

# We're going to use a function to help us accelerate compiling.
function buildit { cd $1 && ./autogen.sh && make dist-gzip && make distcheck && cp -fa warewulf-*.tar.gz ~/rpmbuild/SOURCES && rpmbuild -bb ./*.spec; cd $OLDPWD; }

# The RPMs we build need a place to go.
mkdir -p /root/rpmbuild/SOURCES

# CD into the directory then compile and install the warewulf modules
# This will also install any other dependencies
cd warewulf
buildit common
yum install ~/rpmbuild/RPMS/noarch/warewulf-common-* -y
buildit provision
yum install ~/rpmbuild/RPMS/x86_64/warewulf-provision-* -y
buildit vnfs
yum install ~/rpmbuild/RPMS/noarch/warewulf-vnfs-* -y
buildit cluster
yum install ~/rpmbuild/RPMS/x86_64/warewulf-cluster-* -y

# Change the network device to the network adapter selected earlier
echo "Changing network interface in /etc/warewulf/provision.conf to $1"
sed -c -i.bak "s/\(network device = \).*/\1$1/" /etc/warewulf/provision.conf

# Auto configure the DHCP server. 
# Then run the init program for warewulf
wwsh dhcp update
wwinit all

#Enable TFTP
#Allow TFTP and NFS through the firewall.
systemctl enable tftp
systemctl start tftp
firewall-cmd --zone=public --add-service=tftp --permanent
firewall-cmd --zone=public --add-service=nfs --permanent
firewall-cmd --reload

echo "All done. You are now ready to create your chroot evironment."
