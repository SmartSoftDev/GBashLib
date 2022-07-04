# systemd shortcuts
alias sc='sudo systemctl'
alias scst='systemctl status'
alias scstart='sudo systemctl start'
alias scstop='sudo systemctl stop'
alias screstart='sudo systemctl restart'
alias jc='journalctl'



function sd_usage(){
    echo "systed (sd) command usage:"
    echo "Commands:"
    echo -e "\tr    - restart"
    echo -e "\ts    - start"
    echo -e "\tS    - stop"
    echo -e "\tl    - logs (at the end)"
    echo -e "\tL    - logs (follow)"
    echo -e "\nServices:"
    for s in $(v list -t systemd -n)
    do
        echo -e "\t$s    - $(v get -t systemd $s)"
    done
}
function sd(){
    local cmd="$1"
    local run=""
    case $cmd in
        "r")
            run="sudo systemctl restart"
        ;;
        "s")
            run="sudo systemctl start"
        ;;
        "S")
            run="sudo systemctl stop"
        ;;
        "l")
            run="journalctl -eu"
        ;;
        "L")
            run="journalctl -feu"
        ;;
        *)
            sd_usage
            return
        ;;
    esac
    local service=""
    for s in $(v get -t systemd -s "$2") ; do
        if [ "$service" != "" ] ; then
            echo "Ambiguous service for '$2' :"
            for s in $(v get -t systemd -s "$2") ; do
                echo -e "\t$2 -> $s"
            done
            return
        fi
        service="$s"
    done
    echo "$run $service"
    $run "$service"
}