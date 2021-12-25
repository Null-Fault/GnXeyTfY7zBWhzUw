sudo apt update && sudo apt upgrade -y
sudo apt install vlc
sudo apt install keepassxc
sudo apt install steam

wget 'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb' -O chrome.deb
sudo apt install ./chrome.deb
rm ./chrome.deb

wget 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' -O vscode.deb
sudo apt install ./vscode.deb
rm ./vscode.deb

wget 'https://builds.parsecgaming.com/package/parsec-linux.deb' -O parsec.deb
sudo apt install ./parsec.deb
rm ./parsec.deb
