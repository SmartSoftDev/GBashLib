
. $(gbl git)

gblcmd_descr_sync='run "git pull -p" on all configured repos in $(v list -vt git)'
gblcmd_sync(){
    for i in $(v list -vt git)
	do
        git_cmd "pull -p" $i
    done
}

gblcmd_descr_status='run "git shortlog -s origin/$branch..$branch" on all configured repos in $(v list -vt git)'
gblcmd_status(){
    for i in $(v list -vt git)
	do
        git_cmd 'status -s' $i
        local branch=$(git_branch $i)
        git_cmd "shortlog -s origin/$branch..$branch" $i
    done
}
