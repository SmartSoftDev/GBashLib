
function loading_dots() {
    local load_interval="${1}"
    local loading_message="${2}"
    local elapsed=0
    local counter=0
    local loading_animation=( '.      ' '. .    ' '. . .  ' '. . . .')
    printf "${loading_message} "
    while [ "${load_interval}" -ne "${elapsed}" ]; do
        printf "%s" "${loading_animation[$(( counter%4 ))]}"
        sleep 0.5
        printf '\b\b\b\b\b\b\b'
        (( counter += 1))
        elapsed=$(( elapsed + 1 ))
    done
    (( counter += ${#loading_message} ))
    for ((i=1;i<=counter;i++));do
       printf "\b"
    done
}