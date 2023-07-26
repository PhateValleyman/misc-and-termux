#!/data/data/com.termux/files/usr/bin/bash

alias ls='/data/data/com.termux/files/usr/bin/ls -1a --color=tty --show-control-chars --quoting-style=shell --group-directories-first'
alias lst='/data/data/com.termux/files/usr/bin/ls -1ac --color=tty --show-control-chars --quoting-style=shell'

alias ..='cd ..'
alias ...='.. && ..'
alias ....='... && ..'
alias .....='.... && ..'

alias rm='yes | rm -r -v'
alias cp='cp -v -r'
alias mv='mv -f -f'

alias 'ts'='telnet 192.168.1.20'

alias 'tree'='tree -AC --dirsfirst'

alias 'wol'='wol FC:F5:28:31:08:B1'

alias 'pygmentize'='pygmentize -g'

alias wget='wget --show-progress --continue'
alias 'curl'='curl --progress-bar'

alias reload='source /data/data/com.termux/files/usr/etc/profile'

alias ssh-server='su -c BIND_INTERFACE=wlan0 DNS_OVERRIDE_IP=8.8.8.8 LD_PRELOAD=/system/lib/bindToInterface.so /data/adb/modules/ssh/usr/bin/ssh -i ~/.ssh/server root@192.168.1.20'

alias rclone-web='rclone rcd --rc-web-gui --rc-user=root --rc-pass=24nascr'
