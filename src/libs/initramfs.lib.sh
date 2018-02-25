
function irfs_extract(){

	local F=$1 #initramfs file
	local where=$2
	cp "$F" ifs.gz
	gunzip ifs.gz
	mkdir -p $where
	cd $where
	rm -rf *
	cpio -vid < ../ifs
	cd ../
	rm ifs
}

function irfs_create(){
	local F="$1" #destination initramfs
	local where=$2
	cd $where
	find . | cpio --create --format='newc' > ../fs.cpio
	cd ../
	gzip fs.cpio
	mv fs.cpio.gz $F
}
