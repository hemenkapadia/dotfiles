Dotfiles
========

!! NOTE !!
----------

This file needs to be reviewed for correctness. Improvised as learnt more and possibly did not update. Take it with a pinch of salt

Setting up dotfile from scratch

- From Github UI console create a new repository called `dotfiles` and initialize it with a README.md and LICENSE (optional)
- Install Git, Git SSH Keys and dotdrop using the setup install script.
- Update PATH `export PATH=${PATH}:${HOME}/.local/bin`
- Create a new repository `dotfiles` on github and initialize with readme
- With Git available and ssh-agent populated with the github key, we clone the `dotfiles` repository `git clone git@github.com:hemenkapadia/dotfiles.git` in $HOME directory. This would only have your README and LICENSE (if selected) for now.
- `cd ~/dotfiles` and `mkdir dotfiles-store`
- Create `config.yaml` with the contents in the `dotfiles` directory.
```
config:
  backup: true
  banner: false 
  create: true
  dotpath: dotfiles-store
  keepdot: false
  link_dotfile_default: nolink
  link_on_import: nolink
  longkey: true
  workdir: ~/.config/dotdrop 
dotfiles:
profiles:

```
- So now you have a directory structure like 
```
hemen@hemen-XPS-13-9370:~/dotfiles$ ls -l 
total 12
-rw-r--r-- 1 hemen hemen  191 Oct  1 11:08 config.yaml
drwxr-xr-x 2 hemen hemen 4096 Oct  1 11:09 dotfiles-store
-rw-r--r-- 1 hemen hemen   10 Oct  1 10:55 README.md
hemen@hemen-XPS-13-9370:~/dotfiles$ 
```

- Create environment variables in the shell for now, we will need to come up with a way to preserve this later. For now this is fine, but note that if you exit the shell you need to recreate them

  - `export DOTDROP_PROFILE=worklaptop`
  - `export DOTDROP_CONFIG=$HOME/dotfiles/config.yaml`

- Check with the command `dotdrop list` if it works. Should not list any profile files as yet and should indicate that it is using the `worklaptop` profile that you set in the environment variable.

- Now we start importing our first dotfile.
`dotdrop import ~/.gitconfig`. This will copy the `~/.gitconfig` file to `dotfiles-store` and then update the key and entry in `config.yaml`. At this point we commit these two files to git (i use lazygit).
- Optionally push your local commits to github.

- I updated the base .bashrc to support .bash_aliases, .bash_envvars and .bash_functions and created these files. To see the changes I made to a tracked dotfile i use the command as below

```
hemen@hemen-XPS-13-9370:~$ dotdrop compare
=> compare f_bashrc: diffing with "/home/hemen/.bashrc"
98a99,103
> # Environment Variables definitions.
> if [ -f ~/.bash_envvars ]; then
>     . ~/.bash_envvars
> fi
> 
105a111,115
> fi
> 
> #  Function definitions.
> if [ -f ~/.bash_functions ]; then
>     . ~/.bash_functions
hemen@hemen-XPS-13-9370:~$ 
```

- Since I know there is a difference we update this dotfile `dotdrop update ~/.bashrc`

- This marks the files in the git repo as edited. Add the files to Git and commit them with a meaningful message

- So the general process is
  - Make changes in the managed dotfiles / 
  - IF changes in dotfiles then do a `dotdrop compare` and then `dotdrop update`. If new file then `dotdrop import`
  - Then go to lazygit and add the changed files and commit them with a meaningful message.
  - Repeat

Global Configuration
--------------------

Based on the direction at https://github.com/deadc0de6/dotdrop/wiki/global-config-files I created a new global config file and dotpath directory

- Create a new directory `dotfiles-global-store` in the dotfiles repo
- Create a new config file `config-global.yaml` in the dotfiles repo with the following contents
```
hemen@hemen-XPS-13-9370:~/dotfiles$ cat config-global.yaml 
config:
  backup: true
  banner: false
  create: true
  dotpath: dotfiles-global-store
  keepdot: false
  link_dotfile_default: nolink
  link_on_import: nolink
  longkey: true
  workdir: ~/.config/dotdrop-global
dotfiles:
profiles:hemen@hemen-XPS-13-9370:~/dotfiles$ 
```
- We also update the `.bash_alias` file and create new alias / command called `global-dotdrop` as below 
```
alias global-dotdrop="dotdrop --cfg $HOME/dotfiles/config-global.yaml"
```
- At this point the commands work as expected ...

```
hemen@hemen-XPS-13-9370:~$ dotdrop list
Available profile(s):
	-> key:"worklaptop"

hemen@hemen-XPS-13-9370:~$ dotdrop listfiles
Dotfile(s) for profile "worklaptop"
f_gitconfig (src: "/home/hemen/dotfiles/dotfiles-store/gitconfig", link: nolink)
	-> /home/hemen/.gitconfig
f_bashrc (src: "/home/hemen/dotfiles/dotfiles-store/bashrc", link: nolink)
	-> /home/hemen/.bashrc
f_bash_envvars (src: "/home/hemen/dotfiles/dotfiles-store/bash_envvars", link: nolink)
	-> /home/hemen/.bash_envvars
f_bash_aliases (src: "/home/hemen/dotfiles/dotfiles-store/bash_aliases", link: nolink)
	-> /home/hemen/.bash_aliases
f_bash_functions (src: "/home/hemen/dotfiles/dotfiles-store/bash_functions", link: nolink)
	-> /home/hemen/.bash_functions
f_profile (src: "/home/hemen/dotfiles/dotfiles-store/profile", link: nolink)
	-> /home/hemen/.profile
f_bash_logout (src: "/home/hemen/dotfiles/dotfiles-store/bash_logout", link: nolink)
	-> /home/hemen/.bash_logout
f_install_script.sh (src: "/home/hemen/dotfiles/dotfiles-store/install_script.sh", link: nolink)
	-> /home/hemen/install_script.sh

hemen@hemen-XPS-13-9370:~$ global-dotdrop list
Available profile(s):

hemen@hemen-XPS-13-9370:~$ global-dotdrop listfiles
[WARN] unknown profile "worklaptop" 
hemen@hemen-XPS-13-9370:~$ 
```

- To add the system file `/etc/docker/daemon.json`, I followed the below steps. **NOTE** for system files always use absolute paths !!!

```
hemen@hemen-XPS-13-9370:~/Downloads$ global-dotdrop import /etc/docker/daemon.json 
	-> "/etc/docker/daemon.json" imported

1 file(s) imported.
hemen@hemen-XPS-13-9370:~/Downloads$ 

hemen@hemen-XPS-13-9370:~/Downloads$ global-dotdrop list
Available profile(s):
	-> key:"worklaptop"

hemen@hemen-XPS-13-9370:~/Downloads$ global-dotdrop listfiles
Dotfile(s) for profile "worklaptop"
f_etc_docker_daemon.json (src: "/home/hemen/dotfiles/dotfiles-global-store/etc/docker/daemon.json", link: nolink)
	-> /etc/docker/daemon.json

hemen@hemen-XPS-13-9370:~/Downloads$ 
```

 - I connect to git and see that the new file is detected as untracked and that `config-global.yaml` is updated. I commit the changes. **Note** as a convention, I plan to tag each global dotfile commit with the `[gloabl]` tag.

 - After the commit the file strcuture is as below

 ```
hemen@hemen-XPS-13-9370:~/dotfiles$ tree
.
├── config-global.yaml
├── config.yaml
├── dotfiles-global-store
│   └── etc
│       └── docker
│           └── daemon.json
├── dotfiles-store
│   ├── bash_aliases
│   ├── bash_envvars
│   ├── bash_functions
│   ├── bash_logout
│   ├── bashrc
│   ├── gitconfig
│   ├── install_script.sh
│   └── profile
└── README.md

4 directories, 12 files
hemen@hemen-XPS-13-9370:~/dotfiles$ 
 ```

Setup on another machine
------------------------

Next we proceed to configure dotdrop on the home machine. Unfortunately the home machine already has considerable configuration files already so we will start selectively adding them.

- Once git is configured we `git clone git@github.com:hemenkapadia/dotfiles.git` in $HOME
  - In case you are in a situation where git clone is not working then first start the ssh-agent as below and then add the private github key to the agent
  ```
  eval `ssh-agent -s`
  ssh-add .ssh/github/id_rsa
  ```
  - Once that is done, git clone should work. Then you can cd to the `dotfiles/dotfiles-store` directory and then run the install script directly from there to get the needed software installed.
- Use the install_script in the dotfiles-store folder to install dotdrop
- Update `$PATH`  `export PATH=${PATH}:${HOME}/.local/bin` this will cause `dotdrop` to be in `$PATH`
- Next export the below environment variables. Note that here we create a new profile `homelaptop`
  - `export DOTDROP_PROFILE=homelaptop`
  - `export DOTDROP_CONFIG=$HOME/dotfiles/config.yaml`

**NOTE** origiinally I was following the above approach but when the DOTDROP_PROFILE is set from the bash_envvars it cannot have the value of the profile in it as when we checkout the code and install that file on another system, it also starts using the profile. To overcome this issue I 
    - created a file `dotdrop_profile` in `$HOME/dotfiles` directory
    - added that file to .gitignore so that it is not tracked in git
    - updated the content of the file to that of the profile. example `echo worklaptop > $HOME/dotfiles/dotdrop_profile`
    - updated `bash_envvars` to check for the presence of the file and load `DOTDROP_PROFILE` based on the content of the file.
    - Thus the profile value does not come of any of the files that are tracked in dotdrop.

- Once done use the `dotdrop list` command to see if it can detect the other profiles in the config

```
 hemen  ~  export DOTDROP_PROFILE=homelaptop
 hemen  ~  export DOTDROP_CONFIG=$HOME/dotfiles/config.yaml
 hemen  ~  dotdrop list
Available profile(s):
	-> key:"worklaptop"
 hemen  ~  dotdrop compare
[WARN] no dotfile defined for this profile ("homelaptop") 

```
- To keep things simple I first add a single file to dotdrop for the `homelaptop` profile. Add the below contents to `profiles` section of `config.yaml`. I picak a simple file that does not need any templating or variable substitution. Once we are comfortable with the simple process we will incorporate these concepts too.

```
  homelaptop:
    dotfiles:
    - f_gitconfig
```
- I also make the `global-dotdrop` aware about the `homelaptop` profile by adding the following lines in `config-global.yaml`

```
  homelaptop:
    dotfiles:
```
- On comparing the only tracked files `~/.gitconfig` we notice that it has the below differences. On my home laptop I seem to have additional configuration for external pagers etc. which I no longer need. 

```
 hemen   master  ~/dotfiles  127  dotdrop compare
=> compare f_gitconfig: diffing with "/home/hemen/.gitconfig"
2,3c2,26
< 	name = Hemen Kapadia
< 	email = hemen.kapadia@gmail.com
---
>   email = hemen.kapadia@gmail.com
>   name = Hemen Kapadia
> 
> [merge]
> 	keepBackup = false;
>   tool = p4merge
> [mergetool]
>   prompt = false
> [mergetool "p4merge"]
>   cmd = p4merge "$BASE" "$LOCAL" "$REMOTE" "$MERGED"
>   keepTemporaries = false
>   trustExitCode = false
>   keepBackup = false
> 
> [diff]
>   tool = p4merge
> [difftool]
>   prompt = false
> [difftool "p4merge"]
>   cmd = p4merge "$LOCAL" "$REMOTE"
>   keepTemporaries = false
>   trustExitCode = false
>   keepBackup = false
> [core]
> 	autocrlf = input
```

- I go ahead and edit the `/.gitconfig` file to rmove the configuration that we no longer need. The file now looks like

```
 hemen   master  ~/dotfiles  1  dotdrop compare
=> compare f_gitconfig: diffing with "/home/hemen/.gitconfig"
2,3c2,6
< 	name = Hemen Kapadia
< 	email = hemen.kapadia@gmail.com
---
>   name = Hemen Kapadia
>   email = hemen.kapadia@gmail.com
> 
> [core]
>   autocrlf = input
```

- Next we do a `dotdrop update` and add the files to the repo

```
 hemen   master  ~/dotfiles  1  dotdrop update
Update all dotfiles for profile "homelaptop" [y/N] ? y
Overwrite "/home/hemen/dotfiles/dotfiles-store/gitconfig" with "/home/hemen/.gitconfig"? [y/N] ? y
	-> "/home/hemen/dotfiles/dotfiles-store/gitconfig" updated
```
- Once that is done we commit to git.
- Next we add the install_script.sh  files key to the profile, so that we can manage the file on both environments
```
  homelaptop:
    dotfiles:
    - f_gitconfig
    - f_install_script.sh
```
- List files managed in the profile. The compare command indicates that this file is not yet available on my home directory on the home laptop.
```
 hemen  ~  dotdrop listfiles
Dotfile(s) for profile "homelaptop"
f_gitconfig (src: "/home/hemen/dotfiles/dotfiles-store/gitconfig", link: nolink)
	-> /home/hemen/.gitconfig
f_install_script.sh (src: "/home/hemen/dotfiles/dotfiles-store/install_script.sh", link: nolink)
	-> /home/hemen/install_script.sh
    
hemen  ~  dotdrop compare
=> compare f_install_script.sh: "/home/hemen/install_script.sh" does not exist on local
```

- Let's get the file locally. After the below command the file was available locally in my $HOME

```
 hemen  ~  dotdrop install f_install_script.sh
	-> copied /home/hemen/dotfiles/dotfiles-store/install_script.sh to /home/hemen/install_script.sh

1 dotfile(s) installed.
```
- Next I updated the config.yaml file to include all the files there were in the worklaptop profile so that I can compare and make template based changes
- Then I compared and installed the files that could be easily installed.

```
 hemen   master  ~/dotfiles  dotdrop compare
=> compare f_profile: diffing with "/home/hemen/.profile"
23,27d22
< 
< # set PATH so it includes user's private bin if it exists
< if [ -d "$HOME/.local/bin" ] ; then
<     PATH="$HOME/.local/bin:$PATH"
< fi
=> compare f_vimrc: diffing with "/home/hemen/.vimrc"
1d0
< " Remap keys for a more ergonomic hand placement on the keyboard
6,7d4
< 
< " Powerline setup
 hemen   master  ~/dotfiles  1  dotdrop install f_profile
Overwrite "/home/hemen/.profile" [y/N] ? y
backup /home/hemen/.profile to /home/hemen/.profile.dotdropbak
	-> copied /home/hemen/dotfiles/dotfiles-store/profile to /home/hemen/.profile

1 dotfile(s) installed.
 hemen   master  ~/dotfiles  dotdrop compare
=> compare f_vimrc: diffing with "/home/hemen/.vimrc"
1d0
< " Remap keys for a more ergonomic hand placement on the keyboard
6,7d4
< 
< " Powerline setup
 hemen   master  ~/dotfiles  1  dotdrop install f_vimrc
Overwrite "/home/hemen/.vimrc" [y/N] ? y
backup /home/hemen/.vimrc to /home/hemen/.vimrc.dotdropbak
	-> copied /home/hemen/dotfiles/dotfiles-store/vimrc to /home/hemen/.vimrc

1 dotfile(s) installed.
 hemen   master  ~/dotfiles  dotdrop compare
 hemen   master  ~/dotfiles  
```

- Now i started handling the ~/.bash files ..the .bashrc and others I had created. Since the newly created ones were not present on my home laptop I installed them without any tmplating. I did not install `.bashrc` as yet...

- Anyway after following the above process to `install (repo -> file system)` and `update (file system changes -> repo) I ended up with multiple profiles and files being managed in the repo. We have three practical profiles inherting from `base` created solely for managing the hierarchy

```
hemen   master  ~/dotfiles  1  dotdrop detail
dotfiles details for profile "worklaptop":
f_gitconfig (dst: "/home/hemen/.gitconfig", link: nolink)
	-> /home/hemen/dotfiles/dotfiles-store/gitconfig (template:no)
f_bashrc (dst: "/home/hemen/.bashrc", link: nolink)
	-> /home/hemen/dotfiles/dotfiles-store/bashrc (template:yes)
f_bash_envvars (dst: "/home/hemen/.bash_envvars", link: nolink)
	-> /home/hemen/dotfiles/dotfiles-store/bash_envvars (template:yes)
f_bash_aliases (dst: "/home/hemen/.bash_aliases", link: nolink)
	-> /home/hemen/dotfiles/dotfiles-store/bash_aliases (template:no)
f_bash_functions (dst: "/home/hemen/.bash_functions", link: nolink)
	-> /home/hemen/dotfiles/dotfiles-store/bash_functions (template:no)
f_profile (dst: "/home/hemen/.profile", link: nolink)
	-> /home/hemen/dotfiles/dotfiles-store/profile (template:no)
f_bash_logout (dst: "/home/hemen/.bash_logout", link: nolink)
	-> /home/hemen/dotfiles/dotfiles-store/bash_logout (template:no)
f_install_script.sh (dst: "/home/hemen/install_script.sh", link: nolink)
	-> /home/hemen/dotfiles/dotfiles-store/install_script.sh (template:no)
f_vimrc (dst: "/home/hemen/.vimrc", link: nolink)
	-> /home/hemen/dotfiles/dotfiles-store/vimrc (template:no)
f_ideavimrc (dst: "/home/hemen/.ideavimrc", link: nolink)
	-> /home/hemen/dotfiles/dotfiles-store/ideavimrc (template:no)
f_vim_colors_solarized.vim (dst: "/home/hemen/.vim/colors/solarized.vim", link: nolink)
	-> /home/hemen/dotfiles/dotfiles-store/vim/colors/solarized.vim (template:no)
f_dotdrop_tester.sh (dst: "/home/hemen/dotdrop_tester.sh", link: nolink)
	-> /home/hemen/dotfiles/dotfiles-store/dotdrop_tester.sh (template:no)

 hemen   master  ~/dotfiles  dotdrop list
Available profile(s):
	-> key:"base"
	-> key:"worklaptop"
	-> key:"workremote"
	-> key:"homelaptop"

 hemen   master  ~/dotfiles  

```

Eventually after some changes there reached a point where templating is inevitable.

Templating
----------

dotdrop supports very powerful templating constructus. https://github.com/deadc0de6/dotdrop/wiki/templating.
If you look at the above output of `dotdrop detail` command, for each file it lists if it is a template or not.

For now i am starting with the simplest form of templating where a certain line(s) will make it to the file system file based on the profile value. Consider the file `~/.bash_envvars` where we update `$PATH` value based on the profile.

```shell
 hemen  ~  1  tail -n 10 dotfiles/dotfiles-store/bash_envvars 
export N_PREFIX="$HOME/n"; [[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH+=":$N_PREFIX/bin"  

# PATH environment variable. Keep this the last one in this file
export PATH="${PATH}:${HOME}/.local/bin"
{%@@ if profile == "worklaptop" @@%}
export PATH="$HOME/miniconda3/bin:$PATH"
{%@@ elif profile == "homelaptop" @@%}
export PATH="/opt/anaconda3/bin:$PATH"
{%@@ endif @@%}

```

The most important thing to note in case of templating is that the `install` and `update` workflow we have above for non template files does not work when the files are templated. As you can see the `.bash_envvars` file on the file system was updated to add golang bin dir to `$PATH`. Per our normal process above we would use `dotdrop compare` to ensure the files differ as expected, then use `dotdrop update ~/.bash_envvars` to update dotfile to the latest change. Once done, we commit to git.

However, as you can see below while `dotdrop install` (repo > FS) would work for such a file, but `dotdrop update` reports that the file will need to be updated (FS > repo). In such a situaion we need to chnage the process we follow to update te file in the repo. 


```shell
 hemen  ~  127  dotdrop compare --file=/home/hemen/.bash_envvars
=> compare f_bash_envvars: diffing with "/home/hemen/.bash_envvars"
20c20
< 
---
> export PATH="/usr/local/go/bin:$PATH"
 hemen  ~  1  dotdrop install f_bash_envvars
Overwrite "/home/hemen/.bash_envvars" [y/N] ? n
[WARN] ignoring /home/hemen/.bash_envvars 

0 dotfile(s) installed.
 hemen  ~  dotdrop install -d  f_bash_envvars
[DRY] would install /home/hemen/.bash_envvars 

1 dotfile(s) installed.
 hemen  ~  dotdrop update -d  .bash_envvars
[WARN] /home/hemen/dotfiles/dotfiles-store/bash_envvars uses template, update manually 
 hemen  ~  1  
 ```
 
 We will follow the below process to manage all our changes, irrespective if it is templated or not
 
 1. File System files should never be edited manually.
 2. To update managed files, we will updated the dotfiles stored in the `dotfiles-store` directory i.e. in the repo only.
 3. Then use `dotdrop compare` to check if the intended changes are the basis of difference
 4. Once verified, use `dotdrop install` to get the latest changes from the repo to file system
 5. Verify that the chnages are as expected.
 6. Commit the changes in the git repo and publish to remote if needed
 
 
 