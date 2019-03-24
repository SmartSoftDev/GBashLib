function ftp_get_recend_modified_object(){
	[ -z "$1" ] && gbl_fatal "please provide ftp url!"
	curl $1 2>/dev/null | awk '{print $NF}' | sort -n | tail -1 
}
function ftp_get_entries(){
	[ -z "$1" ] && gbl_fatal "please provide ftp url!"
	curl $1 2>/dev/null | awk '{print $NF}'
}
