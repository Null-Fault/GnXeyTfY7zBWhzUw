sambausername=samba

adduser --no-create-home --disabled-password --disabled-login $sambausername
smbpasswd -a $sambausername
groupadd -g 1111 media
usermod -aG media $sambausername

share=//255.255.255.255/Share
mnt=/mnt/samba
mount -t cifs -o rw,username=$sambausername,uid=1000,gid=1111 $share $mnt
