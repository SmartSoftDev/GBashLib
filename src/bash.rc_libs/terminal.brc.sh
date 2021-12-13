
title(){
	local title=$1
	PROMPT_COMMAND='echo -ne "\033]0;'$title'\007"'
}
