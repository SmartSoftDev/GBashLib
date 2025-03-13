. $(gbl log)

function nginx_install_service(){
    local service_name="$1"
    local tpl_path="$2"
    shift
    shift
    # all other arguments will be passed to -v of TPL command

    local NGINX_CFG="/etc/nginx/sites-available/gen.$service_name.cfg"
    log "generate nginx config: $NGINX_CFG"
    local v_cmd="-v"
    if [ "$#" -eq 0 ] ; then v_cmd="" ; fi

    #config nginx
    # global port redirection can be done by exporting PORT_80=XXX
    [ "x$PORT_80" == "x" ] && PORT_80=80
    [ "x$PORT_443" == "x" ] && PORT_443=443

    sudo tpl -i "$tpl_path" -o "$NGINX_CFG" "$v_cmd" \
        PORT_80="$PORT_80" \
        PORT_443="$PORT_443" \
        $@
    sudo ln -sf "$NGINX_CFG" "/etc/nginx/sites-enabled/"
    sudo nginx -t || fatal "NGINX configuration failed"
    sudo systemctl restart nginx.service
}

function nginx_uninstall_service(){
    for service_name in "$@" ; do
        sudo rm "/etc/nginx/sites-available/gen.$service_name.cfg"
        sudo rm "/etc/nginx/sites-enabled/gen.$service_name.cfg"
    done
}
