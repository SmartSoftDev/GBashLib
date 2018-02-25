ADOC_REVISION=
ADOC_DATE=$(date '+%Y-%m-%d %H:%M')
DIR=$(pwd)

function build_one_asciidoc(){
    local adoc="$1"
    local otype="$2"
    local odir="$3"
    
	if [ "$otype" == "html" ] ; then
		otype='html5'
		asciidoc --theme=volnitsky -a toc2 -a revnumber="$ADOC_REVISION" -a revdate="$ADOC_DATE" -a source-highlighter=pygments \
    		-a data-uri -a icons -o "$odir/$adoc.html" -b $otype "$adoc"
		
	elif [ "$otype" == "pdf" ] ; then
		a2x --asciidoc-opts '--theme=volnitsky' -L -a toc2 -a revnumber="$ADOC_REVISION" -a revdate="$ADOC_DATE" -a source-highlighter=pygments \
    		-a data-uri -a icons -f pdf "$adoc" -D $odir
	fi
	
}