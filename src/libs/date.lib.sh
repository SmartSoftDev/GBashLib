
function epoch_to_str(){
	local epoch="$1"
	local format="$2"
	date -d @$epoch +$format
}


