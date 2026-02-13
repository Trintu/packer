# #!/usr/bin/env bash
# # ubuntu version of provision.sh
INSTALL_UPDATES=true
INSTALL_OPENVOX=true

echo "Provisioning phase 1 - Starting: Mirror, SELinux and basic packages"
export DEBIAN_FRONTEND=noninteractive
apt-get clean all -y
apt-get update -y
apt-get install pv perl mc net-tools -y

# set locale
sudo update-locale LANG=en_US.UTF-8

if [ "$INSTALL_UPDATES" == "true" ]; then
    echo "Provisioning phase 1 - system updates"
    export DEBIAN_FRONTEND=noninteractive
    apt-get -y -q upgrade
    apt-get -y -q clean all
else
    echo "Provisioning phase 1 - skipping system updates"
fi

# disable selinux
echo "Provisioning phase 1 - disabling SELinux"
if [ -f /etc/sysconfig/selinux ]; then
  sed -i /etc/sysconfig/selinux -r -e 's/^SELINUX=.*/SELINUX=disabled/g'||true
fi

if [ -f /etc/selinux/config ]; then
  sed -i /etc/selinux/config -r -e 's/^SELINUX=.*/SELINUX=disabled/g'||true
fi

echo "Provisioning phase 1 - all done"



# openvox
if [ "$INSTALL_OPENVOX" == "true" ]; then

    echo "Provisioning phase 2 - Puppet Agent"
    # puppet 7.x repository
    export DEBIAN_FRONTEND=noninteractive
    wget https://apt.voxpupuli.org/openvox8-release-ubuntu25.04.deb
    dpkg -i openvox8-release-ubuntu25.04.deb
    rm -rfv openvox8-release-ubuntu25.04.deb
    apt-get update -y

    apt-get -y install install openvox-agent
    echo "Provisioning phase 2 - OpenVox Agent cleaning"
    systemctl stop puppet
    systemctl disable puppet
    if [ -d /etc/puppetlabs/puppet/ssl ]; then
        rm -rf /etc/puppetlabs/puppet/ssl
    fi

    if [ -f /tmp/puppet.conf ]; then
        mv /tmp/puppet.conf /etc/puppetlabs/puppet/puppet.conf
    fi
else
    echo "Provisioning phase 2 - Skipping Openvox agent"
fi
echo "Provisioning phase 2 - Done"
# misc
echo "Provisioning phase 3 - Timezone"
timedatectl set-timezone UTC --no-ask-password



echo "Provisioning phase 4 - Final updates and cleaning up"

if [ "$INSTALL_UPDATES" == "true" ]; then
    echo "Provisioning phase 4 - system final updates"
    export DEBIAN_FRONTEND=noninteractive
    apt-get -y -q upgrade
    apt-get -y -q clean all
else
    echo "Provisioning phase 4 - skipping system final updates"
fi
echo "Provisioning phase 4 - Done"
echo "Provisioning done - all phases"