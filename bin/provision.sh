#!/bin/bash

USER_ME=${USER_ME:-pat}

if [ $(id -u) -ne 0 ]; then
  echo "Must be run as root"
  errors=true
fi

if ! [[ $(pwd) =~ ^/home/[a-z]+$ ]]; then
  echo 'Must be run from /home/user (/root invalid)'
  errors=true
fi

if [ -n "$errors" ]; then
  exit 1
fi

installDeps() {
  sudo apt-get update && sudo apt-get install -y \
    vim \
    tmux \
    git \
    apt-transport-https \
    wmctrl \
    recordmydesktop \
    ffmpeg \
    xclip \
    dialog \
    xinput \
    xdotool \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
}

installSublime() {
  wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
  echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
  sudo apt-get update
  sudo apt-get install sublime-text
  ln -s /usr/bin/subl /usr/bin/sub
}

pullHomeRepo() {
  sudo -u $USER_ME git init
  sudo -u $USER_ME git remote add origin git@github.com:p-mcgowan/home.git
  sudo -u $USER_ME git pull origin master

  sudo -u $USER_ME mkdir -p source/ tmp/ .config
  sudo -u $USER_ME touch .machinerc

  rm -rf Desktop Templates Public Music Videos Snapshots
}

pullConfigRepo() {
  cd .config
  sudo -u $USER_ME git init
  sudo -u $USER_ME git remote add origin git@github.com:p-mcgowan/config.git
  sudo -u $USER_ME git pull origin master
  cd - &> /dev/null
}

installNVM() {
  # nvm stuff in machine specific bashrc
  if ! grep -q 'NVM_DIR' .machinerc; then
    cat <<'NVMSTUFF' >> .machinerc
if [ -z $NVM_DIR ]; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi
NVMSTUFF
  fi
  local getnvm=$(curl -s https://raw.githubusercontent.com/nvm-sh/nvm/master/README.md |grep -om1 '^curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v[0-9.]\+/install.sh')
  if [ -n "$getnvm" ]; then
    eval $getnvm | sudo -u $USER_ME bash
  else
    echo 'could not grep for latest - trying 0.35.3'
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | sudo -u $USER_ME bash
  fi
}

cloneGoogler() {
  cd source
  sudo -u $USER_ME git clone git@github.com:p-mcgowan/google-productivity-tools.git googler
  cd - &> /dev/null
}

installDocker() {
  sudo apt-get remove docker docker-engine docker.io containerd runc
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo apt-get update
  sudo apt-get install docker-ce docker-ce-cli containerd.io

  sudo groupadd docker
  # sudo usermod -aG docker '<$USER> but not root'
  sudo usermod -aG docker $USER_ME
}

installDockerCompose() {
  sudo curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  # apparently never used this
  # sudo curl -L https://raw.githubusercontent.com/docker/compose/1.25.4/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
}

echo -e '\n\n'
pullHomeRepo
echo -e '\n\n'
pullConfigRepo
echo -e '\n\n'
cloneGoogler
echo -e '\n\n'
installSublime
echo -e '\n\n'
installNVM
echo -e '\n\n'
installDocker
echo -e '\n\n'
installDockerCompose
