# this feature uses BASH > v4

declare -A PARALLEL_OUT_FILES
declare -A PARALLEL_NAME
declare -a PARALLEL_PIDS
PARALLEL_MAX_PIDS=
PARALLEL_AUTO_REMOVE_OUT_FILES=1

function wait_first_pid(){
    if [ "${#PARALLEL_PIDS[@]}" == 0 ] ; then
        echo "No pids found"
        return 1
    fi
    local pid=${PARALLEL_PIDS[0]}
    local name=${PARALLEL_NAME[$pid]}
    local out_file=${PARALLEL_OUT_FILES[$pid]}
    echo "wait pid=$pid $name"
    wait $pid
    local ret=$?
    if [ "$ret" != "0" ] ; then
        echo -e "$name failed with return code $ret pid=$pid"
        [ "$out_file" != "" ] && {
            echo "Output of pid=$pid $name"
            cat $out_file
        }
    fi
    [ "$PARALLEL_AUTO_REMOVE_OUT_FILES" != "" ] && {
        rm -f $out_file
    }
    unset PARALLEL_OUT_FILES[$pid]
    unset PARALLEL_NAME[$pid]
    PARALLEL_PIDS=(${PARALLEL_PIDS[@]:1})
    return $ret
}

function wait_all(){
    echo "wait all pids ${#PARALLEL_PIDS[@]}"
    local ret=0
    for i in $(seq ${#PARALLEL_PIDS[@]}) ; do
        wait_first_pid
        local wait_ret=$?
        [ "$wait_ret" != "0" ] && ret=$wait_ret
    done
    return $ret
}

function add_pid(){
    local pid="$1"
    PARALLEL_PIDS+=($pid)
    [ "$2" != "" ] && PARALLEL_OUT_FILES[$pid]="$2"
    [ "$3" != "" ] && PARALLEL_NAME[$pid]="$3"
    [ "$PARALLEL_MAX_PIDS" != "" ] && {
        if [ ${#PARALLEL_PIDS[@]} -gt $PARALLEL_MAX_PIDS ] ; then
            echo "PARALLEL_MAX_PIDS=$PARALLEL_MAX_PIDS reached, waiting for first pid"
            wait_first_pid
            return $?
        fi
    }
}
