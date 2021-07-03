
gblcmd_descr_sudo_disable_password='Disables the sudo password for this user'
gblcmd_sudo_disable_password(){
    sudo tpl -i $(gbl tpl sudoers) -ro /etc/sudoers -v "USER=$USER"
}

gblcmd_descr_sudo_enable_password='Disables the sudo password for this user'
gblcmd_sudo_enable_password(){
    sudo tpl -i $(gbl tpl sudoers) -dro /etc/sudoers -v "USER=$USER"
}
