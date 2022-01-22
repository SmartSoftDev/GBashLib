. $(gbl log)
. $(gbl reqs)


gblcmd_descr_show_docs=("Shows the singlehtmls in browser (default chromium)", ["Browser CMD"])
gblcmd_show_doc(){
	local browser="chromium"
	[ "x$1" != "x" ] && browser="$1"
	reqs_show_all_singlehtml "$browser"
}

gblcmd_descr_doc="Builds Sphynx Documentation"
gblcmd_doc(){
	reqs_build_all || fatal "could not build the document"
}
