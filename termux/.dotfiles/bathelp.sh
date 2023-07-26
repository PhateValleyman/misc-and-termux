#!/data/data/com.termux/files/usr/bin/bash
alias bathelp='bat --plain --language=help'
help() {
    "$@" --help 2>&1 | bathelp
}
