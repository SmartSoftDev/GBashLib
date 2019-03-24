

_UIDGEN_VALUE_ID=""
_UIDGEN_NEW_HASH=""
_UIDGEN_OLD_VALUE=""

function _uidgen_compute_values(){
    local uidgen_id=uidgen_check_if_files_changed
	#first compute the ID of the files
	uidgen -s $uidgen_id create
	for i in $@ ; do 
		uidgen -s $uidgen_id add $i
	done
	_UIDGEN_VALUE_ID=$(uidgen $uidgen_id get -l 10)
	uidgen -s $uidgen_id create
	for i in $@ ; do 
		uidgen -s $uidgen_id add -f $i
	done
	_UIDGEN_NEW_HASH=$(uidgen $uidgen_id get -l 10)
	_UIDGEN_OLD_VALUE=$(v get -t uidgen_check_changes ${_UIDGEN_VALUE_ID})
}

uidgen_check_if_files_changed_descr="computes md5 of the files (from arguments) and check the value with the saved one. \
if match returns false (means no changes were detected)); no match returns true "
function uidgen_check_if_files_changed(){
    _uidgen_compute_values $@

	if [ "$_UIDGEN_NEW_HASH" == "$_UIDGEN_OLD_VALUE" ] ; then
        return 0
    else
        return 1
    fi
}

uidgen_save_files_changed_descr="saves the current file hashes to v"
function uidgen_save_files_changed(){
    _uidgen_compute_values $@
    v set -t uidgen_check_changes ${_UIDGEN_VALUE_ID}=${_UIDGEN_NEW_HASH}
}