
function rsync_dir(){
    local src="$1"
    local dst="$2"
    if [ "$dst" == "" ] ; then
        dst="."
    fi
    rsync -iPavzh "$src" "$dst"
}