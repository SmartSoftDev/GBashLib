# Introduction

GBashLib is a bunch of scripts that helps you to write less and do more in the terminals with BASH shell but keeping it super human friendly.

It provides few shortcuts:

- `j` - for jumping to saved paths
- `s` - run ssh to saved destinations.
- `d` - running bash functions as commands. Basically replaces `make` targets with simple BASH functions.
- `r` - is the same as `d` but globally available from any directory and uses $HOME/d.bl.sh file. 


# How to install

- go to the directory where you want to keep the code
- clone the code `git clone https://github.com/SmartSoftDev/GBashLib.git`
- run `$./GBashLib/src/scripts/install.sh`

# How to use it

## `j` - fast jump to your paths

Before you can jump to your preferred paths you have to save them with `j set` command like this:

- `$ j set alias1 .` to add alias1 as jump to current directory or `j set alias2 /home/myUser/git/`.

then you can jump to any of this locations:

- `$ j alias1`

`j` has intelligent autocomplete and selection feature. For ex: you can write an unique string which is part of your alias
and `j` will autocomplete but also will select it atomatically.

- `$ j 1` is equal with `$ j alias1` because "1" is unique for our example of 2 aliases ("alias1" and "alias2").

## `s` - ssh to your hosts with one letter and intelligent autocomplete

Before you can ssh to your preferred host you have to add it to `s` like this:

- `$ s set  ALIAS1 user@ip:port/template` - only IP is mandatory for this command. 
- `s` command adds an entry in $HOME/.ssh/config file and uses `$G_BASH_LIB/tpls/ssh_host.tpl` template for that.
- But when the `template` argument is given then the used template for that entry is `$HOME/.ssh/ssh_host_${template}.tpl`. 
This is useful if you have to configure ssh differently for different types of hosts.
- When you set a new alias the `s` command will copy your keys (using ssh-copy-id command) to that host, that you are not prompted for password anymore.
This can be skipped with `$ s set --skip-keys ALIAS...`.

## `d` - define and run commands in a very human friendly way

- `d` command always looks for `d.bl.sh` file inside current directory.
- any bash function that starts with `gbl_` will be taken as a command.
 