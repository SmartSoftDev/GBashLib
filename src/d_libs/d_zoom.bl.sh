gblcmd_zoom(){
    local url="$1"
    # example link: https://us02web.zoom.us/j/87XXX1XXX7?pwd=L1V4UXXXXXXXXXXXXXkRlRhdz09
    xdg-open "zoommtg://zoom.us/join?action=join&confno=$(echo $(basename $url) | tr '?' '&')"
}