#!/data/data/com.termux/files/usr/bin/bash
batdiff() {
    git diff --name-only --relative --diff-filter=d | xargs bat --diff
}
