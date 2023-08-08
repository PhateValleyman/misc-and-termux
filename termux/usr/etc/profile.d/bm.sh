#!/data/data/com.termux/files/usr/bin/env bash
# USAGE:
# bm -a bookmarkname - saves the curr dir as bookmarkname
# bm -g bookmarkname - jumps to the that bookmark
# bm -g b[TAB] - tab completion is available
# bm -p bookmarkname - prints the bookmark
# bm -p b[TAB] - tab completion is available
# bm -d bookmarkname - deletes the bookmark
# bm -d [TAB] - tab completion is available
# bm -l - list all bookmarks

R="\e[01;31m"
G="\e[01;32m"
B="\e[01;34m"
Y="\e[01;33m"
C="\e[01;36m"
N="\e[0m"

SDIRS=/data/data/com.termux/files/usr/etc/sdirs
# setup file to store bookmarks
#if [ ! -n "$SDIRS" ]; then
#    SDIRS=/data/data/com.termux/files/usr/etc/sdirs
#fi
touch $SDIRS

RED="0;31m"
GREEN="0;33m"

# main function
function bm {
  option="${1}"
  case ${option} in
    # save current directory to bookmarks [ bm -a BOOKMARK_NAME ]
    -a)
      _save_bookmark "$2"
    ;;
    # delete bookmark [ bm -d BOOKMARK_NAME ]
    -d)
      _delete_bookmark "$2"
    ;;
    # jump to bookmark [ bm -g BOOKMARK_NAME ]
    -g)
      _goto_bookmark "$2"
    ;;
    # print bookmark [ bm -p BOOKMARK_NAME ]
    -p)
      _print_bookmark "$2"
    ;;
    # show bookmark list [ bm -l ]
    -l)
      _list_bookmark
    ;;
    # help [ bm -h ]
    -h)
      _echo_usage
    ;;
    # help [ bm --help ]
    --help)
      _echo_usage
    ;;
    *)
      if [[ $1 == -* ]]; then
        # unrecognized option. echo error message and usage [ bm -X ]
        echo "Neznama volba '$1'"
        _echo_usage
        kill -SIGINT $$
        exit 1
      elif [[ $1 == "" ]]; then
        # no args supplied - echo usage [ bm ]
        _echo_usage
      else
        # non-option supplied as first arg.  assume goto [ bm BOOKMARK_NAME ]
        _goto_bookmark "$1"
      fi
    ;;
  esac
}

# print usage information
function _echo_usage {
  echo -e " "
  echo -e "${C}POUZITI${N}:"
  echo -e "${R}bm${N} ${G}-h${N}			- ${B}Zobrazit informace o pouziti${N}"
  echo -e "${R}bm${N} ${G}-a${N} ${Y}<zalozka>${N}		  - ${B}Ulozit aktualni slozku jako${N} '${Y}zalozka${N}'"
  echo -e "${R}bm${N} ${G}-g${N} ${Y}<zalozka>${N}		  - ${B}Prejit (cd) do slozky ulozene jako${N} '${Y}zalozka${N}'"
  echo -e "${R}bm${N} ${G}-p${N} ${Y}<zalozka>${N}		  - ${B}Zobrazit slozku ulozenou jako${N} '${Y}zalozka${N}'"
  echo -e "${R}bm${N} ${G}-d${N} ${Y}<zalozka>${N}		  - ${B}Smazat zalozku${N} '${Y}zalozka${N}'"
  echo -e "${R}bm${N} ${G}-l${N}			- ${B}Zobrazit dostupne zalozky${N}"
  echo -e " "
}

# save current directory to bookmarks
function _save_bookmark {
  _bookmark_name_valid "$@"
  if [ -z "$exit_message" ]; then
    _purge_line "$SDIRS" "export DIR_$1="
    CURDIR=$(echo $PWD| sed "s#^$HOME#\$HOME#g")
    echo "export DIR_$1=\"$CURDIR\"" >> $SDIRS
  fi
}

# delete bookmark
function _delete_bookmark {
  _bookmark_name_valid "$@"
  if [ -z "$exit_message" ]; then
    _purge_line "$SDIRS" "export DIR_$1="
    unset "DIR_$1"
  fi
}

# jump to bookmark
function _goto_bookmark {
    source $SDIRS
    target="$(eval $(echo echo $(echo \$DIR_$1)))"
    if [ -d "$target" ]; then
        cd "$target"
    elif [ ! -n "$target" ]; then
        echo -e "\033[${RED}VAROVANI: '${1}' zalozka neexistuje\033[00m"
    else
        echo -e "\033[${RED}VAROVANI: '${target}' neexistuje\033[00m"
    fi
}

# list bookmarks with dirname
function _list_bookmark {
    source $SDIRS
    # if color output is not working for you, comment out the line below '\033[1;32m' == "red"
    env | sort | awk '/DIR_.+/{split(substr($0,5),parts,"="); printf("\033[0;33m%-20s\033[0m %s\n", parts[1], parts[2]);}'
    # uncomment this line if color output is not working with the line above
    # env | grep "^DIR_" | cut -c5- | sort |grep "^.*="
}

# print bookmark
function _print_bookmark {
    source $SDIRS
    echo "$(eval $(echo echo $(echo \$DIR_$1)))"
}

# list bookmarks without dirname
function _l {
    source $SDIRS
    env | grep "^DIR_" | cut -c5- | sort | grep "^.*=" | cut -f1 -d "="
}

# validate bookmark name
function _bookmark_name_valid {
    exit_message=""
    if [ -z $1 ]; then
        exit_message="chybi nazev zalozky"
        echo $exit_message
    elif [ "$1" != "$(echo $1 | sed 's/[^A-Za-z0-9_]//g')" ]; then
        exit_message="neplatny nazev zalozky"
        echo $exit_message
    fi
}

# completion command
function _comp {
    local curw
    COMPREPLY=()
    curw=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=($(compgen -W '`_l`' -- $curw))
    return 0
}

# ZSH completion command
function _compzsh {
  reply=($(_l))
}

# safe delete line from sdirs
function _purge_line {
  if [ -s "$1" ]; then
    # safely create a temp file
    t=$(mktemp -t bashmarks.XXXXXX) || exit 1
    trap "/bin/rm -f -- '$t'" EXIT

    # purge line
    sed "/$2/d" "$1" >| "$t"
    /bin/mv "$t" "$1"

    # cleanup temp file
    /bin/rm -f -- "$t"
    trap - EXIT
  fi
}

# bind completion command for g,p,d to _comp
if [ $ZSH_VERSION ]; then
  compctl -K _compzsh bm -g
  compctl -K _compzsh bm -p
  compctl -K _compzsh bm -d
  compctl -K _compzsh g
  compctl -K _compzsh p
  compctl -K _compzsh d
else
  shopt -s progcomp
  complete -F _comp bm -g
  complete -F _comp bm -p
  complete -F _comp bm -d
  complete -F _comp g
  complete -F _comp p
  complete -F _comp d
fi

alias s='bm -a'       # Save a bookmark [bookmark_name]
alias g='bm -g'       # Go to bookmark [bookmark_name]
alias p='bm -p'       # Print bookmark of a path [path]
alias d='bm -d'       # Delete a bookmark [bookmark_name]
