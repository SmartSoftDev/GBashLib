#!/bin/bash
. $(gbl log)
. $(gbl parallel)

bla1(){
    sleep 3
    log "bla1"
    return 0
}

bla2(){
    sleep 5
    log "bla2"
    exit 10
}
PARALLEL_MAX_PIDS=2

log_fpath=/tmp/$$_${#PARALLEL_PIDS[@]}.out
bla1 >$log_fpath 2>&1 &
add_pid $! log_fpath "bla1.1" || fatal "one of the tasks failed"

bla2 >/tmp/bla_2.out 2>&1 &
add_pid $! /tmp/bla_2.out || fatal "one of the tasks failed"

bla1 >/tmp/bla_3.out 2>&1 &
add_pid $! /tmp/bla_3.out || fatal "one of the tasks failed"

bla1 >/tmp/bla_4.out 2>&1 &
add_pid $! /tmp/bla_4.out || fatal "one of the tasks failed"


wait_all || fatal "could not finish the tasks"

