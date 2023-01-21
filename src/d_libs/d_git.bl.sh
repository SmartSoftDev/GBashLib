. $(gbl git)

gblcmd_descr_git_sync='run "git pull -p" on all configured repos in $(v list -vt git)'
gblcmd_git_sync(){
    for i in $(v list -vt git)
    do
        git_cmd "pull -p" $i
    done
}

gblcmd_descr_git_status='run "git shortlog -s origin/$branch..$branch" on all configured repos in $(v list -vt git)'
gblcmd_git_status(){
    for i in $(v list -vt git)
    do
        git_cmd 'status -s' $i
        local branch=$(git_branch $i)
        git_cmd "shortlog -s origin/$branch..$branch" $i
    done
}


gblcmd_git_clean_local_only_branches(){
    set -e
    local main_branch="dev"
    [ ! -z "$1" ] && main_branch="$1"
    git remote prune origin
    echo "checkout the '$main_branch' branch"
    git checkout $main_branch
    set +e
    for i in $(git branch -vv | grep ': gone]' | awk '{print $1}'); do
        echo "deleting branch: $i"
        git branch -D $i
    done
}

