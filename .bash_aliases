alias gain='mp3gain -r *.mp3'
alias du='du -kh'
alias df='df -kh'
alias mkdir='mkdir -p -v'
alias rm='rm -r'
alias cdtemp='cd $(mktemp --dir)'
alias pushtemp='pushd . && cdtemp'
alias chalias='$EDITOR ~/.bash_aliases'
alias title='mocp -Q%title'
alias mkreport='cp -r /home/luke/Schoolwork/stuff/report .'
alias t='tree'
alias shutdown='shutdown now'
alias mntPi='mkdir -p ~/Pi && sshfs luke@lukegrehan.com:/home/luke ~/Pi && cd ~/Pi'
alias unMntPi='sudo fusermount -u ~/Pi && rmdir ~/Pi'
alias tmux='tmux -2'
alias mklatex='latexmk -pvc -pdf'
