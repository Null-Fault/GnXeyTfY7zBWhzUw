# Setup basic lab
# https://www.redhat.com/sysadmin/container-systemd-persist-reboot

echo "PermitRootLogin yes" > /etc/ssh/sshd_config.d/rootlogin.conf

useradd pdmn
passwd pdmn

loginctl enable-linger pdmn
