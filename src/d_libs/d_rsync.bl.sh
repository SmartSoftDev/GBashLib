
gblcmd_descr_rsync_dir=('Rsync a directory with progress and summary' "SRC [DST]")
gblcmd_rsync_dir(){
    local src="$1"
    local dst="$2"
    if [ "$dst" == "" ] ; then
        dst="."
    fi
    rsync -iPavzh "$src" "$dst"
}