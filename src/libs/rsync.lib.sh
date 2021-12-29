
function rsync_dir(){
    local src="$1"
    local dst="$2"
    if [ "$dst" == "" ] ; then
        dst="."
    fi
    echo -e "Rsync $src to $dst"
    rsync -iPavzh "$src" "$dst"
}