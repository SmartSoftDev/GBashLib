gblcmd_docker_clean_dangling_images(){
    docker images -f "dangling=true"
}

gblcmd_docker_system_usage(){
    docker system df
}