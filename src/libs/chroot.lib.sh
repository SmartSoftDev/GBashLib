function do_chroot(){
    local MP=$1
    shift
    echo "chroot $MP $@ "
    mountpoint -q $MP/proc || mount -o bind /proc $MP/proc
    mountpoint -q $MP/dev || mount -o bind /dev $MP/dev
    mountpoint -q $MP/sys || mount -o bind /sys $MP/sys
    mountpoint -q $MP/tmp || mount -o bind /tmp $MP/tmp
    set +e
    chroot $MP $@
    set -e
    mountpoint -q $MP/proc && umount $MP/proc
    mountpoint -q $MP/dev && umount $MP/dev
    mountpoint -q $MP/sys && umount $MP/sys
    mountpoint -q $MP/tmp && umount $MP/tmp

}