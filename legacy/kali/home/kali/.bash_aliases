#!/usr/bin/env bash

function msfconsole {
    sudo -u postgres /etc/init.d/postgresql start
    $(which msfconsole) "$@"
    sudo -u postgres /etc/init.d/postgresql stop
}
