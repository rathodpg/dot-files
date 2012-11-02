# /etc/bash/bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !


# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.

if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi

# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.  #65623
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize

# Enable history appending instead of overwriting.  #139609
shopt -s histappend

# Change the window title of X terminals
case ${TERM} in
	xterm*|rxvt*|Eterm|aterm|kterm|gnome*|interix)
		PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\007"'
		;;
	screen)
		PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\033\\"'
		;;
esac

use_color=false

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
	&& type -P dircolors >/dev/null \
	&& match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

if ${use_color} ; then
	# Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
	if type -P dircolors >/dev/null ; then
		if [[ -f ~/.dir_colors ]] ; then
			eval $(dircolors -b ~/.dir_colors)
		elif [[ -f /etc/DIR_COLORS ]] ; then
			eval $(dircolors -b /etc/DIR_COLORS)
		fi
	fi

	if [[ ${EUID} == 0 ]] ; then
		PS1='\[\033[01;31m\]\h\[\033[01;34m\] \W \$\[\033[00m\] '
	else
		PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] '
	fi

#	alias ls='ls --color=auto'
	alias grep='grep --colour=auto'
else
	if [[ ${EUID} == 0 ]] ; then
		# show root@ when we don't have colors
		PS1='\u@\h \W \$ '
	else
		PS1='\u@\h \w \$ '
	fi
fi

# Try to keep environment pollution down, EPA loves us.
unset use_color safe_term match_lhs

#################
#Misc functions
#################

findcity() { curl -s "http://api.hostip.info/get_html.php?ip=$1";}

pingallonLAN() { for i in {1..254}; do ping -c 1 10.100.98.$i; done; }

listalliponLAN() { pingallonLAN ; arp -n | grep ether | awk '{print $1}' | sort ;}

findlocation() { place=`echo $1 | sed 's/ /%20/g'` ; curl -s "http://maps.google.com/maps/geo?output=json&oe=utf-8&q=$place" | grep -e "address" -e "coordinates" | sed -e 's/^ *//' -e 's/"//g' -e 's/address/Full Address/';}

makeipaliases() { q=1 ; for i in {220..244}; do sudo ifconfig eth0:$q 10.100.98.$i netmask 255.255.255.0; q=`echo $q+1 | bc`; done ; }

etymo()
{
curl -s  "http://www.etymonline.com/index.php?term=$1" | html2text -nobs | sed '1,/^.*Z/d' | head -n 7 | less;
}
googl ()
{
	curl -s -d "url=${1}" http://goo.gl/api/url | sed -n "s/.*:\"\([^\"]*\).*/\1\n/p" | xclip -i -selection clipboard;
}

? () { echo "$*" | bc -l; }

startvnc()
{
	x11vnc -loop -display :0 -rfbauth ~/.x11vnc/passwd -many -display :0 -bg;
}

# extract function 7z package needed
x() {
	if [ -f "$1" ] ; then
	case "$1" in
		*.tar.bz2) tar xjf "$1" ;;
		*.tar.gz) tar xzf "$1" ;;
		*.tar.Z) tar xzf "$1" ;;
		*.bz2) bunzip2 "$1" ;;
		*.rar) 7z x "$1" ;;
		*.gz) gunzip "$1" ;;
		*.jar) 7z x "$1" ;;
		*.tar) tar xf "$1" ;;
		*.tbz2) tar xjf "$1" ;;
		*.tgz) tar xzf "$1" ;;
		*.zip) 7z x "$1" ;;
		*.Z) uncompress "$1" ;;
		*.7z) 7z x "$1" ;;
		*) echo "'$1' cannot be extracted" ;;
		esac
	else
		echo "'$1' is not a file"
			fi
}

wgetsite()
{
	wget --recursive --page-requisites --html-extension --convert-links --domains $1 --user-agent="Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.3) Gecko/2008092416 Firefox/3.0.3" --no-parent $2;
}

gitpcp()
{
    echo -e "\033[32m Doing git pull"
    tput sgr0;
    git pull;
    sleep 2
    echo -e "\033[32m Doing git commit -a"
    tput sgr0;
    git commit -a \"$1\";
    sleep 2
    if [[ $? == 1 ]];then
        echo -e "\033[32m Skipping push"
        return
    fi
    echo -e "\033[32m Doing git push"
    tput sgr0;
    git push;
}

gitwc()
{
    #Against value tells to diff against which old commit. 1 means the commit just before $1
    against="$2"
    if [[ $against == "" ]];then
        let against="1"
    fi
    prev_commit_hash=`git log --oneline | grep $(echo $1 | cut -c 1-7) -A $against | tail -n 1 | cut -d " " -f 1`
    echo $prev_commit_hash
    git diff $prev_commit_hash $1
    echo -e "\033[32m"
    git log $1 | head -n 5
    tput sgr0
}

swiki()
{
    search_term="$1"
    find /home/shadyabhi/my-wiki/wiki/ -type f | xargs grep --color --exclude-dir=.git $2 -Hin "$search_term"
}

vl()
{
    cmd=`echo $1 | sed -e 's/:\([0-9]\)/ +\1/' -e 's/:$//'`
    vim $cmd
}

#Start tmux only when required.
#cmd="tmux attach-session"; [[ $TERM != "screen" ]] && output=`$cmd 2>&1`; if [[ $output == "no sessions" ]];then tmux; fi

#DO NOT REMOVE THIS IN ORDER TO HAVE SCRIPT FARM FUNCTIONAL
if [ -f /home/shadyabhi/.scriptfarm/scriptfarm.sh ]; then . /home/shadyabhi/.scriptfarm/scriptfarm.sh ; fi
#export _JAVA_OPTIONS="-Dswing.aatext=true -Dawt.useSystemAAFontSettings=on -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel"
export HISTTIMEFORMAT='%F %T '


#RVM related shit.
PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
a() { alias $1=cd\ $PWD; }

#######
#Alias
#######

alias s3cmd="s3cmd --guess-mime-type"
alias dict="/home/shadyabhi/codes/godict/pretty_print.py"
alias p="curl -s -F 'sprunge=<-' http://sprunge.us | perl -ne 'chomp and print' | xclip -selection c && xclip -o -selection c"
alias N="sudo netcfg "
alias dnddir="cd /media/misc1/D"
alias sif="grep --exclude-dir=.git -inr"
alias wget="wget -c -t inf"
alias dhistory="less $HOME/dict/dicthistory"
alias rm="rm --verbose"
alias mv="mv --verbose"
alias cp="cp --verbose"
alias ls="ls -lh --color=auto"
alias hg="hg --verbose"
alias mount="mount -v"
alias grepall="grep --ignore-case --recursive --line-number --with-filename"
alias fullupgrade="yaourt -Syu --noconfirm"
alias onlineapps='lsof -P -i -n | cut -f 1 -d " "| uniq | tail -n +2'
alias diskusage='du -cks * | sort -rn | while read size fname; do for unit in k M G T P E Z Y; do if [ $size -lt 1024 ]; then echo -e "${size}${unit}\t${fname}"; break; fi; size=$((size/1024)); done; done'
alias jslint="jslint --color --vars --sloppy --undef";
alias mpcd="mpc -h 10.100.98.29"
alias PROXY="http_proxy=localhost:8118"
alias youtube-dl="youtube-dl -l"
alias dssh="ssh -i ~/.ssh/id_rsa_directi -F ~/.ssh/directi_ssh_config"
alias dxssh="dssh -t xbox.internal.directi.com ssh"
alias ll="ls -l --color"
alias ..="cd .."
alias ..2="cd ../.."
alias ..3="cd ../../.."
alias ..4="cd ../../../.."
alias ..5="cd ../../../../.."
alias gpl="git pull"
alias gpush="git push"
alias less="less -r"
alias ff="find -name "

########
#EXPORTS
########

#Some stuff for FF which I don't remember
export MOZ_DISABLE_PANGO=1

#History related tweaks
export HISTCONTROL=erasedups
export HISTSIZE=10000
export HISTORYCONTROL=ignorespace

#Defining default editor as Vim (for yaourt etc)
export EDITOR="vim"
export HGUSER="shadyabhi"
export PYTHONDOCS=/usr/share/doc/python2/html/

#EC2 related variables
export EC2_PRIVATE_KEY=~/.ec2/pk.pem
export export EC2_CERT=~/.ec2/cert.pem
export EC2_URL=https://ec2.us-west-1.amazonaws.com/

#############
#Bash Related
#############

#Doesn't overwrite existing file when ">" used
set -o noclobber
shopt -s autocd
set t_Co=16
