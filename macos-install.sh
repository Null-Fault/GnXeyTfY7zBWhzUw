/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew tap microsoft/git
brew tap homebrew/cask
brew tap homebrew/cask-drivers
brew tap homebrew/core

brew install git
brew install iperf3

brew install --cask firefox
brew install --cask google-chrome
brew install --cask microsoft-teams
brew install --cask microsoft-remote-desktop
brew install --cask git-credential-manager-core
brew install --cask powershell
brew install --cask visual-studio-code
brew install --cask rectangle
brew install --cask macs-fan-control
brew install --cask keka
brew install --cask keepassxc
brew install --cask kodi
brew install --cask vlc
brew install --cask steam
brew install --cask nvidia-geforce-now
brew install --cask parsec

# Maybe
#brew install --cask jabra-direct
#brew install --cask vmware-fusion
#brew install --cask docker
#brew install --cask sidequest
