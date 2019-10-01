#!/bin/bash

# Check sudo.
# If credentials not already cached, ask for password and cache credentials.
# If already cached, increase sudo timeout by 5 min
sudo -v && exit 1 'Sudo access needed to execute this script'

# First update
echo " >>> Updating apt list ...."
sudo apt-get update

# Install base dependencies
echo ">>> Installing base dependencies ...."
sudo apt install -y dialog tree curl snapd openssl python3 python3-virtualenv python3-pip

# Check if upgrade is needed
dialog --title "Upgrade" \
  --yesno "Do you want to run apt-get upgrade ?" 6 25
if [[ "$?" -eq 0 ]]; then
  echo ">>> Upgrading system ...."
  sudo apt-get upgrade -y
else
  echo ">>> Proceeding without system upgrade ..."
fi
clear


# Offer list of applications to select for installation
cmd=(dialog --separate-output --checklist "Please Select Software you want to install:" 22 76 16)
options=(
  1  "Git" off
  2  "Git SSH keys" off
  3  "dotdrop" off
  4  "Tig" off
  5  "Lazygit" off
  6  "tmux" off
  7  "Miniconda" off
  8  "Visual Studio Code" off
)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear

for choice in $choices; do
  case $choice in
    1)
      # Install Git
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
    2)
      # Install Git SSH Keys only if file encrypted-ssh-keys.tar.gz is present in this directory.
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
    3)
      # Install dotdrop using snapd
      echo ""
      echo "Installing dotdrop from pypi in the normal python environment, not using virtualenv ...."
      pip3 install --user dotdrop
      echo "dotdrop Installation completed."
      echo "Please setup your dordrop repository as explained at https://github.com/deadc0de6/dotdrop/wiki/installation#setup-your-repository"
      ;;
    4)
      # Install Tig
      echo ""
      echo "Installing Tig ...."
      sudo apt-get update
      sudo apt install tig
      echo "Tig Installation completed."
      echo ""
      ;;
    5)
      # Install Lazygit
      echo ""
      echo "Installing Lazygit  ...."
      sudo add-apt-repository ppa:lazygit-team/release
      sudo apt-get update
      sudo apt install lazygit
      echo "Lazygit Installation completed."
      echo ""
      ;;
    6)
      # Install tmux
      echo ""
      echo "Installing tmux...."
      sudo apt-get update
      sudo apt install tmux
      echo "Lazygit Installation completed."
      echo ""
      ;;
    7)
      # Install Miniconda latest
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
    8)
      # Installing Visual Studio Code
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
    *)
      # Default Option
      echo "Hmm ... nothing to do here"
      ;;
  esac
done
