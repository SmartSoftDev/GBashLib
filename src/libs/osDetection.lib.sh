function __processOsDetection(){
	OSNAME="${OSNAME,,}"
	OSVERSION="${OSVERSION,,}"
	OSVERSION_MAJOR="${OSVERSION%%.*}"
	OSVERSION_MINOR="${OSVERSION##*.}"
	OSID="${OSNAME}_$OSVERSION"
	if [ "$OSVERSION_MAJOR" != "" ] ; then
		OSID_MAJOR="${OSNAME}_${OSVERSION_MAJOR}"
	else
		OSID_MAJOR=""
	fi
}

function osDetection(){
	[ "$OSID" != "" ] && [ "$OSNAME" != "" ] && return 0
	if [ -f /etc/lsb-release ] ; then
		OSNAME=$(. /etc/lsb-release; echo $DISTRIB_ID)
		OSVERSION=$(. /etc/lsb-release; echo $DISTRIB_RELEASE)
		OSDESCRIPTION=$(. /etc/lsb-release; echo $DISTRIB_DESCRIPTION)
		__processOsDetection
		return 0
	fi
}

function run_when_os_is(){
	osDetection
	local req_os="$1"
	shift
	[ "$req_os" != "$OSID" ] && [ "$req_os" != "$OSNAME" ] && return 0
	$@
}

# receives a list of os_ids that are processed in or
function is_os(){
	osDetection
	for req_os in  $@ ; do
		[ "$req_os" == "$OSID" ] && return 0
		[ "$req_os" == "$OSNAME" ] && return 0
		[ "$req_os" == "$OSID_MAJOR" ] && return 0
	done
	return 1 # did not match any input
}
function osPrint(){
	osDetection
	echo "OSNAME=${OSNAME}"
	echo "OSVERSION=${OSVERSION}"
	echo "OSVERSION_MAJOR=${OSVERSION_MAJOR}"
	echo "OSVERSION_MINOR=${OSVERSION_MINOR}"
	echo "OSID=${OSID}"
	echo "OSID_MAJOR=${OSID_MAJOR}"
}