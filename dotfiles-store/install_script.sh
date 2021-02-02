#!/bin/bash

# Check sudo.
# If credentials not already cached, ask for password and cache credentials.
# If already cached, increase sudo timeout by 5 min
sudo -v && exit 1 'Sudo access needed to execute this script'

# Check if dialog is installed. If not, install it.
dialog -v || sudo apt install -y dialog

# First ask to update all keys from ubuntu keyserver
dialog --title "Update Keys" \
  --yesno "Do you want to update apt keys ?" 8 45
if [[ "$?" -eq 0 ]]; then
  echo " >>> Updating apt keys ...."
  sudo apt-key adv --refresh-keys --keyserver keyserver.ubuntu.com
fi
clear

# Check if update is needed
dialog --title "Update" \
  --yesno "Do you want to run apt-get update ?" 8 45
if [[ "$?" -eq 0 ]]; then
  echo " >>> Updating apt list ...."
  sudo apt-get update
fi
clear

# Install Base dependencies. These should be absolute base, console only dependencies.
dialog --title "Install Base dependencies" \
  --yesno "Do you want to install base dependencies (recommended) ?" 8 55
if [[ "$?" -eq 0 ]]; then
  # Install base dependencies
  echo ">>> Installing base dependencies ...."
  sudo apt install -y tree wget curl htop unzip net-tools icdiff vim\
                      openssl gnupg-agent apt-transport-https ca-certificates \
                      python3 python3-dev python3-virtualenv python3-venv python3-pip \
                      software-properties-common build-essential lsb-release 
fi
clear

# Install Extended dependencies
dialog --title "Install Extended dependencies" \
  --yesno "Do you want to install extended dependencies (recommended) ?" 8 55
if [[ "$?" -eq 0 ]]; then
  # Install extended dependencies
  echo ">>> Installing extended dependencies ...."
  sudo apt install -y xdotool libcanberra-gtk0 libcanberra-gtk-module \
                      unixodbc unixodbc-dev libmagic-dev \
                      shellcheck snapd wmctrl
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
  "------"  "------------------------------" off
  "------"  "-----  System Utilities  -----" off
  "------"  "------------------------------" off
  "sys000"  "hid_apple patch for magic keyboard" off
  "sys005"  "Touchpad Indicator" off
  "sys010"  "Canon MX 490 Printer Drivers" off
  "sys011"  "Canon MX 490 Scanner Drivers" off
  "sys012"  "Xsane Scanning ssoftware" off
  "sys015"  "VPN and Gnome Network Manager" off
  "------"  "------------------------------" off
  "------"  "-----   Base Utilities   -----" off
  "------"  "------------------------------" off
  "bas000"  "Ubuntu Restricted Extras" off
  "bas010"  "Adapta theme" off
  "bas011"  "Icon themes" off
  "bas012"  "Ubuntu Wallpapers and Source Code fonts" off
  "bas028"  "Google Chrome" off
  "bas029"  "Gnome Tweaks, Shell Extensions" off
  "bas030"  "Gnome Clocks" off
  "bas031"  "Gnome Calendar" off
  "bas032"  "Gnome Screenshot" off
  "bas033"  "Flameshot Screenshot" off
  "bas100"  "Git" off
  "bas101"  "Gitbatch" off
  "bas102"  "Tig" off
  "bas103"  "Lazygit" off
  "bas105"  "Git SSH keys" off
  "bas110"  "dotdrop" off
  "bas115"  "Tmux, powerline" off
  "bas120"  "VirtualBox and Vagrant" off
  "bas130"  "Docker CE" off
  "bas131"  "Docker Compose" off
  "bas132"  "Lazydocker" off
  "bas133"  "Dive - docker image analyser" off
  "bas134"  "Ansible" off
  "bas135"  "Google Cloud SDK" off
  "bas136"  "AWS CLI SDK" off
  "bas137"  "Azure CLI SDK" off
  "bas138"  "Terraform" off
  "bas139"  "Packer" off
  "bas140"  "s3cmd" off
  "bas150"  "Kubernetes Tools" off
  "------"  "------------------------------" off
  "------"  "-----         IDE        -----" off
  "------"  "------------------------------" off
  "ide000"  "vim" off
  "ide005"  "Visual Studio Code" off
  "ide010"  "Jetbrains Toolbox" off
  "------"  "------------------------------" off
  "------"  "----- Development Stuff  -----" off
  "------"  "------------------------------" off
  "dev000"  "Miniconda" off
  "dev030"  "NodeJS LTS using n-install" off
  "dev031"  "YARN" off
  "dev040"  "Pipenv and Pipes" off
  "dev050"  "OpenJDK 8" off
  "dev051"  "OpenJDK 11" off
  "dev060"  "Go language" off
  "dev080"  "Rust+Cargo" off
  "dev100"  "dbeaver Community - Databse Tool" off
  "dev110"  "SQLLite DB Browser" off
  "dev120"  "Clickhouse" off
  "dev130"  "Apache Directory Studio" off
  "------"  "------------------------------" off
  "------"  "----- Productivity Stuff -----" off
  "------"  "------------------------------" off
  "prd000"  "mdbook" off
  "prd001"  "Joplin - Notes taking application" off
  "prd050"  "Mailspring" off
  "prd051"  "Minetime" off
  "prd052"  "Slack" off
  "prd060"  "Zoom Meetings App" off
  "prd070"  "Libreoffice" off
  "prd080"  "PDFsam basic" off
  "------"  "------------------------------" off
  "------"  "----- Audio Video Stuff  -----" off
  "------"  "------------------------------" off
  "med000"  "Spotify Client" off
  "med010"  "VLC Media Player" off
  "med020"  "Simple Screen Recorder" off
  "med030"  "Open Boradcast Studio" off
  "med040"  "Lightworks Video Studio" off
  "med050"  "Shotcut Video Editor" off
)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear

for choice in $choices; do
  case $choice in
    sys000) # Installing Apple Magic Keyboard config kernel module
      echo ""
      echo "Installing dkms..."
      sudo apt install -y dkms
      echo "Installing hid_apple patched...."
      mkdir -p /tmp/magickb
      pushd /tmp/magickb
      git clone https://github.com/free5lot/hid-apple-patched
      pushd hid-apple-patched
      sudo dkms add .
      sudo dkms build hid-apple/1.0
      sudo dkms install hid-apple/1.0
      echo "Creating /etc/modprobe.d/hid_apple.conf file...."
      echo "options hid_apple fnmode=2" | sudo tee /etc/modprobe.d/hid_apple.conf
      echo "options hid_apple swap_fn_leftctrl=1" | sudo tee -a /etc/modprobe.d/hid_apple.conf
      echo "options hid_apple swap_opt_cmd=1" | sudo tee -a /etc/modprobe.d/hid_apple.conf
      echo "options hid_apple rightalt_as_rightctrl=1" | sudo tee -a /etc/modprobe.d/hid_apple.conf
      echo "options hid_apple ejectcd_as_delete=1" | sudo tee -a /etc/modprobe.d/hid_apple.conf
      sudo update-initramfs -u
      popd
      popd
      rm -rf /tmp/magickb
      echo "Installallation of hid_apple patched completed...."
      echo "Please reboot your machine."
      echo ""
      ;;
    sys005) # Installing Touchpad Indicator
      echo ""
      echo "Installing Touchpad Indicator...."
      sudo add-apt-repository ppa:atareao/atareao -y
      sudo apt-get update
      sudo apt install -y touchpad-indicator
      echo "Touchpad indicator installation completed."
      echo ""
      ;;
    sys010) # Installing Cannon MX490 Printer Drivers
      echo ""
      echo "Installing Canon MX490 Printer Drivers...."
      mkdir -p /tmp/cnondriv
      pushd /tmp/cnondrv
      curl -L http://gdlp01.c-wss.com/gds/9/0100006669/01/cnijfilter2-5.10-1-deb.tar.gz --output driver.tar.gz
      tar -zxvf driver.tar.gz
      pushd cnijfilter2-5.10-1-deb
      sudo ./install.sh
      popd
      popd
      rm -rf /tmp/cnondrv
      echo "Canon MX490 Printer driver installation completed. "
      echo ""
      ;;
    sys011) # Installing Canon MX490 Scanner Drivers
      echo ""
      echo "Installing Canon MX490 Scanner Drivers...."
      mkdir -p /tmp/cnonscan
      pushd /tmp/cnonscan
      curl -L http://gdlp01.c-wss.com/gds/2/0100006672/01/scangearmp2-3.10-1-deb.tar.gz --output driver.tar.gz
      tar -zxvf driver.tar.gz
      pushd scangearmp2-3.10-1-deb
      sudo ./install.sh
      popd
      popd
      rm -rf /tmp/cnonscan
      echo "Canon MX490 Scanner driver installation completed. "
      echo ""
      ;;
    sys012) # Install SANE scanning software
      echo ""
      echo "Installing xsane scanning software...."
      sudo apt-get update
      sudo apt install -y sane sane-utils libsane-extras xsane
      echo "Xsane Installation completed."
      echo ""
      ;;
    sys015) # Installing VPN and Gnome Network Manager
      echo ""
      echo "Installing VPN...."
      sudo apt install -y vpnc network-manager-vpnc-gnome
      echo "VPN installation completed. You will need to configure VPN connection yourself."
      echo ""
      ;;
    bas000) # Installing Ubuntu extras
      echo ""
      echo "Installing ubuntu extras...."
      sudo apt install -y ubuntu-restricted-extras
      echo "Ubuntu extras installation completed."
      ;;
    bas010) # Installing Adapta Theme
      echo ""
      echo "Installing Adapta Theme...."
      sudo apt-add-repository ppa:tista/adapta -y
      sudo apt-get update
      sudo apt install -y adapta-gtk-theme
      echo "Adapta theme installation completed."
      echo ""
      ;;
    bas011) # Ubuntu icon themes
      echo ""
      echo "Installing papirus icons theme...."
      sudo add-apt-repository ppa:papirus/papirus -y
      sudo apt-get update
      sudo apt-get install -y papirus-icon-theme
      echo "papirus icon theme installation completed."
      echo ""
      echo ""
      echo "Installing moka icons theme...."
      sudo add-apt-repository ppa:snwh/ppa -y
      sudo apt-get update
      sudo apt-get install -y moka-icon-theme faba-icon-theme faba-mono-icons 
      echo "moka icon theme installation completed."
      echo ""
      ;;
    bas012) # Install wallpapers and source code fonts
      # https://help.gnome.org/admin/system-admin-guide/stable/fonts-user.html.en
      echo ""
      echo "Installing Wallpapers and Fonts ...."
      if [ -f "privatestuff-master.zip" ]; then
        mv privatestuff-master.zip /tmp
        pushd /tmp
        unzip privatestuff-master.zip
        mv privatestuff-master/wallpapers $HOME/Pictures
        echo "Wallpaer installation completed."
        mkdir -p $HOME/.local/share/fonts
        mv privatestuff-master/fonts/*.{ttf,otf} $HOME/.local/share/fonts
        fc-cache $HOME/.local/share/fonts
        echo "Fonts installation completed."
        rm -rf /tmp/privatestuff-master.zip && rm -rf privatestuff-master
        popd
      else
        echo "Could not locate privatestuff-master.zip."
        echo "Download the zip from https://github.com/hemenkapadia/privatestuff in your broser and put in the same dir as this file."
      fi
      ;;
    bas028) # Installing Google Chrome 
      echo ""
      echo "Installing Google Chrome browser...."
      mkdir -p /tmp/chrome
      pushd /tmp/chrome
      curl -L https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb --output chrome.deb
      sudo apt install ./chrome.deb
      popd
      rm -rf /tmp/chrome
      echo "Google Chrome installation completed. "
      echo ""
      ;;
    bas029) # Installing Gnome Shell Extensions 
      echo ""
      echo "Installing Gnome Tweaks and Shell Extensions...."
      sudo apt install -y gnome-tweaks gnome-shell-extensions 
      echo "Installing native connectory to manage Gnome Extensions using Chrome...."
      sudo apt install -y chrome-gnome-shell 
      echo "Installing extensions for dock and multi-monitor support...."
      sudo apt install -y gnome-shell-extension-dashtodock \
                          gnome-shell-extension-multi-monitors
      echo "Gnome Clocks installation completed."
      echo ""
      ;;
    bas030) # Installing Gnome Clocks
      echo ""
      echo "Installing Gnome Clocks...."
      sudo apt install -y gnome-clocks
      echo "Gnome Clocks installation completed."
      echo ""
      ;;
    bas031) # Installing Gnome Calendar
      echo ""
      echo "Installing Gnome Calendar...."
      sudo apt install -y gnome-calendar
      echo "Gnome Calendar installation completed."
      echo ""
      ;;
    bas032) # Installing Gnome Screenshot 
      echo ""
      echo "Installing Gnome Screenshot...."
      sudo apt install -y gnome-screenshot 
      echo "Gnome screenshot installed."
      echo ""
      ;;
    bas033) # Installing Flameshot 
      echo ""
      echo "Installing Flameshot...."
      sudo apt install -y flameshot 
      echo "Flameshot installed"
      echo ""
      ;;
    bas100) # Install Git
      echo ""
      echo ">>> Installing Git ...."
      sudo add-apt-repository ppa:git-core/ppa -y
      sudo apt-get update
      sudo apt install -y git
      echo ">>> Git Installation completed."
      echo ">>> Configuring Git user.name and user.email...."
      read -p "Enter Git configuration user.name: " username
      read -p "Enter Git configuration user.email: " useremail
      git config --global user.name "${username}"
      git config --global user.email "${useremail}"
      ;;
    bas101) # Installing Gitbatch
      echo ""
      echo "Installing gitbatch...."
      mkdir -p /tmp/gitbatch
      pushd /tmp/gitbatch
      curl -OL https://github.com/isacikgoz/gitbatch/releases/download/v0.5.0/gitbatch_0.5.0_linux_amd64.tar.gz
      tar xzf gitbatch_0.5.0_linux_amd64.tar.gz
      sudo mv gitbatch /usr/local/bin
      popd
      rm -rf /tmp/gitbatch
      echo "Gitbatch installation completed."
      echo ""
      ;;
    bas102) # Install Tig
      echo ""
      echo "Installing Tig ...."
      sudo apt-get update
      sudo apt install -y tig
      echo "Tig Installation completed."
      echo ""
      ;;
    bas103) # Install Lazygit
      echo ""
      echo "Installing Lazygit  ...."
      sudo add-apt-repository ppa:lazygit-team/release -y
      sudo apt-get update
      sudo apt install -y lazygit
      echo "Lazygit Installation completed."
      echo ""
      ;;
    bas105) # Install Git SSH Keys only if file encrypted-ssh-keys.tar.gz is present in this directory.
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
    bas110) # Install dotdrop
      echo ""
      echo "Installing dotdrop from pypi for the system, not using virtualenv ...."
      sudo python3 -m pip install --system dotdrop
      echo "dotdrop Installation completed."
      echo "Please setup your dordrop repository as explained at https://github.com/deadc0de6/dotdrop/wiki/installation#setup-your-repository"
      ;;
    bas115) # Installing Tmux and Powerline
      echo ""
      echo "Installing Tmux and Powerline...."
      sudo apt install -y tmux fonts-powerline powerline python3-powerline
      git clone https://github.com/adidenko/powerline ~/.config/powerline
      echo "Configuring Powerline for vim...."
      echo "set laststatus=2" >> ~/.vimrc
      echo -e "python3 from powerline.vim import setup as powerline_setup" >> ~/.vimrc
      echo -e "python3 powerline_setup()\npython3 del powerline_setup" >> ~/.vimrc
      echo "Configuring Powerline for terminal...."
      echo ". /usr/share/powerline/bindings/bash/powerline.sh" >> ~/.bashrc
      echo "Tmux and Powerline installation completed."
      echo ""
      ;;
    bas120) # Installing Virtual Box and Vagrant
      echo ""
      echo "Installing VirtualBox...."
      wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
      wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
      sudo add-apt-repository "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" -y
      sudo apt-get update
      sudo apt-get install -y virtualbox-6.0
      echo "VirtualBox installation completed."
      echo ""
      echo "Installing Vagrant ...."
      sudo add-apt-repository ppa:tiagohillebrandt/vagrant -y
      sudo apt-get update
      sudo apt-get install -y vagrant
      echo "Vagrant installation completed."
      ;;
    bas130) # Installing Docker Community Edition
      echo ""
      echo "Installing Docker CE...."
      sudo apt-get remove docker docker-engine docker.io containerd runc
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
      sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" -y
      sudo apt-get update
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io
      sudo usermod -a -G docker $USER
      echo "Docker installation completed."
      ;;
    bas131) # Install docker compose
      echo ""
      # Get latest github release tag or version but printing the redirection url for the latest relese
      version=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/docker/compose/releases/latest | rev | cut -d '/' -f 1 | rev)
      version="1.27.4"  # hardcoading as 1.28.0 was giving python library error
      echo "Installing Docker Compose...."
      sudo curl -L "https://github.com/docker/compose/releases/download/${version}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
      sudo chmod +x /usr/local/bin/docker-compose
      unset version
      echo ""
      ;;
    bas132) # Installing Lazydocker
      echo ""
      echo "Installing Lazydocker ...."
      curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
      echo "Lazydocker installation completed."
      echo ""
      ;;
    bas133) # Installing Dive - docker image analyser 
      echo ""
      echo "Installing Dive - docker image analyser...."
      # Get latest github release tag or version but printing the redirection url for the latest relese
      version=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/wagoodman/dive/releases/latest | rev | cut -d '/' -f 1 | rev)
      mkdir -p /tmp/dive
      pushd /tmp/dive
      curl -L "https://github.com/wagoodman/dive/releases/download/${version}/dive_${version:1}_linux_amd64.deb" --output dive.deb
      sudo apt install ./dive.deb
      unset version
      popd
      rm -rf /tmp/dive
      echo "Dive installation completed. "
      echo ""
      ;;
    bas134) # Installing Ansible 
      echo ""
      echo "Installing Ansible...."
      sudo apt-add-repository --yes --update ppa:ansible/ansible
      sudo apt-get update
      sudo apt-get install -y ansible python-argcomplete
      sudo activate-global-python-argcomplete 
      echo "Ansible installation completed."
      echo ""
      ;;
    bas135) # Installing Google Cloud SDK 
      echo ""
      echo "Installing Google Cloud SDK...."
      echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
      curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
      sudo apt-get update && sudo apt-get install -y google-cloud-sdk
      echo "Google Cloud SDK installation completed."
      echo ""
      ;;
    bas136) # Installing AWS CLI 
      echo ""
      echo "Installing AWS CLI...."
      mkdir -p /tmp/awscli
      pushd /tmp/awscli
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
      unzip awscliv2.zip
      sudo ./aws/install
      popd
      rm -rf /tmp/awscli
      echo "AWS CLI installation completed."
      echo ""
      ;;
    bas137) # Installing Azure CLI 
      echo ""
      echo "Installing Azure CLI...."
      curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null 
      AZ_REPO=$(lsb_release -cs)
      echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
      sudo apt-get update && sudo apt-get install -y azure-cli 
      echo "Azure CLI installation completed."
      echo ""
      ;;
    bas138) # Installing Terraform 
      echo ""
      echo "Installing Terraform...."
      mkdir -p /tmp/terraform
      pushd /tmp/terraform
      # Commenting download of latest version as there were some errors experienced. Will use 0.13.6 version for now
      # wget $(curl --silent  https://www.terraform.io/downloads.html | grep '_linux_amd64.zip' | cut -d '"' -f 2) -O terraform.zip
      wget  https://releases.hashicorp.com/terraform/0.13.6/terraform_0.13.6_linux_amd64.zip -O terraform.zip
      unzip terraform.zip
      mv terraform $HOME/.local/bin
      echo "Terraform installation completed."
      echo ""
      ;;
    bas139) # Installing Packer
      echo ""
      echo "Installing Packer...."
      mkdir -p /tmp/packer
      pushd /tmp/packer
      wget https://releases.hashicorp.com/packer/1.6.6/packer_1.6.6_linux_amd64.zip -O packer.zip
      unzip packer.zip
      mv packer $HOME/.local/bin
      echo "Packer installation completed."
      echo ""
      ;;
    bas140) # Install s3cmd
      echo ""
      echo "Installing s3cmd from pypi systemwide ...."
      sudo python3 -m pip install --system s3cmd
      echo "s3cmd Installation completed."
      ;;
    bas150) # Installing Kubernetes Tools
      echo ""
      echo "Installing kubectl...."
      kubectl_version=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
      wget "https://storage.googleapis.com/kubernetes-release/release/${kubectl_version}/bin/linux/amd64/kubectl" -O "${HOME}/.local/bin/kubectl"
      chmod u+x "${HOME}/.local/bin/kubectl"
      echo "kubectl installation completed."
      echo ""
      echo "Installing k3d...."
      # Get latest github release tag or version but printing the redirection url for the latest relese
      version=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/rancher/k3d/releases/latest | rev | cut -d '/' -f 1 | rev)
      wget "https://github.com/rancher/k3d/releases/download/${version}/k3d-linux-amd64" -O "${HOME}/.local/bin/k3d"
      unset version
      chmod u+x "${HOME}/.local/bin/k3d"
      echo "k3d installation completed."
      echo ""
      echo "Installing kind...."
      version=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/kubernetes-sigs/kind/releases/latest | rev | cut -d '/' -f 1 | rev)
      wget "https://github.com/kubernetes-sigs/kind/releases/download/${version}/kind-linux-amd64" -O "${HOME}/.local/bin/kind"
      unset version
      chmod u+x "${HOME}/.local/bin/kind"
      echo "kind installation completed."
      echo ""
      echo "Installing kubectx and kubens...."
      version=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/ahmetb/kubectx/releases/latest | rev | cut -d '/' -f 1 | rev)
      wget "https://github.com/ahmetb/kubectx/releases/download/${version}/kubectx_${version}_linux_x86_64.tar.gz" -O "${HOME}/.local/bin/kubectx"
      wget "https://github.com/ahmetb/kubectx/releases/download/${version}/kubens_${version}_linux_x86_64.tar.gz" -O "${HOME}/.local/bin/kubens"
      unset version
      chmod u+x "${HOME}/.local/bin/kubectx"
      chmod u+x "${HOME}/.local/bin/kubens"
      echo "kubectx and kubens installation completed."
      echo ""
      echo "Installing kubebox...."
      version=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/astefanutti/kubebox/releases/latest | rev | cut -d '/' -f 1 | rev)
      wget "https://github.com/astefanutti/kubebox/releases/download/v0.9.0/kubebox-linux" -O "${HOME}/.local/bin/kubebox"
      unset version
      chmod u+x "${HOME}/.local/bin/kubebox"
      echo "kubebox installation completed."
      echo ""
      echo "Installing helm...."
      mkdir -p /tmp/helm
      pushd /tmp/helm
      version=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/helm/helm/releases/latest | rev | cut -d '/' -f 1 | rev)
      wget "https://get.helm.sh/helm-v3.5.1-linux-amd64.tar.gz" -O helm.tar.gz
      unset version
      tar -zxvf helm.tar.gz
      mv linux-amd64/helm "${HOME}/.local/bin"
      echo "kubebox installation completed."
      echo ""
      ;;
    ide000) # Installing vim
      echo ""
      echo "Installing vim...."
      sudo apt install -y vim
      echo "Vim installed. Make sure to alias vi to vim"
      echo ""
      ;;
    ide005) # Installing Visual Studio CodeP
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
    ide010) # Installing Jetbrains Toolbox
      echo ""
      echo "Installing Jetbrains Toolbox ...."
      mkdir -p /tmp/jetbrains
      pushd /tmp/jetbrains
      wget https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.19.7784.tar.gz
      tar -zxvf jetbrains*.tar.gz
      ./jetbrains*/jetbrains-toolbox
      popd
      rm -rf /tmp/jetbrains
      echo "Jetbrains installation completed."
      echo ""
      ;;
    dev000) # Install Miniconda latest
      echo ""
      echo "Installing Miniconda3 latest...."
      wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -q --show-progress
      chmod u+x Miniconda3-latest-Linux-x86_64.sh
      bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda3
      echo 'export PATH="$HOME/miniconda3/bin:$PATH"' >> ~/.bash_envvars
      echo '$PATH updated in .bash_envvars. Remember to source it . ~/.bash_envvars'
      "${HOME}"/miniconda3/bin/conda init bash
      rm ~/Miniconda3-latest-Linux-x86_64.sh
      echo "Miniconda Installation completed."
      echo ""
      ;;
    dev030) # Installing NodeJS LTS using n
      echo ""
      echo "Installing n...."
      curl -L https://git.io/n-install | bash
      n lts
      echo "NodeJS installation completed."
      ;;
    dev031) # Installing YARN
      echo ""
      echo "Installing YARN...."
      curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
      echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
      sudo apt update && sudo apt install yarn
      echo "YARN installation completed. "
      echo ""
      ;;
    dev040) # Install pipenv
      echo ""
      echo "Installing pipenv and pipes from pypi for user onlu...."
      python3 -m pip install --user pipenv
      python3 -m pip install --user pipenv-pipes
      echo "Pipenv and Pipes Installation completed."
      ;;
    dev050) # Installing OpenJDK 8
      echo ""
      echo "Installing OpenJDK 8...."
      sudo apt install -y openjdk-8-jdk
      echo "OpenJDK 8 installation completed."
      echo ""
      ;;
    dev051) # Installing OpenJDK 11
      echo ""
      echo "Installing OpenJDK 11...."
      sudo apt install -y openjdk-11-jdk
      echo "OpenJDK 11 installation completed."
      echo ""
      ;;
    dev060) # Installing Go language
      echo ""
      echo "Installing Go language...."
      mkdir -p /tmp/golang
      pushd /tmp/golang
      curl -L https://dl.google.com/go/go1.15.7.linux-amd64.tar.gz --output go.tar.gz
      sudo tar zxvf go.tar.gz && sudo mv go /usr/local
      echo 'export PATH="/usr/local/go/bin:$PATH"' >> "${HOME}"/.bash_envvars
      popd
      rm -rf /tmp/golang
      echo "Go language installation completed. "
      echo ""
      ;;
    dev080) # Install Rust + Cargo
      echo ""
      echo "Installing Rust and Cargo...."
      sudo mkdir -p /opt/cargo /opt/rustup
      sudo chown hemen:hemen /opt/cargo
      sudo chown hemen:hemen /opt/rustup
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | RUSTUP_HOME=/opt/rustup CARGO_HOME=/opt/cargo sh
      echo "Rust and Cargo install completed."
      echo 'Update $PATH to inclue /opt/cargo/bin and /opt/rustup/bin.'
      echo ""
      ;;
    dev100) # Installing DBeaver
      echo ""
      echo "Installing dbeaver...."
      mkdir -p /tmp/dbeaver
      pushd /tmp/dbeaver
      curl -L https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb --output dbeaver.deb
      sudo dpkg -i dbeaver.deb
      popd
      rm -rf /tmp/dbeaver
      echo "DBeaver installation completed."
      echo ""
      ;;
    dev110) # Installing SQL Lite DB Browser 
      echo ""
      echo "Installing SQL Lite DB Browser...."
      sudo apt update && sudo apt install sqlitebrowser 
      echo "YARN installation completed. "
      echo ""
      ;;
    dev120) # Clickhouse installation 
      echo ""
      echo "Installing clickhouse...."
      echo "deb http://repo.yandex.ru/clickhouse/deb/stable/ main/" | sudo tee -a /etc/apt/sources.list.d/clickhouse.list
      sudo apt-key adv --keyserver keyserver.ubuntu.com --recv E0C56BD4
      sudo apt-get update
      sudo apt-get install -y clickhouse-server clickhouse-client 
      echo "Clickhouse installation completed."
      echo ""
      ;;
    dev130) # Installing Apache Directory Studio
      echo ""
      echo "Installing Apache Directory Studio...."
      mkdir -p /tmp/ads
      pushd /tmp/ads
      curl -L http://mirrors.ocf.berkeley.edu/apache/directory/studio/2.0.0.v20180908-M14/ApacheDirectoryStudio-2.0.0.v20180908-M14-linux.gtk.x86_64.tar.gz --output ads.tar.gz
      sudo tar zxvf ads.tar.gz && sudo mv ApacheDirectoryStudio /opt
      ln -s /opt/ApacheDirectoryStudio/ApacheDirectoryStudio "${HOME}"/bin/ldapbrowser
      popd
      rm -rf /tmp/ads
      echo "Apache Directory Studio installation completed. "
      echo ""
      ;;
    prd000) # Install mdbook
      echo ""
      echo "Installing mdbook...."
      cargo install mdbook
      cargo install mdbook-toc
      echo "mdbook Installation completed."
      echo ""
      ;;
    prd001) # Installing Joplin 
      echo ""
      echo "Installing Joplin - Notes taking application...."
      wget -O - https://raw.githubusercontent.com/laurent22/joplin/master/Joplin_install_and_update.sh | bash      
      echo "Joplin installation completed. "
      echo ""
      ;;
    prd050) # Installing Mailspring
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
    prd051) # Installing Minetime
      echo ""
      echo "Installing Minetime...."
      mkdir -p /tmp/minetime
      pushd /tmp/minetime
      curl -L https://europe-west1-minetime-backend.cloudfunctions.net/download/linux-deb --output minetime.deb
      sudo dpkg -i minetime.deb
      popd
      rm -rf /tmp/minetime
      echo "Minetime installation completed."
      echo ""
      ;;
    prd052) # Installing Slack
      echo ""
      echo "Installing Slack...."
      mkdir -p /tmp/slack
      pushd /tmp/slack
      wget https://downloads.slack-edge.com/linux_releases/slack-desktop-4.12.2-amd64.deb
      sudo dpkg -i slack*.deb
      popd
      rm -rf /tmp/slack
      echo "Slack installation completed."
      echo ""
      ;;
    prd060) # Installing Zoom Meeting
      echo ""
      echo "Installing zoom meeting app...."
      mkdir -p /tmp/zoom
      pushd /tmp/zoom
      curl -L https://zoom.us/client/latest/zoom_amd64.deb --output zoom.deb
      sudo apt install ./zoom.deb
      popd
      rm -rf /tmp/zoom
      echo "Zoom installation completed."
      echo ""
      ;;
    prd070) # Installing Libreoffice
      echo ""
      echo "Installing Libreoffice...."
      sudo apt install -y libreoffice
      echo "Libreoffice installation completed."
      echo ""
      ;;
    prd080) # Installing PDFsam baisc
      echo ""
      echo "Installing PDFsam basic...."
      mkdir -p /tmp/pdfsamb
      pushd /tmp/pdfsamb
      curl -L  https://github.com/torakiki/pdfsam/releases/download/v4.2.1/pdfsam_4.2.1-1_amd64.deb --output pdfsam.deb
      sudo dpkg -i pdfsam.deb
      popd
      rm -rf /tmp/pdfsamb
      echo "PDFsam installation completed. "
      echo ""
      ;;
    med000) # Installing Spotify Client
      echo ""
      echo "Installing Spotify Client...."
      curl -sS https://download.spotify.com/debian/pubkey.gpg | sudo apt-key add -
      echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
      sudo apt-get update && sudo apt install -y spotify-client
      echo "Spotify Client installation completed."
      echo ""
      ;;
    med010) # Install VLC
      echo ""
      echo "Installing VLC ...."
      sudo apt-get update
      sudo apt install -y vlc
      echo "VLC Installation completed."
      echo ""
      ;;
    med020) # Install Simple Screen Recorded
      echo ""
      echo "Installing Simple Screen Recorder ...."
      sudo apt-get update
      sudo apt install -y simplescreenrecorder
      echo "SimpleScreenRecorder Installation completed."
      echo ""
      ;;
    med030) # Installing Open Broadcast Studio 
      echo ""
      echo "Installing Open Broadcast Studio...."
      sudo add-apt-repository ppa:obsproject/obs-studio 
      sudo apt update
      sudo apt install -y ffmpeg obs-studio
      echo "Open Broadcast Studio installation completed. "
      echo ""
      ;;
    med040) # Installing lightworks 
      echo ""
      echo "Installing lightworks...."
      mkdir -p /tmp/lw
      pushd /tmp/lw
      curl -L https://cdn.lwks.com/releases/lightworks-2020.1-r122068-amd64.deb --output lw.deb
      sudo apt install ./lw.deb
      sudo apt install mediainfo-gui
      popd
      rm -rf /tmp/lw
      echo "Lightworks installation completed. "
      echo ""
      ;;
    med050) # Installing Shotcut vidoe editor 
      echo ""
      echo "Installing Shotcut Video Editor...."
      mkdir -p /tmp/shotcut
      pushd /tmp/shotcut
      curl -L https://github.com/mltframework/shotcut/releases/download/v20.07.11/shotcut-linux-x86_64-200711.txz --output shotcut.txz 
      tar -xf shotcut.txz && sudo mv Shotcut /opt
      sed -i '/^Exec.*/d' /opt/Shotcut/Shotcut.desktop
      echo 'Exec=/opt/Shotcut/Shotcut.app/shotcut "%F"' >> /opt/Shotcut/Shotcut.desktop
      ln -s /opt/Shotcut/Shotcut.desktop "${HOME}"/.local/share/applications
      popd
      rm -rf /tmp/shotcut
      echo "Shotcut completed. "
      echo ""
      ;;
    *)
      # Default Option
      ;;
  esac
done

# Run fixbroken install?
dialog --title "Fix Broken? " \
  --yesno "Do you want to run apt --fix-broken install ?" 8 45
if [[ "$?" -eq 0 ]]; then
  echo ">>> Fixing broken install applications ...."
  sudo apt --fix-broken -y install
fi

# Check if autoremove is needed
dialog --title "Auto Remove? " \
  --yesno "Do you want to run apt auto-remove ?" 8 45
if [[ "$?" -eq 0 ]]; then
  echo ">>> Removing unwanted applications ...."
  sudo apt auto-remove -y
fi


# vim: filetype=sh
