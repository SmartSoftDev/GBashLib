function is_file_gzipped(){
    local fpath="$1"
    if file -b -i "$fpath" | grep gzip >/dev/null 2>&1 ; then
        return 0
    else
        return 1
    fi
}