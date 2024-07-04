function ossl_get_server_certificate(){
	local url="$1"
	local save_to="$2"
	local port=443
	[ "$3" != "" ] && port="$3"
	
	( openssl s_client -showcerts -connect "$url":443 </dev/null 2>/dev/null | sed -n -e '/BEGIN\ CERTIFICATE/,/END\ CERTIFICATE/ p' ) > "$save_to"
}

function ossl_printCert(){
	local cert_p="$1"
	openssl x509 -noout -text -in "$cert_p"
	openssl x509 -noout -in "$cert_p" -fingerprint

}


function ossl_encrypt_file(){
	local src="$1"
	local dst="$2"
	openssl aes-256-cbc -a -salt -in $src -out $dst
}

function ossl_decrypt_file(){
	local src="$1"
	local dst="$2"
	openssl aes-256-cbc -d -a -in "$src" -out "$dst"
}

