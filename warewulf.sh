#/bin/bash

#Check for root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 
    exit 1
fi

#Check that argument for network interface was provided
if [$# -eq 0]; then
    echo "You need to supply the network interface you'd like warewulf to use"
    echo "Example: ./warewulf_setup.sh enp0s25"
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

echo "All done. You can now add nodes. wwnodescan is the fastest way to do this."


