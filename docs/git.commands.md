# How to use git efficiently 

## GBL will come follogin bash shortcuts:

* g='git' - So it is shorter to run "g" instead of git.
* gg='git grep -n'  - search text in the only in the files from git repository
* gs='git st'  - short git status view (git status -sb)
* gd='git diff'
* gl="git log --pretty=format:'%C(dim)%h%Creset  %C(green)%s%Creset %C(yellow)<%an>%Creset %C(dim)%cr%Creset %C(blue)%D%Creset' --name-only"  - short view of git history which shows also the affected files.
* gdt='git difftool -d origin/dev .'
* ga='git add'
* b='git_branch'
* push='git push'
* pull='git pull -p'


## GBL provides aliases also in git config means they also work with "git" or "g" command:
* `g d`  = diff
* `g dt` = difftool -d origin/dev
* `g a`  = add
* `g co` = checkout
* `g c`  = commit
* `g ci` = commit
* `g b` = branch
* `g s` = status -sb
* `g st` = status -sb
* `g type` = cat-file -t
* `g dump` = cat-file -p
* `g l`= log --pretty=format:'%C(dim)%h%Creset  %C(green)%s%Creset %C(yellow)<%an>%Creset %C(dim)%cr%Creset %C(blue)%D%Creset' --name-only
* `g hist` = log --pretty=format:\"%h-%ar| %Cgreen%d%Creset %s [%Cblue%an%Creset]\" --graph --date=short --decorate=short
* `g m`= merge