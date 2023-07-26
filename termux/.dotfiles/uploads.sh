#!/data/data/com.termux/files/usr/bin/sh
uploadserver ()
{
    if [[ -n $1 ]]; then
        file=$1;
    else
        echo -e "Select file to upload:";
        read -ei "" file;
    fi;
    echo -en "Select remote folder:\n";
    read -ei "/ffp/home/root/" serverdir;
    if [[ "$@" > 1 ]]; then
        for f in "$@";
        do
            echo -en "\033]0;Uploading $f\a";
            echo -en "Uploading $f to $serverdir";
            scp -r -i $HOME/.ssh/server $f root@192.168.1.20:$serverdir;
            echo -en "\n$file uploaded to $serverdir\n";
        done;
        echo -en "\033]0; \a";
    else
        echo -en "\033]0;Uploading $file\a";
        echo -en "Uploading $file to $serverdir";
        scp -r -i $HOME/.ssh/server $file root@192.168.1.20:$serverdir;
        echo -en "\n$file uploaded to $serverdir\n";
        echo -en "\033]0; \a";
    fi
}
