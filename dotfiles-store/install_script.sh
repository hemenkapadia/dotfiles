#!/bin/bash

# Check sudo.
# If credentials not already cached, ask for password and cache credentials.
# If already cached, increase sudo timeout by 5 min
sudo -v && exit 1 'Sudo access needed to execute this script'

# First update
# Check if update is needed
dialog --title "Update" \
  --yesno "Do you want to run apt-get update ?" 8 45
if [[ "$?" -eq 0 ]]; then
  echo " >>> Updating apt list ...."
  sudo apt-get update
fi
clear

# Install Base dependencies 
dialog --title "Install dependencies" \
  --yesno "Do you want to install base dependencies (recommended) ?" 8 55
if [[ "$?" -eq 0 ]]; then
  # Install base dependencies
  echo ">>> Installing base dependencies ...."
  sudo apt install -y dialog tree wget curl snapd openssl \
                      python3 python3-virtualenv python3-pip \
                      apt-transport-https ca-certificates gnupg-agent \
                      software-properties-common
fi
clear


# Check if upgrade is needed
dialog --title "Upgrade" \
  --yesno "Do you want to run apt-get upgrade ?" 8 55
if [[ "$?" -eq 0 ]]; then
  echo ">>> Upgrading system ...."
  sudo apt-get upgrade -y
fi
clear


# Offer list of applications to select for installation
cmd=(dialog --separate-output --checklist "Please Select Software you want to install:" 22 76 16)
options=(
  01  "Git" off
  02  "Git SSH keys" off
  03  "dotdrop" off
  04  "Tig" off
  05  "Lazygit" off
  06  "tmux" off
  07  "Miniconda" off
  08  "Visual Studio Code" off
  09  "vim" off
  10  "VirtualBox and Vagrant" off
  11  "Docker CE" off
  12  "NodeJS LTS using n-install" off
  13  "Ubuntu Restricted Extras" off
  14  "Jetbrains Toolbox" off
  15  "Slack" off
  16  "Mailspring" off
  17  "MineTime" off
)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear

for choice in $choices; do
  case $choice in
    01) # Install Git
      echo ""
      echo ">>> Installing Git ...."
      sudo add-apt-repository ppa:git-core/ppa
      sudo apt-get update
      sudo apt install -y git
      echo ">>> Git Installation completed."
      echo ">>> Configuring Git user.name and user.email...."
      read -p "Enter Git configuration user.name: " username
      read -p "Enter Git configuration user.email: " useremail
      git config --global user.name "${username}"
      git config --global user.email "${useremail}"
      ;;
    02) # Install Git SSH Keys only if file encrypted-ssh-keys.tar.gz is present in this directory.
      # It is created using the command below - https://www.tecmint.com/encrypt-decrypt-files-tar-openssl-linux/
      # tar --exclude='.ssh/environment' --exclude='.ssh/known_hosts' -czvf - .ssh | openssl enc -e -aes256 -out encrypted-ssh-keys.tar.gz
      echo ""
      echo ">>> Installing Git SSH only if encrypted ssh key file is present ...."
      if [ -f "encrypted-ssh-keys.tar.gz" ]; then
        openssl enc -d -aes256 -in encrypted-ssh-keys.tar.gz | tar zxv
        echo ">>> Git keys extraction completed."
      fi
      echo ">>> Adding keys to ssh-agent"
      find ~/.ssh -type f -name *id_rsa -exec /usr/bin/ssh-add {} \;
      ;;
    03) # Install dotdrop using snapd
      echo ""
      echo "Installing dotdrop from pypi in the normal python environment, not using virtualenv ...."
      pip3 install --user dotdrop
      echo "dotdrop Installation completed."
      echo "Please setup your dordrop repository as explained at https://github.com/deadc0de6/dotdrop/wiki/installation#setup-your-repository"
      ;;
    04) # Install Tig 
      echo ""
      echo "Installing Tig ...."
      sudo apt-get update
      sudo apt install tig
      echo "Tig Installation completed."
      echo ""
      ;;
    05) # Install Lazygit 
      echo ""
      echo "Installing Lazygit  ...."
      sudo add-apt-repository ppa:lazygit-team/release
      sudo apt-get update
      sudo apt install lazygit
      echo "Lazygit Installation completed."
      echo ""
      ;;
    06) # Install tmux 
      echo ""
      echo "Installing tmux...."
      sudo apt-get update
      sudo apt install tmux
      echo "Lazygit Installation completed."
      echo ""
      ;;
    07) # Install Miniconda latest 
      echo ""
      echo "Installing Miniconda3 latest...."
      wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -q --show-progress
      chmod u+x Miniconda3-latest-Linux-x86_64.sh
      bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda
      echo 'export PATH="$HOME/miniconda/bin:$PATH"' >> ~/.bashrc
      echo '$PATH updated in .bashrc. Remember to source it . ~/.bashrc'
      echo "Miniconda Installation completed."
      echo ""
      ;;
    08) # Installing Visual Studio CodeP
      echo ""
      echo "Installing Visual Studio Code ...."
      mkdir -p /tmp/vscode
      pushd /tmp/vscode
      curl -L https://vscode-update.azurewebsites.net/latest/linux-deb-x64/stable --output vscode.deb
      sudo dpkg -i vscode.deb
      popd
      rm -rf /tmp/vscode
      echo "Visual Studio Code installation completed."
      echo "Install Settings Sync extenstion and setup the same."
      echo ""
      ;;
    09) # Installing vim
      echo ""
      echo "Installing vim...."
      sudo apt install -y vim
      echo "Vim installed. Make sure to alias vi to vim"
      echo ""
      ;;
    10) # Installing Virtual Box and Vagrant 
      echo ""
      echo "Installing VirtualBox...."
      wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
      wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
      sudo add-apt-repository "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib"
      sudo apt-get update
      sudo apt-get install -y virtualbox-6.0
      echo "VirtualBox installation completed."
      echo ""
      echo "Installing Vagrant ...."
      sudo add-apt-repository ppa:tiagohillebrandt/vagrant
      sudo apt-get update
      sudo apt-get install -y vagrant
      echo "Vagrant installation completed."
      ;;
    11) # Installing Docker Community Edition 
      echo ""
      echo "Installing Docker CE...."
      sudo apt-get remove docker docker-engine docker.io containerd runc
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
      sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
      sudo apt-get update
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io
      echo "Docker installation completed."
      ;;
    12) # Installing NodeJS LTS using n 
      echo ""
      echo "Installing n...."
      curl -L https://git.io/n-install | bash
      n lts
      echo "NodeJS installation completed."
      ;;
    13) # Installing Ubuntu extras 
      echo ""
      echo "Installing ubuntu extras...."
      sudo apt install -y ubuntu-restricted-extras
      echo "Ubuntu extras installation completed."
      ;;
    14) # Installing Jetbrains Toolbox
      echo ""
      echo "Installing Jetbrains Toolbox ...."
      mkdir -p /tmp/jetbrains
      pushd /tmp/jetbrains
      wget https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.15.5796.tar.gz
      tar -zxvf jetbrains*.tar.gz
      ./jetbrains*/jetbrains-toolbox
      popd
      rm -rf /tmp/jetbrains
      echo "Jetbrains installation completed."
      echo ""
      ;;
    15) # Installing Slack
      echo ""
      echo "Installing Slack...."
      mkdir -p /tmp/slack
      pushd /tmp/slack
      wget https://downloads.slack-edge.com/linux_releases/slack-desktop-4.0.2-amd64.deb
      sudo dpkg -i slack*.deb
      popd
      rm -rf /tmp/slack
      echo "Slack installation completed."
      echo ""
      ;;
    16) # Installing Mailspring 
      echo ""
      echo "Installing Mailspring...."
      mkdir -p /tmp/mailspring
      pushd /tmp/mailspring
      curl -L https://updates.getmailspring.com/download?platform=linuxDeb --output mailspring.deb
      sudo dpkg -i mailspring.deb
      popd
      rm -rf /tmp/mailspring
      echo "Mailspring installation completed."
      echo ""
      ;;
    17) # Installing MineTime 
      echo ""
      echo "Installing MineTime...."
      mkdir -p /tmp/minetime
      pushd /tmp/minetime
      curl -L https://minetime-deploy.herokuapp.com/download/linux_deb_64 --output minetime.deb
      sudo dpkg -i minetime.deb
      popd
      rm -rf /tmp/minetime
      echo "Minetime installation completed."
      echo ""
      ;;
    *)
      # Default Option
      echo "Hmm ... nothing to do here"
      ;;
  esac
done

# Check if autoremove is needed
dialog --title "Auto Remove? " \
  --yesno "Do you want to run apt auto-remove ?" 8 45
if [[ "$?" -eq 0 ]]; then
  echo ">>> Removing unwanted applications ...."
  sudo apt auto-remove -y
fi
clear
