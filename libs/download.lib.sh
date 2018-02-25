function wget_and_checksum(){
	local url=$1
	local md5=$2
	local algo=$3
	local fname=$(basename $url)
	wget $url
	local fmd5=""
	if [ "$algo" == "" ] || [ "$algo" == "md5" ] ; then
		fmd5=$(md5sum $fname | cut -d' ' -f1)
	elif [ "$algo" == "md5" ] ; then
		fmd5=$(shasum $fname | cut -d' ' -f1)
	fi
	if [ "$md5" != "$fmd5" ] ; then 
		echo "Md5 did not match: requested Md5=$md5 calculatedMd5=$fmd5"
		return 1
	fi
	return 0
}