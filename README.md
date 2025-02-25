# Introduction

GBashLib (GBL) is a bunch of scripts that helps you to write less and do more in the terminals with BASH shell but keeping it super human friendly.

It provides several nice features:

- `j` - for jumping to saved paths
- `d` - running bash functions as commands. Basically replaces `make` targets with simple BASH functions.
- `r` - is the same as `d` but globally available from any directory and uses $HOME/d.bl.sh file.
- `s` - run ssh to saved destinations.
- `c` - manage multiple serial console connections and configurations.
- `v` - used to save kye=value pairs in yaml file, which then can be used in any other script (bash, ) or application.
- `g` - alias for git command with all auto completes
- `tpl` - simple templating on key=values, used for simple scripting / generation of configuration files
- `uidgen` - a simple CLI tool to generate hashed UIDS of files or text, in order to detect changes.

GBL provides several tools to manage what features should be included in configuration files from Home directory, like:
- `mng_bashrc` - will manage features/files included in ~/.bashrc
  - console - provides `c` shortcut to manage serial console commands
  - find - provides shortcuts to find files and directories: `ff` and `fd` shortcuts.
  - git - provides `g` shortcut (alias with git) with autocomplete
  - git_prompt - setups the PS1 to include the branch name and the repo status
  - jump - provides the `j` shortcut for jump
  - python - provides shortcuts for python: `bp` (bpython), `pytest`, `pyclean`
  - qt_screen_factor - implements the workaround for QT apps to scale on various monitors.
  - ssh - provides `s` shortcut
  - systemd
  - terminal
- `mng_inputrc` - will manage features/files included in ~/.inputrc
  - up_down_search - setups that reverse and forward search should happen when user presses up/down keys
  - useful - setups some useful inputrc settings, like how to show autocomplete suggestions.
- `mng_gitconfig` - will manage features/files included in ~/.gitconfig
  - alias - adds some short aliases for commands like `co` for checkout, `d` for diff, `l` for log, etc.
  - http_credentials - enables store credentials for http.
  - push_pull - configures push to simple and pull to rebase strategy.

# How to install

- go to the directory where you want to keep the code
- clone the code `git clone https://github.com/SmartSoftDev/GBashLib.git`
- run `$./GBashLib/src/scripts/install_all_goodies.sh`

Alternatively you could run which will install GBashLib and all recommended mng _bashrc,_inputrc and _gitconfig
```
wget -O - https://raw.githubusercontent.com/SmartSoftDev/GBashLib/master/src/scripts/install_all_goodies.sh | bash
```

# How to use it

## `j` - fast jump to your paths

Before you can jump to your preferred paths you have to save them with `j set` command like this:

- `$ j set alias1 .` to add alias1 as jump to current directory or `j set alias2 /home/myUser/git/`.

then you can jump to any of these locations:

- `$ j alias1`

`j` has intelligent autocomplete and selection feature. For ex: you can write a unique string which is part of your alias
and `j` will autocomplete but also will select it automatically.

- `$ j 1` is equal with `$ j alias1` because "1" is unique for our example of 2 aliases ("alias1" and "alias2").

## `s` - ssh to your hosts with one letter and intelligent autocomplete

Before you can ssh to your preferred host you have to add it to `s` like this:

- `$ s set ALIAS1 user@ip:port` - only IP is mandatory for this command.
- `s` command adds an entry in $HOME/.ssh/config file and uses `$G_BASH_LIB/tpls/ssh_host.tpl` template for that.
- When you set a new alias the `s` command will copy your keys (using ssh-copy-id command) to that host, that you are not prompted for password anymore. This can be skipped with `$ s set --skip-keys ALIAS...`.

- But when the `--template path/to/template.tpl` argument is given then it will be used. This is useful if you have to
  configure ssh differently for different types of hosts.
- `s` supports proxyJump option like `s set --ProxyJump proxyHostAlias my_alias root@192.168.1.1`
- `s` supports waiting for the Alias to come online when trying to connect to SSH: `s --wait my_alias`

## `c` - serial console with one letter and intelligent autocomplete

This is calling different serial console setups. It is very usefully when you have multiple USB to Serial adapters. The best practice is to give them a specific name based on serial number using udev like this:

```
$ cat /etc/udev/rules.d/90-serial.rules
SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", SYMLINK+="ttyUSB_rpi"
SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", SYMLINK+="ttyUSB_opi"
```

Then you can configure them as follows:
- `$ c set  ALIAS1 DEV_PATH@BAUDRATE` - when BAUDRATE is missing it defaults to 115200.
The `c` command uses `screen` serial console. And you can start the console using `c ALIAS1`.

## `d` - define and run commands in a very human friendly way

- `d` command always looks for `d.bl.sh` file inside current directory.
- any bash function that starts with `gbl_` will be taken as a command.

## `v` - store key=value configuration and use it from a single place

- Stores simple key=value pairs in yaml file, in HOME directory, or in current directory.
- Can print the values so that BASH takes them as variables.
- Stores in yaml file so it is easy to read from any program language (there is a python library that supports all v features).
- Key=values pairs can be grouped ("type" specifier in CLI).
- Supports GPG encryption using multiple GPG keys (for keeping secrets, passwords, etc.).

## `tpl` - simple key=value template for configuration generation

- It can generate entire files, or it can generate/replace/delete only a portion of files
- Can generate/replace multiple variables at once.
- Can generate/replace multiple instances of the same template in same file (based on instance ID).

## `uidgen` - hash generation of files or text

- transaction type generation (multiple CLI calls can be executed to add/del hashes)


