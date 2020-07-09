#
# ~/.bashrc
#

source ~/.env
export GOPATH=~/.local/share/go
export PATH=~/bin:~/.local/bin:$PATH 

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/tretinha/lib/google-cloud-sdk/path.bash.inc' ]; then . '/home/tretinha/lib/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/tretinha/lib/google-cloud-sdk/completion.bash.inc' ]; then . '/home/tretinha/lib/google-cloud-sdk/completion.bash.inc'; fi
