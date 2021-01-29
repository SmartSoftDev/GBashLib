
#. $G_BASH_LIB/libs/reqs.lib.bsh

SPHINXOPTS=-W
SPHINXBUILD=sphinx-build
SPHINX_DEFAULT_TARGET="singlehtml"

declare -a REQS  # initialing

function reqs_find(){
	local path='.'
	if [ "$1" != "" ] ; then
		path=$1
	fi
	REQS=$(find $path -name "0_req" -type d)
}

function reqs_build_one(){
	local path=$1
	local target=$SPHINX_DEFAULT_TARGET
	if [ "$2" != "" ] ; then
		target="$2"
	fi
	$SPHINXBUILD -M $target $path ${path}_build ${SPHINXOPTS}
}

function reqs_build_all(){
	local target=$SPHINX_DEFAULT_TARGET
	if [ "$1" != "" ] ; then
		target="$1"
	fi
	for path in ${REQS[@]} ; do
		reqs_build_one $path $target
	done
}

function reqs_build(){
	reqs_find
	reqs_build_all
}

function reqs_show_all_singlehtml(){
	local browser=$1
	reqs_find
	local browser_files=""
	for path in ${REQS[@]} ; do
		if [ ! -d ${path}_build ] ; then
			reqs_build_one $path $target
		fi
		browser_files="$browser_files ${path}_build/$SPHINX_DEFAULT_TARGET/index.html"
	done
	if [ "$browser" != "" ] ; then
		$browser $browser_files
	else
		for i in $browser_files ; do
			echo $(readlink -e $i)
		done
	fi
}
