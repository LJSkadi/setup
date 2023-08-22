#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# inspired by
# https://gist.github.com/codeinthehole/26b37efa67041e1307db
# https://github.com/why-jay/osx-init/blob/master/install.sh
# https://github.com/timsutton/osx-vm-templates/blob/master/scripts/xcode-cli-tools.sh

# PRECONDITIONS
# 1)
# make sure the file is executable
# chmod +x osx_setup_script.sh
#
# 2)
# Your password may be necessary for some packages
#
# 3)
# https://docs.brew.sh/Installation#macos-requirements
xcode-select --install
# (_xcode-select installation_ installs git already, however git will be installed via brew packages as well to install as much as possible the brew way
#  this way you benefit from frequent brew updates)
# 
# 4) don't let the “Operation not permitted” error bite you
# Please make sure you system settings allow the termianl full disk access
# https://osxdaily.com/2018/10/09/fix-operation-not-permitted-terminal-error-macos/

# `set -eu` causes an 'unbound variable' error in case SUDO_USER is not set
SUDO_USER=$(whoami)

# Check for Homebrew, install if not installed
if test ! $(which brew); then
    echo "Installing homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

brew update
brew upgrade

# find the CLI Tools update
echo "find CLI tools update"
PROD=$(softwareupdate -l | grep "\*.*Command Line" | head -n 1 | awk -F"*" '{print $2}' | sed -e 's/^ *//' | tr -d '\n') || true
# install it
if [[ ! -z "$PROD" ]]; then
  softwareupdate -i "$PROD" --verbose
fi

echo "install git and config"
brew install git
brew install gh

git config --global user.name "Elliot Skadi"
git config --global user.email lj.skadi@gmail.com
git config --global init.defaultBranch main

echo "update iterm2 and zsh"
brew cask install iterm2
brew install zsh zsh-completions


sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k

echo "export ZSH_THEME=powerlevel9k/powerlevel9" >> ~/.zshrc
echo "export POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir rbenv vcs)" >> ~/.zshrc
echo "export POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status root_indicator background_jobs history time)" >> ~/.zshrc
echo "export POWERLEVEL9K_PROMPT_ON_NEWLINE=true" >> ~/.zshrc
# Add a space in the first prompt
echo "export POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="%f"" >> ~/.zshrc

echo "install gnu tools and utilities"
# GNU core utilities
brew install coreutils
brew install gnu-sed
brew install gnu-tar
brew install gnu-indent
brew install gnu-which

# GNU tools
brew install findutils

echo "install java"
# https://github.com/AdoptOpenJDK/homebrew-openjdk
brew tap AdoptOpenJDK/openjdk
brew install --cask adoptopenjdk
brew install --cask adoptopenjdk8
brew install --cask adoptopenjdk11
brew install --cask adoptopenjdk14
brew install --cask adoptopenjdk15

PACKAGES=(
   ack # Search tool like grep, but optimized for programmers
    ansible # Automate deployment, configuration, and upgrading
    ant # Java build tool
    aws-iam-authenticator
    awscli # Official Amazon AWS command-line interface
    brew-cask-completion # Bash & Fish completion for brew-cask
    coreutils # GNU File, Shell, and Text utilities
    curl # Get a file from an HTTP, HTTPS or FTP server
    docker # Pack, ship and run any application as a lightweight container
    docker-completion # Bash, Zsh and Fish completion for Docker
    docker-compose # Isolated development environments using Docker
    fx
    fzf # Command-line fuzzy finder written in Go
    git # Distributed revision control system
    grafana # Gorgeous metric visualizations and dashboards for timeseries databases.
    hashcat # World's fastest and most advanced password recovery utility
    heroku # Command-line client for the cloud PaaS
    highlight # Convert source code to formatted text with syntax highlighting
    imagemagick
    jenv # Manage your Java environment
    john # Featureful UNIX password cracker
    jq # Lightweight and flexible command-line JSON processor
    jruby # Ruby implementation in pure Java
    kafka # Publish-subscribe messaging rethought as a distributed commit log
    kibana # Analytics and search dashboard for Elasticsearch
    kubernetes-cli
    kubernetes-cli # Kubernetes command-line interface
    kubernetes-helm
    kubernetes-helm # The Kubernetes package manager
    libtool # Generic library support script
    libyaml # YAML Parser
    lynx # Text-based web browser
    make
    markdown
    maven # Java-based project management
    memcached
    minikube
    mysql # Open source relational database management system
    netcat # Utility for managing network connections
    nginx # HTTP(S) server and reverse proxy, and IMAP/POP3 proxy server
    nmap # Port scanning utility for large networks
    node # Platform built on V8 to build network applications
    nvm # Manage multiple Node.js version
    openssh # OpenBSD freely-licensed SSH connectivity tools
    pidof # Display the PID number for a given process name
    pkg-config # Manage compile and link flags for libraries
    putty # Implementation of Telnet and SSH
    rbenv # Ruby version manager
    readline # Library for command-line editing
    redis # Persistent key-value database, with built-in net interface
    ruby # Powerful, clean, object-oriented scripting language
    ruby-build # Install various Ruby versions and implementations
    ruby-install # Install Ruby, JRuby, Rubinius, MagLev, or mruby
    rust # Safe, concurrent, practical language
    speedtest-cli # Command-line interface for https://speedtest.net bandwidth tests
    terraform # Tool to build, change, and version infrastructure
    tree # Display directories as trees (with optional color/HTML output)
    uncrustify # Source code beautifier
    vim
    wget # Internet file retriever
    yarn # JavaScript package manager
    youtube-dl # Download YouTube videos from the command-line
    zsh # UNIX shell (command interpreter)
    zsh-autosuggestions # Fish-like fast/unobtrusive autosuggestions for zsh.
    zsh-completions # Additional completion definitions for zsh
    zsh-syntax-highlighting # Fish shell like syntax highlighting for zsh
)

echo "Installing packages..."
brew install ${PACKAGES[@]}

CASKS=(
    android-studio
    chromium
    firefox
    gimp
    google-chrome
    keepingyouawake
    rectangle
    slack
    telegram
    visual-studio-code
    vlc
    zoom
)

echo "Installing cask apps..."
sudo -u $SUDO_USER brew install --cask ${CASKS[@]}

sudo -u $SUDO_USER brew install --cask docker
#or
#brew install colima

echo "Installing Python packages..."
sudo -u $SUDO_USER pip3 install --upgrade pip
sudo -u $SUDO_USER pip3 install --upgrade setuptools

PYTHON_PACKAGES=(
    ipython
    virtualenv
    virtualenvwrapper
)
sudo -u $SUDO_USER pip3 install ${PYTHON_PACKAGES[@]}

echo "Installing global npm packages..."
sudo -u $SUDO_USER npm install marked -g

echo "Cleaning up"
brew cleanup
echo "Ask the doctor"
brew doctor

echo "OSX bootstrapping done"