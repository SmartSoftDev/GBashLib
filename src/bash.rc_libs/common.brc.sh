if ! alias ll >/dev/null 2>&1; then  
    alias ll='ls -alF'
    alias la='ls -A'
    alias l='ls -CF'
fi

# change history files
HISTSIZE=10000
HISTFILESIZE=12000

