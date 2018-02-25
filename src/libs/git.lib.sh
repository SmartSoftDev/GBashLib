function git_branch(){
	local dir=$1
	cd $dir || return 1
	local branch="$(git symbolic-ref HEAD 2>/dev/null || echo "DETACHED")"     # detached HEAD
	branch=${branch##refs/heads/}
	echo $branch
}
function git_cmd(){
	local dir=$2
	cd $dir || return 1
	local branch=$(git_branch $dir)
	gbl_log "git $1: $COLOR_GREEN $dir $COLOR_NONE@$branch"
	git $1
}

function git_repo_hash(){
	local short="$1"
	if [ "$short"  != "" ] ; then
		local commit=$(git log -n 1 --format="%H")
		echo ${commit:0:$short}
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
	git show -s --format="%ct" $commit
}
