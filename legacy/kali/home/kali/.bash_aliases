#!/usr/bin/env bash

PROMPT_COMMAND="date '+%Y-%m-%d @ %H:%M:%S %Z'"
if [[ "$NEWLINE_BEFORE_PROMPT" == "yes" ]]; then
	bash -c "$PROMPT_COMMAND"
	PROMPT_COMMAND="PROMPT_COMMAND=\"echo '' && $PROMPT_COMMAND\""
fi

alias pbcopy="$(which xsel) --input --clipboard"
alias pbpaste="$(which xsel) --output --clipboard"

function msfconsole {
    sudo -u postgres /etc/init.d/postgresql start
    $(which msfconsole) "$@"
    sudo -u postgres /etc/init.d/postgresql stop
}

function xcv {
	nohup "$@" 2> /dev/null
}
