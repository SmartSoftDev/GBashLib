pyclean () {
    find . -type f -name "*.py[co]" -delete
    find . -type d -name "__pycache__" -delete
}

alias bp='bpython'
alias pytest3='python3 -m pytest -vvvv -o log_cli=true -p no:cacheprovider'

# For python3 user libraries
export PATH="$HOME/.local/bin:$PATH"