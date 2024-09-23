# add-apt-repository ppa:ultradvorka/ppa
# apt update
# apt install hstr
# On Debain: hstr --show-configuration >> ~/.bashrc

# apt install bat fzf zsh fd
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# theme agnoster

# Source fzf key bindings and fuzzy completion
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
[ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh

alias ll = 'fzf --preview bat --style=numbers --color=always {}'
# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}


#-------------------- Oh My Bash -------------------#
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
# theme agnoster

#-------------------- Custom Vim Config -------------------#
#			git clone https://github.com/amix/vimrc.git ~/.vim_runtime
#			sh ~/.vim_runtime/install_awesome_vimrc.sh

#-------------------- Kubectl bash completion -------------------#
# alias kk=kubectl
# complete -o default -F __start_kubectl kk
# source <(kubectl completion bash)

#-------------------- Kubectl Context Switcher -------------------#
# git clone https://github.com/ahmetb/kubectx /opt/kubectx
# ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
# ln -s /opt/kubectx/kubens /usr/local/bin/kubens
# ------------Bash completion ------- #
# git clone https://github.com/ahmetb/kubectx.git ~/.kubectx
# COMPDIR=$(pkg-config --variable=completionsdir bash-completion)
# ln -sf ~/.kubectx/completion/kubens.bash $COMPDIR/kubens
# ln -sf ~/.kubectx/completion/kubectx.bash $COMPDIR/kubectx
# cat << EOF >> ~/.bashrc

# #kubectx and kubens
# export PATH=~/.kubectx:\$PATH
# EOF

#########################-------------COLORS------------------#########################
RS="\[\033[0m\]"    # reset
HC="\[\033[1m\]"    # hicolor
UL="\[\033[4m\]"    # underline
INV="\[\033[7m\]"   # inverse background and foreground
FBLK="\[\033[30m\]" # foreground black
FRED="\[\033[31m\]" # foreground red
FGRN="\[\033[32m\]" # foreground green
FYEL="\[\033[33m\]" # foreground yellow
FBLE="\[\033[34m\]" # foreground blue
FMAG="\[\033[35m\]" # foreground magenta
FCYN="\[\033[36m\]" # foreground cyan
FWHT="\[\033[37m\]" # foreground white
BBLK="\[\033[40m\]" # background black
BRED="\[\033[41m\]" # background red
BGRN="\[\033[42m\]" # background green
BYEL="\[\033[43m\]" # background yellow
BBLE="\[\033[44m\]" # background blue
BMAG="\[\033[45m\]" # background magenta
BCYN="\[\033[46m\]" # background cyan
BWHT="\[\033[47m\]" # background white
txtblk='\e[0;30m' # Black - Regular
txtred='\e[0;31m' # Red
txtgrn='\e[0;32m' # Green
txtylw='\e[0;33m' # Yellow
txtblu='\e[0;34m' # Blue
txtpur='\e[0;35m' # Purple
txtcyn='\e[0;36m' # Cyan
txtwht='\e[0;37m' # White
bldblk='\e[1;30m' # Black - Bold
bldred='\e[1;31m' # Red
bldgrn='\e[1;32m' # Green
bldylw='\e[1;33m' # Yellow
bldblu='\e[1;34m' # Blue
bldpur='\e[1;35m' # Purple
bldcyn='\e[1;36m' # Cyan
bldwht='\e[1;37m' # White
unkblk='\e[4;30m' # Black - Underline
undred='\e[4;31m' # Red
undgrn='\e[4;32m' # Green
undylw='\e[4;33m' # Yellow
undblu='\e[4;34m' # Blue
undpur='\e[4;35m' # Purple
undcyn='\e[4;36m' # Cyan
undwht='\e[4;37m' # White
bakblk='\e[40m'   # Black - Background
bakred='\e[41m'   # Red
bakgrn='\e[42m'   # Green
bakylw='\e[43m'   # Yellow
bakblu='\e[44m'   # Blue
bakpur='\e[45m'   # Purple
bakcyn='\e[46m'   # Cyan
bakwht='\e[47m'   # White
txtrst='\e[0m'    # Text Reset
#########################-------------COLORS------------------#########################
# PS1=" \[$bldred\]ELK-DLP365-\[$txtrst\]\[$bldgrn\]Test\[$txtrst\]\[$txtylw\] [\A] \[$txtrst\]\w> "
# PS1=" ELK-DLP365-Prod [\A] \w> "
####################################-----------History-Control---------#############################
# avoid duplicates..
export HISTCONTROL=ignoredups:erasedups:ignorespace
shopt -s cdspell # Spellcheck for command and dir name
export HISTTIMEFORMAT="%h %d %H:%M:%S "   # After each command, save and reload history
export HH_CONFIG=hicolor,casesensitive,rawhistory
shopt -s histappend              # append new history items to .bash_history
export HISTFILESIZE=10000        # increase history file size (default is 500)
export HISTSIZE=${HISTFILESIZE}  # increase history size (default is 500)
export HISTIGNORE="&:cd:exit:ls:history:w:htop:pwd:top:htop" # This will cause all duplicate commands, and the cd, exit, and ls commands to be omitted from the history list.
export PROMPT_COMMAND="history -a; history -n; ${PROMPT_COMMAND}"   # mem/file sync
#
	if [[ $- =~ .*i.* ]]; then bind '"\C-r": "\C-a hh \C-j"'; fi # if this is interactive shell, then bind hh to Ctrl-r
shopt -s autocd #Go to directory by just typing its name. No need to use 'cd'
####################################################################################################

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi
#------------------------------------------------------
#search in history with arrows after Ctrl+R
bind '"\e[A": history-search-backward' 2>/dev/null
bind '"\e[B": history-search-forward' 2>/dev/null

#------------------------------------------------------
# Create dir and CD to it
function md1 () { /bin/mkdir -p "$@" && cd "$@"; }
#
#------------------------------------------------------
#  I can now run df -h|fawk 2 which saves a good bit of typing
function fawk () {
    USAGE="\
usage:  fawk [<awk_args>] <field_no>
        Ex: getent passwd | grep andy | fawk -F: 5
"
    if [ $# -eq 0 ]; then
        echo -e "$USAGE" >&2
        return
        #exit 1 # whoops! that would quit the shell!
    fi
 
    # bail if the *last* argument isn't a number (source:
    # http://stackoverflow.com/a/808740)
    last=${@:(-1)}
    if ! [ $last -eq $last ] &>/dev/null; then
        echo "FAWK! Last argument (awk field) must be numeric." >&2
        echo -e "$USAGE" >&2;
        return
    fi
 
    if [ $# -gt 1 ]; then
        # Source:
        # http://www.cyberciti.biz/faq/linux-unix-bsd-apple-osx-bash-get-last-argument/
        rest=${@:1:$(( $# - 1 ))}
    else
        rest='' # just to be sure
    fi
    awk $rest "{ print  \$$last }"
}
#------------------------------------------------------
# Search/grep within history
function hs () {
  if [ $# -ne 1 ]; then
  history | ccze -A
  else
  history | /bin/grep -i --color=auto $1
  fi
}
#-----------------------------------------------------
function tail () {
'/usr/bin/tail' $@ $1 | ccze -A
}
#-----------------------------------------------------
function ls () {
/bin/ls -la --group-directories-first $@ | ccze -A
#du -ch | /bin/grep total
}
#-----------------------------------------------------
function findlast () {
if [ -f $2 ] ; then
        case $2 in
            s) data=$(/bin/date --date="$1 seconds ago" +"%F %T")   ;;
            m) data=$(/bin/date --date="$1 minutes ago" +"%F %T")   ;;
            d) data=$(/bin/date --date="$1 days ago" +"%F %T")   ;;
            mo) data=$(/bin/date --date="$1 months ago" +"%F %T")   ;;
        esac
    else data=$(/bin/date --date="120 seconds ago" +"%F %T")
fi
touch --date "$data" /tmp/foo
find /var/log/ -type f -newer /tmp/foo
}
#-----------------------------------------------------
function findlog () {
if [ -f $2 ] ; then
        case $2 in
            s) data1=$(/bin/date --date="$1 seconds ago" +"%F %T")   ;;
            m) data1=$(/bin/date --date="$1 minutes ago" +"%F %T")   ;;
            d) data1=$(/bin/date --date="$1 days ago" +"%F %T")   ;;
            mo) data1=$(/bin/date --date="$1 months ago" +"%F %T")   ;;
        esac
    else data1=$(/bin/date --date="120 seconds ago" +"%F %T")
fi
touch --date "$data1" /tmp/foo
find /var/log/ -newer /tmp/foo | while read i; do /bin/grep -iH $3 $i; done | ccze -A
}
#-----------------------------------------------------
function ps () {
if [ $# -ne 1 ]; then
/bin/ps aux | ccze -A
else
/bin/ps aux | /bin/grep -v grep | /bin/grep --color=auto $1
fi
}
#-----------------------------------------------------
function kill () {
pid1=$(/bin/ps auxww | /bin/grep "$1" | egrep -v grep | awk '{print $2}')
procname=$(/bin/ps auxww | /bin/grep "$1" | egrep -v grep | awk '{print $12}')
if [[ -n $pid1 ]]; then
	/bin/kill -15 $pid1
	echo "Proccess -- $procname -- Killed!"
else
	echo "Proccess $1 Not Found!"
fi
}
#-----------------------------------------------------
function less () {
/bin/less $@ | ccze -A
}
#-----------------------------------------------------
function nicemount () {
(echo "DEVICE PATH TYPE FLAGS" && mount | awk '$2=$4="";1') | column -t | ccze -A;
}
#-----------------------------------------------------
function ping1 () {
/bin/ping $@ $1 | ccze -A
}
#-----------------------------------------------------
#function grep () {
#/bin/grep -i '$@' | ccze -A
#}
#-----------------------------------------------------
function grepstring () {
/bin/grep -r -A 3 -B 3 "$1" "$2" | ccze -A
}
#-----------------------------------------------------
# Find this $1 Word in this $2 Files
function grepit () {
find . -name "*${2}" -print | xargs /bin/grep -nir "${1}"
}
#-----------------------------------------------------

function extract () {
    if [ -f $1 ] ; then
        case $1 in
			*.tar.bz2) tar xvjf $1   ;;
			*.tar.gz)  tar xvzf $1   ;;
			*.tar.xz)  tar xf $1   ;;
			*.bz2)     tar xvjf $1    ;;
			*.rar)     unrar x $1    ;;
			*.gz)      gunzip $1     ;;
			*.tar)     tar xvf $1    ;;
			*.tbz2)    tar xvjf $1   ;;
			*.tgz)     tar xvzf $1   ;;
			*.zip)     unzip $1      ;;
			*.Z)       uncompress $1 ;;
			*.7z)      7z x $1       ;;
			*)         echo "'$1' cannot be extracted via >extract<" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}
#-----------------------------------------------------
#Paginated colored tree
function ltree ()
{
    tree -C $* | less -R
}
#-----------------------------------------------------
function do-and-do () {
for i in $("$1")
do "$2" $i
done
}

#-----------------------------------------------------#

function spy () {
lsof -i -P +c 0 +M | /bin/grep -i "$1"
}
#-----------------------------------------------------#
#List most recently changed files
function lt () {
ls -ltrh --color $1 | /usr/bin/tail -n 15;
}
#-----------------------------------------------------#
#sniff GET and POST traffic over http
function sniff () {
/usr/bin/ngrep -d ''$1'' -t '^(GET|POST) ' 'tcp and port 80'
}
#-----------------------------------------------------#
# Change and list directory on clear screen
function cdls { cd $1; clear; /bin/ls -lah;}
#-----------------------------------------------------#
#"Sort by size" to display in list the files in the current directory, sorted by their size on disk.
sbs() { du -b --max-depth 1 | sort -nr | perl -pe 's{([0-9]+)}{sprintf "%.1f%s", $1>=2**30? ($1/2**30, "G"): $1>=2**20? ($1/2**20, "M"): $1>=2**10? ($1/2**10, "K"): ($1, "")}e';}
#-----------------------------------------------------#

function myhelp ()
{
echo -e "<ctrl+x ctrl+e> (Rapidly invoke an editor to write a long, complex, or tricky command)\n<ctrl+u> [...] <ctrl+y> (type partial command, kill this command, check something you forgot, yank the command, resume typing)\n<ctrl+l> (Clear the terminal screen)"
}

#-----------------------------------------------------#


#alias grep='/bin/grep --color=auto'

alias watch='/usr/bin/watch -d' ##watch with highlight
export GREP_COLOR='1;30;42'
#alias grep='grep -ir'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias syslog='/usr/bin/tail -n30 /var/log/syslog | ccze -A'

# Reboot
alias reboot='echo "Rebooting `hostname` in 5 secs. Press Ctrl+C to cancel";sleep 7 && reboot'
alias poweroff='echo "Shutting down `hostname` in 5 secs. Press Ctrl+C to cancel";sleep 7 && poweroff'
#
alias cp='rsync -ahP'
alias df='pydf'
#alias squid='/usr/local/squid/sbin/squid'
alias webserver='python -m SimpleHTTPServer 80'
alias wget='wget --content-disposition'
alias rmf='rm -rf'
alias ls='ls -la --group-directories-first'
#
#Show lines that are not blank or commented out
alias active='/bin/grep -v -e "^$" -e"^ *#"'
#
# Exact Memory consumption
alias freee='/usr/bin/watch -n1 -d ~/ps_mem/ps_mem.py'
#Reload bashRC
alias reloadrc='source ~/.bashrc'
#
#Show active Listeners
alias netlisteners='lsof -n -P -i4 -sTCP:LISTEN -sTCP:ESTABLISHED | (read -r; printf "%s\n" "$REPLY"; sort -k9nr)'
#
alias myip='curl http://ipinfo.io'
#
alias hh='/usr/bin/hstr'
#alias helpme='curl cheat.sh/command'

transfer () {
	if [[ "$#" -ge "2" ]]; then
		curl -F "file=@$1" "https://file.io/?expires=$2";
	elif [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
		echo "Uploads a file to file.io"
		echo
		echo -n "Usage: fio file_name [expiration]"
	elif [[ "$#" -ge "1" ]]; then
		curl -F "file=@$1" "https://file.io";
	else
		echo "Invalid arguments";
		echo
		echo -n "Use \"fio --help\" for help";
	fi
	echo;
}

#--------------EXPORT----------------------#
export EDITOR=/usr/bin/vim
export CHEATCOLORS=true