gblcmd_docker_clean_dangling_images(){
    docker images -f "dangling=true"
}