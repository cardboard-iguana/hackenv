#!/usr/bin/env bash

function get_direnv_path {
    DIR="$(realpath "$1")"

    if [[ -d "$DIR" ]]; then
        if [[ -f "$DIR"/.envrc ]]; then
            echo "$DIR"
        else
            PARENT_DIR="$(dirname "$DIR")"

            if [[ "$PARENT_DIR" != "$DIR" ]]; then
                get_direnv_path "$PARENT_DIR"
            fi
        fi
    fi
}

function unmask_executable {
    OLD_PATH="$PATH"
    PATH="$(echo ":${PATH}:" | sed "s#:/[^:]*/scripts\(/[^:]*\)*:#:#g;s#^:##;s#:\$##")"
    export PATH

    which "$1" 2>/dev/null

    export PATH="$OLD_PATH"
}

function get_msf_config_root {
    ENVIRONMENT_DIRECTORY="$(get_direnv_path "$1")"

    if [[ -n "$ENVIRONMENT_DIRECTORY" ]] && [[ -d "$ENVIRONMENT_DIRECTORY" ]]; then
        if [[ -z "$MSF_CFGROOT_CONFIG" ]]; then
            MSF_CFGROOT_CONFIG="$ENVIRONMENT_DIRECTORY"/appdata/metasploit
            mkdir -p "$MSF_CFGROOT_CONFIG"
        fi
        echo "$MSF_CFGROOT_CONFIG"
    fi
}

function start_msfdb {
    MSF_CFGROOT_CONFIG="$(get_msf_config_root "$1")"

    if [[ -n "$MSF_CFGROOT_CONFIG" ]]; then
        export MSF_CFGROOT_CONFIG

        if [[ ! -d "$MSF_CFGROOT_CONFIG"/db ]]; then
            msfdb init
        fi
        if [[ -f "$MSF_CFGROOT_CONFIG"/db/postmaster.pid ]] && [[ -z "$(pgrep -F "$MSF_CFGROOT_CONFIG"/db/postmaster.pid)" ]]; then
            rm "$MSF_CFGROOT_CONFIG"/db/postmaster.pid
        fi
        if [[ ! -f "$MSF_CFGROOT_CONFIG"/db/postmaster.pid ]]; then
            msfdb start
        fi
    fi
}

function stop_msfdb {
    ENVIRONMENT_DIRECTORY="$(get_direnv_path "$1")"
    MSF_CFGROOT_CONFIG="$(get_msf_config_root "$ENVIRONMENT_DIRECTORY")"

    if [[ -n "$MSF_CFGROOT_CONFIG" ]]; then
        export MSF_CFGROOT_CONFIG

        if [[ $(pgrep -f "msfconsole msfConfigRoot=$MSF_CFGROOT_CONFIG" | wc -l) -eq 0 ]] &&
            [[ $(pgrep -a -f "asciinema rec .* $ENVIRONMENT_DIRECTORY/artifacts/terminal_session_.*.cast" | wc -l) -eq 0 ]]; then
            msfdb stop
        fi
    fi
}
