gblcmd_zoom_url(){
    local url="$1"
    # example link: https://us02web.zoom.us/j/87XXX1XXX7?pwd=L1V4UXXXXXXXXXXXXXkRlRhdz09
    xdg-open "zoommtg://zoom.us/join?action=join&confno=$(echo $(basename $url) | tr '?' '&')"
}

gblcmd_zoom(){
    local zoom_name="$1"
    local zoom_url=$(v get --search -t zoom $zoom_name )
    [ "$zoom_url" == "" ] && fatal "Could not find zoom_name=$zoom_name"
    local zoom_url_array=( $zoom_url )
    [ ${#zoom_url_array[@]} -gt 1 ] && {
        echo "FATAL: Ambigous zoome_name=$zoom_name"
        v list -t zoom -n | grep "$zoom_name"
        exit 1
    }

    # example link: https://us02web.zoom.us/j/87XXX1XXX7?pwd=L1V4UXXXXXXXXXXXXXkRlRhdz09
    xdg-open "zoommtg://zoom.us/join?action=join&confno=$(echo $(basename $zoom_url) | tr '?' '&')"
}
