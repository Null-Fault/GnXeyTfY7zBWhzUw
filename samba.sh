sambausername=samba
adduser --no-create-home --disabled-password --disabled-login $sambausername
smbpasswd -a $sambausername
