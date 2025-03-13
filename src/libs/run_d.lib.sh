function run_d(){
    local d_path="$1"
    shift
    echo -e "\n --- Run d from path=$d_path/d.bl.sh with cmd: d $@"
    cd $d_path || fatal "Could not find '$d_path'"
    d $@  || fatal "Could not run 'd $@' command in '$d_path'"
}