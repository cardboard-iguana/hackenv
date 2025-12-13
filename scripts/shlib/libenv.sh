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
