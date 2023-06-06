. $(gbl ssh)

gblcmd_ssh_tunnel_list(){
    ssh_tunnel list
}

gblcmd_ssh_tunnel_stop(){
    ssh_tunnel stop $@
}

gblcmd_ssh_tunnel_start(){
    ssh_tunnel start $@
}