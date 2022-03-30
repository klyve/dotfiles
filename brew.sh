#!/usr/bin/env bash

# sudo
sudo -v 

# Install homebrew
which -s brew
if [[ $? != 0 ]] ; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    brew update
fi

# Applications
brew install --cask slack
brew install --cask spotify
brew install --cask discord
brew install --cask 1password
brew install --cask alfred
brew install --cask alacritty
brew install --cask amethyst
brew install --cask altair-graphql-client

# Browsers
brew install --cask google-chrome

# tools
brew install --cask figma


# Development

brew install --cask docker
brew install stow
brew install kubectl
brew install kubectx
brew install jq
brew install protobuf
brew install argoproj/tap/argo
brew install azure-cli
brew install cmake

brew install go
brew install node
npm install -g n
npm install -g react-native-cli
npm install -g nodemon
npm install -g expo-cli
# https://yarnpkg.com/getting-started/install
npm i -g corepack
corepack enable

# Terminal additions
brew install gpg
brew install neofetch
brew install gh
brew install ripgrep
brew install ack
brew install fzf
$(brew --prefix)/opt/fzf/install --all
brew install ack
brew install httpie
brew install z
brew install tmux
brew install tmuxinator
brew install zsh-autosuggestions
brew install romkatv/powerlevel10k/powerlevel10k
brew install exa
brew install pinentry-mac


brew tap homebrew/cask-fonts
brew install --cask font-fira-code
brew install --cask font-fira-mono

# Nvim
brew install neovim
pip3 install pynvim --upgrade
yarn global add neovim

# set up gnupg
echo "pinentry-program $(which pinentry-mac)" >> ~/.gnupg/gpg-agent.conf
killall gpg-agent


if ! type rvm > /dev/null; then
  gpg --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
  \curl -sSL https://get.rvm.io | bash -s stable
  [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" 
fi

# If ruby version is not 3.1.1
if ! rvm list | grep -q 3.1.1; then
  rvm install 3.1.1
fi

