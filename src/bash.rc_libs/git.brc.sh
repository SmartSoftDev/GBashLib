
function git_branch(){
    if [ "$1" == "" ] ; then
        git branch -vv --all
    else
        git branch -vv --all | grep $1
    fi
}


alias g='git'
alias gg='git grep -n'
alias gs='git st'
alias gd='git diff'
alias gl="git log --pretty=format:'%C(dim)%h%Creset  %C(green)%s%Creset %C(yellow)<%an>%Creset %C(dim)%cr%Creset %C(blue)%D%Creset' --name-only"
alias gdt='git difftool -d origin/dev .'
alias ga='git add'
alias b='git_branch'
alias push='git push'
alias pull='git pull -p'

source /usr/share/bash-completion/completions/git

fn_exists() {
    for fn_name in $@ ; do 
        if ! type $fn_name >/dev/null 2>&1 ; then
            return 1
        fi
    done
    return 0
}

if fn_exists complete ; then
    if fn_exists __git_complete __git_main ; then
        # ubuntu 22.04
        __git_complete g __git_main
    else
        # older versions
        complete -o bashdefault -o default -o nospace -F _git g 2>/dev/null \
                || complete -o default -o nospace -F _git g
    fi
fi