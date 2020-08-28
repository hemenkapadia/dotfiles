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
  sudo apt install -y tree wget curl htop unzip net-tools icdiff\
                      openssl gnupg-agent apt-transport-https ca-certificates \
                      python3 python3-dev python3-virtualenv python3-venv python3-pip \
                      software-properties-common build-essential 
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
  17  "Gnome Calendar" off
  18  "VPN and Gnome Network Manager" off
  19  "Touchpad Indicator" off
  20  "Tmux, powerline" off
  21  "Libreoffice" off
  22  "dbeaver Community - Databse Tool" off
  23  "hid_apple patch for magic keyboard" off
  24  "Zoom Meetings App" off
  25  "OpenJDK 8" off
  26  "Adapta theme" off
  27  "Lazydocker" off
  28  "Gitbatch" off
  29  "Spotify Client" off
  30  "Minetime" off
  31  "Gnome Clocks" off
  32  "Go language" off
  33  "Apache Directory Studio" off
  34  "PDFsam basic" off
  35  "VLC Media Player" off
  36  "Simple Screen Recorder" off
  37  "Rust+Cargo" off
  38  "mdbook" off
  39  "Docker Compose" off
  40  "Canon MX 490 Printer Drivers" off
  41  "Canon MX 490 Scanner Drivers" off
  42  "Xsane Scanning ssoftware" off
  43  "Icon themes" off
  44  "Clickhouse" off
  45  "Dive - docker image analyser" off
  46  "Joplin - Notes taking application" off
  47  "YARN" off
  48  "SQLLite DB Browser" off
  49  "Open Boradcast Studio" off
  50  "Lightworks Video Studio" off
  51  "Shotcut Video Editor" off
)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear

for choice in $choices; do
  case $choice in
    01) # Install Git
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
      sudo apt install -y tig
      echo "Tig Installation completed."
      echo ""
      ;;
    05) # Install Lazygit
      echo ""
      echo "Installing Lazygit  ...."
      sudo add-apt-repository ppa:lazygit-team/release -y
      sudo apt-get update
      sudo apt install -y lazygit
      echo "Lazygit Installation completed."
      echo ""
      ;;
    06) # Install tmux
      echo ""
      echo "Installing tmux...."
      sudo apt-get update
      sudo apt install -y tmux
      echo "Lazygit Installation completed."
      echo ""
      ;;
    07) # Install Miniconda latest
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
    11) # Installing Docker Community Edition
      echo ""
      echo "Installing Docker CE...."
      sudo apt-get remove docker docker-engine docker.io containerd runc
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
      sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" -y
      sudo apt-get update
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io
      sudo usermod -a -G docker
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
    17) # Installing Gnome Calendar
      echo ""
      echo "Installing Gnome Calendar...."
      sudo apt install -y gnome-calendar
      echo "Gnome Calendar installation completed."
      echo ""
      ;;
    18) # Installing VPN and Gnome Network Manager
      echo ""
      echo "Installing VPN...."
      sudo apt install -y vpnc vpnc-connect network-manager-vpnc-gnome
      echo "VPN installation completed. You will need to configure VPN connection yourself."
      echo ""
      ;;
    19) # Installing Touchpad Indicator
      echo ""
      echo "Installing Touchpad Indicator...."
      sudo add-apt-repository ppa:atareao/atareao -y
      sudo apt-get update
      sudo apt install -y touchpad-indicator
      echo "Touchpad indicator installation completed."
      echo ""
      ;;
    20) # Installing Tmux and Powerline
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
    21) # Installing Libreoffice
      echo ""
      echo "Installing Libreoffice...."
      sudo apt install -y libreoffice
      echo "Libreoffice installation completed."
      echo ""
      ;;
    22) # Installing DBeaver
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
    23) # Installing Apple Magic Keyboard config kernel module
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
    24) # Installing Zoom Meeting
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
    25) # Installing OpenJDK 8
      echo ""
      echo "Installing OpenJDK 8...."
      sudo apt install -y openjdk-8-jdk
      echo "OpenJDK 8 installation completed."
      echo ""
      ;;
    26) # Installing Adapta Theme
      echo ""
      echo "Installing Adapta Theme...."
      sudo apt-add-repository ppa:tista/adapta -y
      sudo apt-get update
      sudo apt install -y adapta-gtk-theme
      echo "Adapta theme installation completed."
      echo ""
      ;;
    27) # Installing Lazydocker
      echo ""
      echo "Installing Lazydocker ...."
      curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
      echo "Lazydocker installation completed."
      echo ""
      ;;
    28) # Installing Gitbatch
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
    29) # Installing Spotify Client
      echo ""
      echo "Installing Spotify Client...."
      curl -sS https://download.spotify.com/debian/pubkey.gpg | sudo apt-key add -
      echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
      sudo apt-get update && sudo apt install -y spotify-client
      echo "Spotify Client installation completed."
      echo ""
      ;;
    30) # Installing Minetime
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
    31) # Installing Gnome Clocks
      echo ""
      echo "Installing Gnome Clocks...."
      sudo apt install -y gnome-clocks
      echo "Gnome Clocks installation completed."
      echo ""
      ;;
    32) # Installing Go language
      echo ""
      echo "Installing Go language...."
      mkdir -p /tmp/golang
      pushd /tmp/golang
      curl -L https://dl.google.com/go/go1.13.4.linux-amd64.tar.gz --output go.tar.gz
      sudo tar zxvf go.tar.gz && sudo mv go /usr/local
      echo 'export PATH="/usr/local/go/bin:$PATH"' >> "${HOME}"/.bash_envvars
      popd
      rm -rf /tmp/golang
      echo "Go language installation completed. "
      echo ""
      ;;
    33) # Installing Apache Directory Studio
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
    34) # Installing PDFsam baisc
      echo ""
      echo "Installing PDFsam basic...."
      mkdir -p /tmp/pdfsamb
      pushd /tmp/pdfsamb
      curl -L  https://github.com/torakiki/pdfsam/releases/download/v4.0.5/pdfsam_4.0.5-1_amd64.deb --output pdfsam.deb
      sudo dpkg -i pdfsam.deb
      popd
      rm -rf /tmp/pdfsamb
      echo "PDFsam installation completed. "
      echo ""
      ;;
    35) # Install VLC
      echo ""
      echo "Installing VLC ...."
      sudo apt-get update
      sudo apt install -y vlc
      echo "VLC Installation completed."
      echo ""
      ;;
    36) # Install Simple Screen Recorded
      echo ""
      echo "Installing Simple Screen Recorder ...."
      sudo apt-get update
      sudo apt install -y simplescreenrecorder
      echo "SimpleScreenRecorder Installation completed."
      echo ""
      ;;
    37) # Install Rust + Cargo
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
    38) # Install mdbook
      echo ""
      echo "Installing mdbook...."
      cargo install mdbook
      cargo install mdbook-toc
      echo "mdbook Installation completed."
      echo ""
      ;;
    39) # Install docker compose
      echo ""
      echo "Installing Docker Compose...."
      sudo curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
      sudo chmod +x /usr/local/bin/docker-compose
      echo ""
      ;;
    40) # Installing Cannon MX490 Printer Drivers
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
    41) # Installing Canon MX490 Scanner Drivers
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
    42) # Install SANE scanning software
      echo ""
      echo "Installing xsane scanning software...."
      sudo apt-get update
      sudo apt install -y sane sane-utils libsane-extras xsane
      echo "Xsane Installation completed."
      echo ""
      ;;
    43) # Ubuntu icon themes 
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
    44) # Clickhouse installation 
      echo ""
      echo "Installing clickhouse...."
      echo "deb http://repo.yandex.ru/clickhouse/deb/stable/ main/" | sudo tee -a /etc/apt/sources.list.d/clickhouse.list
      sudo apt-key adv --keyserver keyserver.ubuntu.com --recv E0C56BD4
      sudo apt-get update
      sudo apt-get install -y clickhouse-server clickhouse-client 
      echo "Clickhouse installation completed."
      echo ""
      ;;
    45) # Installing Dive - docker image analyser 
      echo ""
      echo "Installing Dive - docker image analyser...."
      mkdir -p /tmp/dive
      pushd /tmp/dive
      curl -L https://github.com/wagoodman/dive/releases/download/v0.9.2/dive_0.9.2_linux_amd64.deb --output dive.deb
      sudo apt install ./dive.deb
      popd
      rm -rf /tmp/dive
      echo "Dive installation completed. "
      echo ""
      ;;
    46) # Installing Joplin 
      echo ""
      echo "Installing Joplin - Notes taking application...."
      wget -O - https://raw.githubusercontent.com/laurent22/joplin/master/Joplin_install_and_update.sh | bash      
      echo "Joplin installation completed. "
      echo ""
      ;;
    47) # Installing YARN 
      echo ""
      echo "Installing YARN...."
      curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
      echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
      sudo apt update && sudo apt install yarn
      echo "YARN installation completed. "
      echo ""
      ;;
    48) # Installing SQL Lite DB Browser 
      echo ""
      echo "Installing SQL Lite DB Browser...."
      sudo apt update && sudo apt install sqlitebrowser 
      echo "YARN installation completed. "
      echo ""
      ;;
    49) # Installing Open Broadcast Studio 
      echo ""
      echo "Installing Open Broadcast Studio...."
      sudo add-apt-repository ppa:obsproject/obs-studio 
      sudo apt update
      sudo apt install -y ffmpeg obs-studio
      echo "Open Broadcast Studio installation completed. "
      echo ""
      ;;
    50) # Installing lightworks 
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
    51) # Installing Shotcut vidoe editor 
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
      echo "Hmm ... nothing to do here"
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
