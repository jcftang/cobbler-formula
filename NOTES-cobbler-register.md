The following is for setting up centos7 to do a first time once off
install to register new machines.

Edit /etc/cobbler/settings and enable the register new installs option.

Create cobbler repo for cobbler

    cobbler repo add --name=cobbler26-centos7 --breed=yum --mirror=http://download.opensuse.org/repositories/home:/libertas-ict:/cobbler26/CentOS_CentOS-7
    cobbler reposync

Or

    cobbler repo add --name=epel7 --breed=yum --mirror=http://ftp.heanet.ie/pub/fedora/epel/7/x86_64 --mirror-locally=false

Assuming the profile for centos7 exists

    cobbler profile edit --name Centos7-x86_64  --repos "cobbler26-centos7"

Or 
    cobbler profile edit --name Centos7-x86_64  --repos "epel7"

The steps below are done by the formula already

Make sure this snippet is included in the kickstart file

    cd /var/lib/cobbler/kickstarts/
    cp sample_end.ks sample_end-cr.ks

In the packages section add this

    $SNIPPET('cobbler_register_install_if_enabled')

Create a new snippet '/var/lib/cobbler/snippets/cobbler_register_install_if_enabled' with this content

    #if $str($getVar('register_new_installs','')) in [ "1", "true", "yes", "y" ]
    koan
    python-ethtool
    #end if
