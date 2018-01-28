clear
echo ""
read -p "Enter Obfuscated Port: " port

read -p "Enter Obfuscated Keyword (10 characters maximum): " keyword

#update system, install compiler and other dependent.
apt-get update
apt-get -y install gcc
apt-get -y install build-essential
apt-get -y install zlib1g-dev
apt-get -y install libssl-dev
 
#compile.
wget -O ofcssh.tar.gz https://github.com/brl/obfuscated-openssh/tarball/master
tar zxvf ofcssh.tar.gz
cd brl-obfuscated-openssh-ca93a2c
./configure
make
make install
#If no error occurred, then you might get
#the ssh daemon in /usr/local/sbin/sshd
#the ssh client will be in /usr/local/bin/ssh
#the config files will be in /usr/local/etc/
 
mv /usr/local/sbin/sshd /usr/sbin/sshd_ofc
cp /etc/ssh/sshd_config /etc/ssh/sshd_ofc_config

#Port 22 is handled by regular ssh daemon, so Port option is not required.
sed -i "s/Port /#Port /g" /etc/ssh/sshd_ofc_config

#obfuscated-openssh does not support UsePAM option.
sed -i "s/UsePAM /#UsePAM /g" /etc/ssh/sshd_ofc_config

#Add two additional configuration options.
echo "ObfuscateKeyword $keyword" | cat - /etc/ssh/sshd_ofc_config > temp && mv temp /etc/ssh/sshd_ofc_config
echo "ObfuscatedPort $port" | cat - /etc/ssh/sshd_ofc_config > temp && mv temp /etc/ssh/sshd_ofc_config

#finally, run it and set it to self-starting. If no error occurred, run "netstat -an", then you might see sshd_ofc binding to the port 1234
/usr/sbin/sshd_ofc -f /etc/ssh/sshd_ofc_config
sed -i -e '$i /usr/sbin/sshd_ofc -f /etc/ssh/sshd_ofc_config' /etc/rc.local

#echo "/usr/sbin/sshd_ofc -f /etc/ssh/sshd_ofc_config" > /etc/init.d/ssh_ofc
#chmod +x /etc/init.d/ssh_ofc
#update-rc.d ssh_ofc defaults
