function git_branch(){
	local dir="$1" branch
	cd "$dir" || return 1
	branch="$(git symbolic-ref HEAD 2>/dev/null || echo "DETACHED")"     # detached HEAD
	branch="${branch##refs/heads/}"
	echo "$branch"
}
function git_cmd(){
	local dir="$2" branch
	cd "$dir" || return 1
	branch=$(git_branch "$dir")
	gbl_log "git $1: $COLOR_GREEN $dir $COLOR_NONE@$branch"
	git "$1"
}

function git_repo_hash(){
	local short="$1" commit
	if [ "$short"  != "" ] ; then
		commit=$(git log -n 1 --format="%H")
		echo "${commit:0:$short}"
	else
    	git log -n 1 --format="%H"
	fi
}

function git_dir_hash()
{
    git log -n 1 --format="%H" -- .
}

function git_commit_ts()
{
	local commit="$1"
	git show -s --format="%ct" "$commit"
}
