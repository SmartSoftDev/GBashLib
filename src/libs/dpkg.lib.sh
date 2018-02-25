
#. $G_BASH_LIB/libs/ubuntu.dpkg.bsh

function dpkg_get_installed_version(){
	# gets applicaiton version in APP_VERSION variable
	local app=$1
	APP_VERSION=$(dpkg --list |grep $app |tr -s ' '| cut -d' ' -f3)
}

function dpkg_check_installed(){
	# gets a list of application name and if all are installed returns 0 otherwise return 1
	while [ "$1" != "" ] ; do
		APP_VERSION=""
		dpkg_get_installed_version $1
		#echo "$1 -> $APP_VERSION"
		if [ "$APP_VERSION" == "" ] ; then
			return 1
		fi
		shift
	done
	return 0
}

function ppa_is_installed(){
	local ppa="$1"
	if ! grep -q "^deb .*$ppa" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
    	return 0
	fi
	return 1
}

function ppa_install_if_missing(){
	local ppa="$1"
	ppa_is_installed $ppa || sudo add-apt-repository $ppa
}