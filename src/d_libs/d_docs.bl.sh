. $(gbl log)

SPHINX_DOCS_SH_LIB=sphinx_docs.lib.sh
SPHINX_DOCS_SH_LIB_LOCATION=

_find_sphinx_docs_sh_lib_location(){
    SPHINX_DOCS_SH_LIB_LOCATION=$(find . -name $SPHINX_DOCS_SH_LIB)
    if [ -z "$SPHINX_DOCS_SH_LIB_LOCATION" ] ; then
        # search conf.py
        for c_path in $(find . -name conf.py -type l) ; do
            local abs_path=$(dirname $(readlink -f $c_path))/$SPHINX_DOCS_SH_LIB
            echo "check: $c_path $abs_path"
            if [ -e $abs_path ] ; then
                SPHINX_DOCS_SH_LIB_LOCATION=$abs_path
                break
            fi
        done
    fi
}
gblcmd_descr_show_docs=("Shows the singlehtmls in browser (default chromium)", ["Browser CMD"])
gblcmd_show_doc(){
    _find_sphinx_docs_sh_lib_location
    [ -z "$SPHINX_DOCS_SH_LIB_LOCATION" ] && fatal "Could not find the Sphinx_docs tool"
    . $SPHINX_DOCS_SH_LIB_LOCATION
    docs_show_all_singlehtml
}

gblcmd_descr_doc="Builds Documentation using Sphinx_docs tool"
gblcmd_doc(){
    _find_sphinx_docs_sh_lib_location
    [ -z "$SPHINX_DOCS_SH_LIB_LOCATION" ] && fatal "Could not find the Sphinx_docs tool"
    . $SPHINX_DOCS_SH_LIB_LOCATION
    docs_build_all .
}
