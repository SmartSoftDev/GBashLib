if [[ -e /etc/bash_completion.d/git-prompt ]]; then
	GIT_PS1_SHOWUPSTREAM="auto"
	GIT_PS1_SHOWDIRTYSTATE="yes"
	GIT_PS1_SHOWCOLORHINTS="yes"
   . /etc/bash_completion.d/git-prompt
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\h:\[\033[01;33m\]$(__git_ps1 " (%s)") \[\033[01;34m\]\w\[\033[00m\]\$ '
fi

PROMPT_COMMAND='echo -ne "\033]0;${HOSTNAME}:$(__git_ps1 " (%s)") ${PWD}\007"'

