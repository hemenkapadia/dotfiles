#!/bin/bash

# Check sudo.
# If credentials not already cached, ask for password and cache credentials.
# If already cached, increase sudo timeout by 5 min
sudo -v || { echo 'Sudo access needed to execute this script'; exit 1; }

# Check if dialog is installed. If not, install it.
dialog -v || sudo apt install -y dialog

# First ask to update all keys from ubuntu keyserver
dialog --title "Update Keys" \
  --yesno "Do you want to update apt keys ?" 8 45
if [[ "$?" -eq 0 ]]; then
  clear
  echo " >>> Updating apt keys ...."
  sudo apt-key adv --refresh-keys --keyserver keyserver.ubuntu.com
  read -s -p 'Press Enter to continue ..'
fi

# Check if update is needed
dialog --title "Update" \
  --yesno "Do you want to run apt-get update ?" 8 45
if [[ "$?" -eq 0 ]]; then
  clear
  echo " >>> Updating apt list ...."
  sudo apt-get update
  read -s -p 'Press Enter to continue ..'
fi

# Install Base dependencies. These should be absolute base, console only dependencies.
dialog --title "Install Base dependencies" \
  --yesno "Do you want to install base dependencies (recommended) ?" 8 55
if [[ "$?" -eq 0 ]]; then
  # Install base dependencies
  clear
  echo ">>> Installing base dependencies ...."
  sudo apt install tree wget curl htop unzip net-tools icdiff vim jq pv \
                   openssl gnupg-agent apt-transport-https ca-certificates \
                   software-properties-common make build-essential lsb-release
  read -s -p 'Press Enter to continue ..'
fi

# Install Python 3 dependencies
dialog --title "Install Python3 dependencies" \
  --yesno "Do you want to install Python3 (recommended) ?" 8 55
if [[ "$?" -eq 0 ]]; then
  # Install Python 3 dependencies
  clear
  echo ">>> Installing Python 3 dependencies ...."
  sudo apt install python3 python3-dev
  sudo apt install python3-virtualenv python3-venv python3-pip
  # sudo -H /usr/bin/python3 -m pip install --upgrade pip
  read -s -p 'Press Enter to continue ..'
fi

# Install Extended dependencies
dialog --title "Install Extended dependencies" \
  --yesno "Do you want to install extended dependencies (recommended) ?" 8 55
if [[ "$?" -eq 0 ]]; then
  # Install extended dependencies
  clear
  echo ">>> Installing extended dependencies ...."
  sudo apt install xdotool libcanberra-gtk0 libcanberra-gtk-module \
                   unixodbc unixodbc-dev libmagic-dev \
                   shellcheck snapd wmctrl \
                   libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev llvm \
                   libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
                   python3-gpg fuse libfuse2
  read -s -p 'Press Enter to continue ..'
fi

# Check if upgrade is needed
dialog --title "Upgrade" \
  --yesno "Do you want to run apt-get upgrade ?" 8 55
if [[ "$?" -eq 0 ]]; then
  clear
  echo ">>> Upgrading system ...."
  sudo apt-get upgrade -y
  read -s -p 'Press Enter to continue ..'
fi

# Make $HOME/.local/bin directory if it does not exist
mkdir -p "${HOME}/.local/bin"

# Offer list of applications to select for installation
cmd=(dialog --separate-output --checklist "Please Select Software you want to install:" 22 76 16)
options=(
  "------"  "------------------------------" off
  "------"  "-----  System Utilities  -----" off
  "------"  "------------------------------" off
  "sys000"  "hid_apple patch for magic keyboard" off
  "sys001"  "HDD and NVMe health check tools" off
  "sys005"  "Touchpad Indicator" off
  "sys006"  "Solaar - Logitech Unifying Device Manager" off
  "sys007"  "XPPen G430S Driver" off
  "sys008"  "Xournal++ - Handwritten notes app" off
  "sys010"  "Printer Driver - Canon MX490" off
  "sys011"  "Scanner Driver - Canon MX490" off
  "sys012"  "Xsane Scanning ssoftware" off
  "sys015"  "VPN and Gnome Network Manager" off
  "sys020"  "Video4Linux Utils and GUVCViewer - Webcam Manager" off
  "------"  "------------------------------" off
  "------"  "-----   Base Utilities   -----" off
  "------"  "------------------------------" off
  "bas000"  "Ubuntu Restricted Extras" off
  "bas010"  "Adapta theme" off
  "bas011"  "Icon themes" off
  "bas012"  "Ubuntu Wallpapers and Source Code fonts" off
  "bas020"  "AppImage Launcher" off
  "bas027"  "Firefox" off
  "bas028"  "Google Chrome" off
  "bas029"  "Gnome Tweaks, Shell Extensions" off
  "bas030"  "Gnome Clocks" off
  "bas031"  "Gnome Calendar" off
  "bas100"  "Git" off
  "bas101"  ">> Gitbatch" off
  "bas102"  "Tig" off
  "bas103"  ">> Lazygit" off
  "bas105"  "Git SSH keys" off
  "bas106"  "Authy 2FA Authenticator" off
  "bas110"  ">> dotdrop" off
  "bas115"  "Tmux, powerline" off
  "bas120"  "VirtualBox" off
  "bas121"  "Vagrant" off
  "bas130"  "Docker CE" off
  "bas131"  "Docker Compose" off
  "bas132"  ">> Lazydocker" off
  "bas133"  ">> Dive - docker image analyser" off
  "bas134"  "Ansible" off
  "bas135"  "Google Cloud SDK" off
  "bas136"  "AWS CLI SDK" off
  "bas137"  "Azure CLI SDK" off
  "bas138"  ">> Terraform" off
  "bas139"  ">> Packer" off
  "bas140"  ">> s3cmd" off
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
  "dev040"  "pyenv" off
  "dev041"  ">> Pipenv and Pipes" off
  "dev050"  "OpenJDK 8" off
  "dev051"  "OpenJDK 11" off
  "dev060"  "Go language" off
  "dev080"  "Rust+Cargo" off
  "dev100"  "dbeaver Community - Databse Tool" off
  "dev110"  "SQLLite DB Browser" off
  "dev120"  "Clickhouse" off
  "dev130"  "Apache Directory Studio" off
  "dev140"  ">> Ran - Static Http server" off
  "dev141"  "cfssl tools" off
  "dev142"  ">> Insomnia REST client" off
  "dev143"  "Android Tools - adb and fastboot" off
  "------"  "------------------------------" off
  "------"  "----- Productivity Stuff -----" off
  "------"  "------------------------------" off
  "prd000"  "mdbook" off
  "prd001"  ">> Joplin - Notes taking application" off
  "prd002"  ">> Logseq - Personal Knowledge Management" off
  "prd003"  ">> Draw.io - charting software" off
  "prd050"  ">> Mailspring" off
  "prd051"  ">> Minetime" off
  "prd052"  ">>v Slack" off
  "prd060"  ">>v Zoom Meetings App" off
  "prd061"  ">> Microsoft Teams" off
  "prd070"  "Libreoffice" off
  "prd080"  ">> PDFsam basic" off
  "------"  "------------------------------" off
  "------"  "-------- Image Stuff  --------" off
  "------"  "------------------------------" off
  "img000"  "Gnome Paint" off
  "img001"  "mtPaint" off
  "img010"  "Gnome Screenshot" off
  "img011"  "Flameshot Screenshot" off
  "------"  "------------------------------" off
  "------"  "----- Audio Video Stuff  -----" off
  "------"  "------------------------------" off
  "med000"  "Spotify Client" off
  "med010"  "VLC Media Player" off
  "med020"  "Simple Screen Recorder" off
  "med021"  "Peek - Screen to Gif Recorder(see gifcap)" off
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
    sys001) # Installing HDD and NVMe disk management tools 
      echo ""
      echo "Installing HDD and NVMe disk management tools...."
      sudo apt install -y nvme-cli smartmontools
      echo "HDD and NVMe disk management tools installation completed"
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
    sys006) # Installing Solaar
      echo ""
      echo "Installing Solaar...."
      sudo add-apt-repository ppa:soppa:solaar-unifying/stable -y
      sudo apt-get update
      sudo apt install -y solaar
      echo "Touchpad indicator installation completed."
      echo ""
      ;;
    sys007) # Installing XP-Pen G430S drivers
      echo ""
      echo "Installing XP-Pen G430S drivers ...."
      mkdir -p /tmp/xppen
      pushd /tmp/xppen
      wget --content-disposition https://www.xp-pen.com/download/file/id/1949/pid/56/ext/deb.html
      sudo dpkg -i XPPen*.deb
      popd
      rm -rf /tmp/xppen
      echo "XP-Pen G430S driver installation completed. "
      echo ""
      ;;
    sys008) # Installing Xournal++
      echo ""
      echo "Installing Xournal++...."
      # Get latest github release tag or version but printing the redirection url for the latest relese
      version=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/xournalpp/xournalpp/releases/latest | rev | cut -d '/' -f 1 | rev)
      mkdir -p /tmp/xournal
      pushd /tmp/xournal
      curl -L "https://github.com/xournalpp/xournalpp/releases/download/${version}/xournalpp-${version:1}-Ubuntu-jammy-x86_64.deb" --output xournalpp.deb
      sudo dpkg -i xournalpp.deb
      unset version
      popd
      rm -rf /tmp/xournal
      echo "Xournal++ installation completed."
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
      sudo apt install -y libpango-1.0-0
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
    sys020) # Installing Video4Linux
      echo ""
      echo "Installing Video4Linux and GSVCView..."
      sudo apt-add-repository ppa:pj-assis/ppa -y
      sudo apt-get update
      sudo apt install -y v4l-utils guvcview
      echo "Video4Linux and GSVCView installation completed"
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
      # Below line is commented for 20.04
      # sudo apt-add-repository ppa:tista/adapta -y
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
#      echo ""
#      echo "Installing moka icons theme...."
#      sudo add-apt-repository ppa:snwh/ppa -y
#      sudo apt-get update
#      sudo apt-get install -y moka-icon-theme faba-icon-theme faba-mono-icons
#      echo "moka icon theme installation completed."
#      echo ""
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
    bas020) # Install AppImage Launcher
      echo ""
      echo "Installing AppImage Launcher...."
      sudo apt install software-properties-common
      sudo add-apt-repository ppa:appimagelauncher-team/stable
      sudo apt update
      sudo apt install appimagelauncher
      echo "AppImage Launcher installation completed."
      echo ""
      ;;
    bas027) # Installing Firefox
      echo ""
      echo "Removing Firefox snap browser...."
      sudo snap remove firefox
      rm -rf "${HOME}/snap/firefox"
      echo "Creating /etc/apt/preferences.d/firefox-no-snap file...."
      echo "Package: firefox*" | sudo tee /etc/apt/preferences.d/firefox-no-snap
      echo "Pin: release o=LP-PPA-mozillateam" | sudo tee -a /etc/apt/preferences.d/firefox-no-snap
      echo "Pin-Priority: 1001" | sudo tee -a /etc/apt/preferences.d/firefox-no-snap
      echo "Creating /etc/apt/apt.conf.d/51unattended-upgrades-firefox file...."
      echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";' | sudo tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox
      echo "Installing  APT browser...."
      # Handle as explained in https://www.debugpoint.com/2021/09/remove-firefox-snap-ubuntu/
      # and https://askubuntu.com/questions/1399383/how-to-install-firefox-as-a-traditional-deb-package-without-snap-in-ubuntu-22/1403204#1403204
      sudo add-apt-repository -y ppa:mozillateam/ppa
      sudo apt-get update
      sudo apt-get install firefox-esr
      echo "Firefox install completed."
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
      # Get latest github release tag or version but printing the redirection url for the latest relese
      version=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/isacikgoz/gitbatch/releases/latest | rev | cut -d '/' -f 1 | rev)
      mkdir -p /tmp/gitbatch
      pushd /tmp/gitbatch
      curl -L "https://github.com/isacikgoz/gitbatch/releases/download/${version}/gitbatch_${version:1}_linux_amd64.tar.gz" --output gitbatch.tar.gz
      tar xzf gitbatch.tar.gz
      chmod u+x gitbatch
      mv gitbatch "${HOME}/.local/bin"
      unset version
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
      # Get latest github release tag or version but printing the redirection url for the latest relese
      version=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/jesseduffield/lazygit/releases/latest | rev | cut -d '/' -f 1 | rev)
      mkdir -p /tmp/lazygit
      pushd /tmp/lazygit
      curl -L "https://github.com/jesseduffield/lazygit/releases/download/${version}/lazygit_${version:1}_Linux_x86_64.tar.gz" --output lazygit.tar.gz
      tar -zxvf lazygit.tar.gz
      chmod u+x lazygit
      mv lazygit "${HOME}/.local/bin"
      unset version
      popd
      rm -rf /tmp/lazygit
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
    bas106) # Install authy
      echo ""
      echo "Installing authy ...."
      sudo snap install authy
      echo "Authy installation completed"
      ;;
    bas110) # Install dotdrop, has to be done as system else global dotrop for system files will not work
      echo ""
      echo "Installing dotdrop from pypi for the user, not using virtualenv ...."
      sudo python3 -m pip install --upgrade dotdrop
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
    bas120) # Installing VirtualBox
      echo ""
      echo "Installing VirtualBox...."
#      wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
#      wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
#      sudo add-apt-repository "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" -y
      sudo apt-get update && sudo apt install -y virtualbox
      echo "VirtualBox installation completed."
      ;;
    bas121) # Installing Vagrant
      echo ""
      echo "Installing Vagrant ...."
#      curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
#      sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
      wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
      echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
      sudo apt update && sudo apt install vagrant
      echo "Vagrant installation completed."
      ;;
    bas130) # Installing Docker Community Edition
      echo ""
      echo "Installing Docker CE...."
      sudo apt-get remove docker docker-engine docker.io containerd runc
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
      echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      sudo apt-get update
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
      sudo usermod -a -G docker $USER
      echo "Docker installation completed."
      ;;
    bas131) # Install docker compose
      echo "Docker compose is now part of Docker CE"
#      # Get latest github release tag or version but printing the redirection url for the latest relese
#      version=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/docker/compose/releases/latest | rev | cut -d '/' -f 1 | rev)
#      version="1.27.4"  # hardcoading as 1.28.0 was giving python library error
#      echo "Installing Docker Compose...."
#      sudo curl -L "https://github.com/docker/compose/releases/download/${version}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
#      sudo chmod +x /usr/local/bin/docker-compose
#      unset version
#      echo ""
      ;;
    bas132) # Installing Lazydocker
      echo ""
      echo "Installing Lazydocker ...."
      curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
      mv lazydocker "${HOME}/.local/bin"
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
      sudo apt-get install -y ansible python3-argcomplete
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
      if which aws; then
        sudo ./aws/install -i /usr/local/aws-cli -b /usr/local/bin --update
      else
        sudo ./aws/install -i /usr/local/aws-cli -b /usr/local/bin
      fi
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
      version=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/hashicorp/terraform/releases/latest | rev | cut -d '/' -f 1 | rev)
      curl -L "https://releases.hashicorp.com/terraform/${version:1}/terraform_${version:1}_linux_amd64.zip" --output terraform.zip
      unzip terraform.zip
      chmod u+x terraform
      mv terraform "${HOME}/.local/bin"
      popd
      unset version
      rm -rf /tmp/terraform
      echo "Terraform installation completed."
      echo ""
      ;;
    bas139) # Installing Packer
      echo ""
      echo "Installing Packer...."
      mkdir -p /tmp/packer
      pushd /tmp/packer
      version=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/hashicorp/packer/releases/latest | rev | cut -d '/' -f 1 | rev)
      curl -L "https://releases.hashicorp.com/packer/${version:1}/packer_${version:1}_linux_amd64.zip" --output packer.zip
      unzip packer.zip
      chmod u+x packer
      mv packer "${HOME}/.local/bin"
      popd
      unset version
      rm -rf /tmp/packer
      echo "Packer installation completed."
      echo ""
      ;;
    bas140) # Install s3cmd
      echo ""
      echo "Installing s3cmd from pypi systemwide ...."
      python3 -m pip install --user --upgrade s3cmd
      echo "s3cmd Installation completed."
      ;;
    bas150) # Installing Kubernetes Tools
      # Show k8s tool dialog
      kcmd=(dialog --separate-output --checklist "Select k8s tools to install:" 22 76 16)
      koptions=(
        "------"  "--------- k8s flavors --------" off
        "k000"  "k3d - local k8s cluster using docker" off
        "k001"  "kind - k3d alternative, local k8s using docker" off
        "k002"  "k0sctl - create kubernetes on baremetal" off
        "------"  "------- k8s cli tools  -------" off
        "k010"  "kubectl - the main k8s controller cli" off
        "k011"  "kubectx (context) and kubens (namespace) switchers" off
        "k020"  "k9s - terminal gui based k8s cli" off
        "k013"  "kubestr - Kubernetes Storage Check" off
        "------"  "--------  cli monitor  -------" off
        "k040"  "kubebox - Terminal and Web console for K8S" off
        "------"  "-------  package mgrs  -------" off
        "k200"  "Helm" off
      )
      kchoices=$("${kcmd[@]}" "${koptions[@]}" 2>&1 >/dev/tty)
      clear

      for kchoice in $kchoices; do
        case $kchoice in
          k000)
            echo "Installing k3d...."
            # Get latest github release tag or version but printing the redirection url for the latest relese
            version=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/rancher/k3d/releases/latest | rev | cut -d '/' -f 1 | rev)
            wget "https://github.com/rancher/k3d/releases/download/${version}/k3d-linux-amd64" -O "${HOME}/.local/bin/k3d"
            unset version
            chmod u+x "${HOME}/.local/bin/k3d"
            echo "k3d installation completed."
            echo ""
            ;;
          k001)
            echo "Installing kind...."
            version=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/kubernetes-sigs/kind/releases/latest | rev | cut -d '/' -f 1 | rev)
            wget "https://github.com/kubernetes-sigs/kind/releases/download/${version}/kind-linux-amd64" -O "${HOME}/.local/bin/kind"
            unset version
            chmod u+x "${HOME}/.local/bin/kind"
            echo "kind installation completed."
            echo ""
            ;;
          k002)
            echo "Installing k0sctl...."
            version=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/k0sproject/k0sctl/releases/latest | rev | cut -d '/' -f 1 | rev)
            wget "https://github.com/k0sproject/k0sctl/releases/download/${version}/k0sctl-linux-x64" -O "${HOME}/.local/bin/k0sctl"
            unset version
            chmod u+x "${HOME}/.local/bin/k0sctl"
            k0sctl completion | sudo tee /etc/bash_completion.d/k0sctl
            echo "k0sctl installation completed."
            echo ""
            ;;
          k010)
            echo ""
            echo "Installing kubectl...."
            kubectl_version=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
            wget "https://storage.googleapis.com/kubernetes-release/release/${kubectl_version}/bin/linux/amd64/kubectl" -O "${HOME}/.local/bin/kubectl"
            chmod u+x "${HOME}/.local/bin/kubectl"
            echo "kubectl installation completed."
            echo ""
            ;;
          k011)
            echo "Installing kubectx and kubens...."
            mkdir -p /tmp/kubectx
            pushd /tmp/kubectx
            version=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/ahmetb/kubectx/releases/latest | rev | cut -d '/' -f 1 | rev)
            wget "https://github.com/ahmetb/kubectx/releases/download/${version}/kubectx_${version}_linux_x86_64.tar.gz" -O "kubectx.tar.gz"
            wget "https://github.com/ahmetb/kubectx/releases/download/${version}/kubens_${version}_linux_x86_64.tar.gz" -O "kubens.tar.gz"
            tar -zxvf kubectx.tar.gz
            tar -zxvf kubens.tar.gz
            chmod u+x kubectx
            chmod u+x kubens
            mv kubectx "${HOME}/.local/bin"
            mv kubens "${HOME}/.local/bin"
            popd
            unset version
            rm -rf /tmp/kubectx
            echo "kubectx and kubens installation completed."
            echo ""
            ;;
          k013)
            echo "Installing kubestr...."
            version=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/kastenhq/kubestr/releases/latest | rev | cut -d '/' -f 1 | rev)
            wget "https://github.com/kastenhq/kubestr/releases/download/${version}/kubestr_${version:1}_Linux_amd64.tar.gz" -O "kubestr.tar.gz"
            tar -zxvf kubestr.tar.gz
            chmod u+x kubestr
            mv kubestr "${HOME}/.local/bin"
            unset version
            echo "kubestr installation completed."
            echo ""
            ;;
          k020)
            echo "Installing k9s...."
            version=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/derailed/k9s/releases/latest | rev | cut -d '/' -f 1 | rev)
            mkdir -p /tmp/k9s
            pushd /tmp/k9s
            wget "https://github.com/derailed/k9s/releases/download/${version}/k9s_Linux_amd64.tar.gz" -O k9s.tar.gz
            unset version
            tar -zxvf k9s.tar.gz
            chmod u+x k9s
            mv k9s "${HOME}/.local/bin/k9s"
            popd
            echo "k9s installation completed."
            echo ""
            ;;
          k040)
            echo "Installing kubebox...."
            version=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/astefanutti/kubebox/releases/latest | rev | cut -d '/' -f 1 | rev)
            wget "https://github.com/astefanutti/kubebox/releases/download/${version}/kubebox-linux" -O "${HOME}/.local/bin/kubebox"
            unset version
            chmod u+x "${HOME}/.local/bin/kubebox"
            echo "kubebox installation completed."
            echo ""
            ;;
          k200)
            echo "Installing helm...."
            mkdir -p /tmp/helm
            pushd /tmp/helm
            version=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/helm/helm/releases/latest | rev | cut -d '/' -f 1 | rev)
            wget "https://get.helm.sh/helm-${version}-linux-amd64.tar.gz" -O helm.tar.gz
            unset version
            tar -zxvf helm.tar.gz
            mv linux-amd64/helm "${HOME}/.local/bin"
            chmod u+x "${HOME}/.local/bin/helm"
            popd
            echo "helm installation completed."
            echo ""
            ;;
          *)
              # Default Option
            ;;
        esac
      done
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
      curl -L 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' --output vscode.deb
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
    dev040) #Install pyenv
      echo ""
      echo "Installing pyenv"
      curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
      echo "pyenv installation completed."
      ;;
    dev041) # Install pipenv
      echo ""
      echo "Installing pipenv and pipes from pypi for user only...."
      # Use below line for install
      # python3 -m pip install --user pipenv
      # python3 -m pip install --user pipenv-pipes
      python3 -m pip install --upgrade --user pipenv
      python3 -m pip install --upgrade --user pipenv-pipes
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
      curl -L https://downloads.apache.org/directory/studio/2.0.0.v20210717-M17/ApacheDirectoryStudio-2.0.0.v20210717-M17-linux.gtk.x86_64.tar.gz --output ads.tar.gz
      sudo tar zxvf ads.tar.gz && sudo mv ApacheDirectoryStudio /opt
      ln -s /opt/ApacheDirectoryStudio/ApacheDirectoryStudio "${HOME}"/.local/bin/ldapbrowser
      popd
      rm -rf /tmp/ads
      echo "Apache Directory Studio installation completed. "
      echo ""
      ;;
    dev140) # Installing Ran - Static Http Web server
      echo ""
      # Get latest github release tag or version but printing the redirection url for the latest relese
      version=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/m3ng9i/ran/releases/latest | rev | cut -d '/' -f 1 | rev)
      echo "Installing Ran - Static Http Web Server...."
      mkdir -p /tmp/ran
      pushd /tmp/ran
      curl -L "https://github.com/m3ng9i/ran/releases/download/${version}/ran_linux_amd64.zip" -o ran.zip
      unzip ran.zip
      mv ran_linux_amd64 "${HOME}/.local/bin/http-server"
      popd
      unset version
      rm -rf /tmp/ran
      echo "Ran http-server installation completed."
      echo ""
      ;;
    dev141) # Installing cfssl tools
      echo ""
      echo "Installing cfssl tools...."
      cfssl_version="${cfssl_version:-1.6.0}"
      cfssl_arch="${cfssl_arch:-linux_amd64}"
      cfssl_binaries=(cfssl-bundle cfssl-certinfo cfssl-newkey cfssl-scan cfssljson cfssl mkbundle multirootca)
      for cfssl_binary in "${cfssl_binaries[@]}"; do
        curl -L "https://github.com/cloudflare/cfssl/releases/download/v${cfssl_version}/${cfssl_binary}_${cfssl_version}_${cfssl_arch}" \
          -o "${HOME}/.local/bin/${cfssl_binary}"
        chmod +x "${HOME}/.local/bin/${cfssl_binary}"
        echo "${cfssl_binary} installation completed."
      done
      echo ""
      ;;
    dev142) # Installing Insomnia REST client
      echo ""
      # Get latest github release tag or version but printing the redirection url for the latest relese
      version=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/Kong/insomnia/releases/latest | rev | cut -d '@' -f 1 | rev)
      echo "Installing Insomnia REST API client..."
      mkdir -p /tmp/insomnia
      pushd /tmp/insomnia
      version="2022.2.1"
      curl -L "https://github.com/Kong/insomnia/releases/download/core@${version}/Insomnia.Core-${version}.deb" -o insomnia.deb
      sudo dpkg -i insomnia.deb
      popd
      unset version
      rm -rf /tmp/insomnia
      echo "Insomnia installation completed."
      echo ""
      ;;
    dev143) # Installing Android tools - adb and fastboot
      echo ""
      # Get latest github release tag or version but printing the redirection url for the latest relese
      echo "Installing adb and fastboot ..."
      mkdir -p /tmp/adb
      pushd /tmp/adb
      curl -L "https://dl.google.com/android/repository/platform-tools-latest-linux.zip" -o adb-tools.zip
      unzip adb-tools.zip
      mv platform-tools ~/bin/android-tools
      popd
      unset version
      rm -rf /tmp/adb
      echo "adb and fastboot installation completed."
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
    prd002) # Installing Logseq
      echo ""
      echo "Installing Logseq desktop client..."
      # Get latest github release tag or version but printing the redirection url for the latest relese
      version=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/logseq/logseq/releases/latest | rev | cut -d '/' -f 1 | rev)
      mkdir -p /tmp/logseq
      pushd /tmp/logseq
      curl -L "https://github.com/logseq/logseq/releases/download/${version}/Logseq-linux-x64-${version}.zip" -o logseq.zip
      unzip logseq.zip
      mv Logseq-linux-x64 ~/.local/bin
      ln -s ~/.local/bin/Logseq-linux-x64/Logseq ~/.local/bin/logseq
      popd
      unset version
      rm -rf /tmp/logseq
      echo "Logseq desktop client installation completed."
      echo ""
      ;;
    prd003) # Installing draw.io
      echo ""
      echo "Installing Drawio desktop client..."
      # Get latest github release tag or version but printing the redirection url for the latest relese
      version=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/jgraph/drawio-desktop/releases/latest | rev | cut -d '/' -f 1 | rev)
      mkdir -p /tmp/drawio
      pushd /tmp/drawio
      curl -L "https://github.com/jgraph/drawio-desktop/releases/download/${version}/drawio-amd64-${version:1}.deb" -o drawio.deb
      sudo dpkg -i drawio.deb
      popd
      unset version
      rm -rf /tmp/drawio
      echo "Drawio desktop client installation completed."
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
      echo "Installing Minetime/Morgen...."
      mkdir -p /tmp/minetime
      pushd /tmp/minetime
      curl -L https://dl.todesktop.com/210203cqcj00tw1/linux/deb/x64 --output minetime.deb
      sudo dpkg -i minetime.deb
      popd
      rm -rf /tmp/minetime
      echo "Minetime/Morgen installation completed."
      echo ""
      ;;
    prd052) # Installing Slack
      echo ""
      echo "Installing Slack...."
      mkdir -p /tmp/slack
      pushd /tmp/slack
      version="4.33.90"
      curl -L "https://downloads.slack-edge.com/releases/linux/${version}/prod/x64/slack-desktop-${version}-amd64.deb" --output slack.deb
      sudo apt install ./slack.deb
      popd
      unset version
      rm -rf /tmp/slack
      echo "Slack installation completed."
      echo ""
      ;;
    prd060) # Installing Zoom Meeting
      echo ""
      echo "Installing zoom meeting app...."
      mkdir -p /tmp/zoom
      pushd /tmp/zoom
      # To download older versions of zoom
      # Get the full version number from https://support.zoom.us/hc/en-us/articles/205759689-New-Updates-For-Linux
      version="5.13.4.711" # 5.10 has a bug on linux, video does not work
      curl -L "https://zoom.us/client/${version}/zoom_amd64.deb" --output zoom.deb
      # Latest version (5.10) has a bug on linux, video does not work
      #curl -L https://zoom.us/client/latest/zoom_amd64.deb --output zoom.deb
      sudo apt install ./zoom.deb
      popd
      unset version
      #rm -rf /tmp/zoom
      echo "Zoom installation completed."
      echo ""
      ;;
    prd061) # Installing Microsoft Teams
      # This needs improvement - download the latest version from tis file listing
      # https://packages.microsoft.com/repos/ms-teams/pool/main/t/teams/
      echo ""
      echo "Installing MS Teams...."
      mkdir -p /tmp/msteams
      pushd /tmp/msteams
      curl -L "https://go.microsoft.com/fwlink/p/?LinkID=2112886&clcid=0x409&culture=en-us&country=US" --output teams.deb
      sudo apt install ./teams.deb
      popd
      rm -rf /tmp/msteams
      echo "MS Teams installation completed."
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
      version=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/torakiki/pdfsam/releases/latest | rev | cut -d '/' -f 1 | rev)
      curl -L  "https://github.com/torakiki/pdfsam/releases/download/${version}/pdfsam_${version:1}-1_amd64.deb" --output pdfsam.deb
      sudo dpkg -i pdfsam.deb
      popd
      unset version
      rm -rf /tmp/pdfsamb
      echo "PDFsam installation completed. "
      echo ""
      ;;
    img000) # Installing Gnome Paint
      echo ""
      echo "Installing Gnome Paint...."
      sudo apt install -y gnome-paint
      echo "Gnome Paint installation completed. "
      echo ""
      ;;
    img001) # Installing mtPaint
      echo ""
      echo "Installing mtPaint...."
      sudo apt install -y mtpaint
      echo "mtPaint installation completed. "
      echo ""
      ;;
    img010) # Installing Gnome Screenshot
      echo ""
      echo "Installing Gnome Screenshot...."
      sudo apt install -y gnome-screenshot
      echo "Gnome screenshot installed."
      echo ""
      ;;
    img011) # Installing Flameshot
      echo ""
      echo "Installing Flameshot...."
      sudo apt install -y flameshot
      echo "Flameshot installed"
      echo ""
      ;;
    med000) # Installing Spotify Client
      echo ""
      echo "Installing Spotify Client...."
      curl -sS https://download.spotify.com/debian/pubkey_5E3C45D7B312C643.gpg | sudo gpg --dearmor -o /usr/share/keyrings/spotify.gpg
      echo "deb [signed-by=/usr/share/keyrings/spotify.gpg] http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
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
    med021) # Install Peek - Screen to Gif Recorder. 
      # Alternative - Also see https://gifcap.dev for web based tool
      # Alternative - see github lecram/congif for converting script shell recording to gifs
      echo ""
      echo "Installing Peek - Screen to Gif Recorder ...."
      sudo apt-get update
      sudo apt install -y peek 
      echo "Peek Installation completed."
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

# Allow to review the changes before dialog
read -s -p 'Press Enter to continue ..'

# Run fixbroken install?
dialog --title "Fix Broken? " \
  --yesno "Do you want to run apt --fix-broken install ?" 8 45
if [[ "$?" -eq 0 ]]; then
  clear
  echo ">>> Fixing broken install applications ...."
  sudo apt --fix-broken -y install
  read -s -p 'Press Enter to continue ..'
fi

# Check if autoremove is needed
dialog --title "Auto Remove? " \
  --yesno "Do you want to run apt auto-remove ?" 8 45
if [[ "$?" -eq 0 ]]; then
  clear
  echo ">>> Removing unwanted applications ...."
  sudo apt auto-remove -y
  read -s -p 'Press Enter to continue ..'
fi

# finally clear everything
clear

# vim: filetype=sh
