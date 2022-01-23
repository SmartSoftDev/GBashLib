# This library finds and builds sphynx documents
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
    local path="$1"
    local target="$SPHINX_DEFAULT_TARGET"
    if [ "$2" != "" ] ; then
        target="$2"
    fi
    local this_dir="$( dirname "${BASH_SOURCE[0]}" )"
    local puml_exec="$(readlink -e "$this_dir/../../tools/plantuml.jar")"
    echo "Start building document $path"
    for pfile in $(find -L $path -name "*.puml" -type f) ; do
        if [ "$pfile" -nt "$pfile.png" ] ;then
            java -jar "$puml_exec" "$pfile" || { echo "failed to convert PUML to PNG: '$pfile'" ; return 1 ; }
            mv "${pfile:0:(-5)}.png" "$pfile.png"
            echo "Converted puml file: $pfile.png"
        else
            echo "$pfile.png already up to date"
        fi
    done
    $SPHINXBUILD -M "$target" "$path" "${path}_build" "${SPHINXOPTS}"
}

function reqs_build(){
    local target=$SPHINX_DEFAULT_TARGET
    if [ "$1" != "" ] ; then
        target="$1"
    fi
    for path in ${REQS[@]} ; do
        reqs_build_one $path $target || return 1
    done
}

function reqs_build_all(){
    reqs_find || return 1
    reqs_build || return 1
}

function reqs_show_all_singlehtml(){
    local browser=$1
    reqs_find
    local browser_files=""
    for path in ${REQS[@]} ; do
        if [ ! -d "${path}_build" ] ; then
            reqs_build_one "$path" "$target"
        fi
        browser_files="$browser_files ${path}_build/$SPHINX_DEFAULT_TARGET/index.html"
    done
    if [ "$browser" != "" ] ; then
        $browser $browser_files >/dev/null 2>&1 &
    else
        for i in $browser_files ; do
            echo $(readlink -e "$i")
        done
    fi
}

function reqs_install_dependencies(){
    sudo -H pip3 install --upgrade --quiet Sphinx recommonmark sphinx-rtd-theme
    sudo apt install graphviz
}

