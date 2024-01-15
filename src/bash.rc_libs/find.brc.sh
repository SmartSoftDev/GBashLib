function ff_find(){
    #find file
	find . -type f -path "*$@*"
}

function fd_find(){
    # find directory
	find . -type d -name "*$@*"
}

function rgrep_all(){
    # run rgrep .
    rgrep "$@" .
}

alias rg='rgrep_all '
alias fd='fd_find '
alias ff='ff_find '

alias ll="ls -alFh"
