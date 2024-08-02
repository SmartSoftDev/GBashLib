function ub_gen_installed_packages(){
    local dst="$1"
    packages=`dpkg --get-selections | awk '{ print $1 }'`
    for package in $packages; do 
        echo "$package: "; cat /usr/share/doc/$package/copyright; echo ""; echo ""; 
    done > ~/licenses.txt
}