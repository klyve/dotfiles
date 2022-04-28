function reload { 
    source ~/.zshrc
}

function pg-start {
    pg_ctl -D /usr/local/var/postgres start
}

function pg-restart {
    pg_ctl -D /usr/local/var/postgres restart
}

function mongo-start {
    mongod --config /usr/local/etc/mongod.conf --fork
}

function redis-start {
    redis-server /usr/local/etc/redis.conf
}

function az-secrets {
  eval $(keyvault-env -environment $1)
  kubectx mo-$1-aks
}

function bltc {
    [ `uname -s` != "Darwin" ] && echo "Cannot run on non-macosx system." && return
    osascript -i <<EOF
tell application "System Events" to tell process "SystemUIServer"
	set bt to (first menu bar item whose description is "bluetooth") of menu bar 1
	click bt
	tell (first menu item whose title is "$1") of menu of bt
		click
		tell menu 1
			if exists menu item "Connect" then
				click menu item "Connect"
			else
				click bt
			end if
		end tell
	end tell
end tell
EOF
}

function coffee {
    touch ~/.coffee
    if [[ $# -lt 1 ]]; then
        # Add cup of coffee
        date +%s >> ~/.coffee
    else
        if [ "$1" = "count" ]; then
            echo "$(< ~/.coffee wc -l) cups of coffee logged to date"
        fi
    fi
}

function cd {
    builtin cd "$@" && exa -abghHliS
}

function ls {
  exa "$@" -abghHlS
}

function create-note {
    DATE=$(date "+%Y-%m-%d")
    touch "$1-$DATE.md"
}


function video-gif {
  ulimit -Sv 1000000
  filename=$(basename -- "$1")
  ffmpeg \
    -i $1 \
    -r 10 \
    $filename.gif
}
