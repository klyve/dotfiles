function list-projects {
  project_roots=(
    "$HOME/personal"
    "$HOME/work"
  )
  depth=3

  # Loop over project roots and find ll directories that contain a .git folder
  for project_root in "${project_roots[@]}"; do
    for dir in $(find $project_root -maxdepth $depth -type d); do
      # We want to track all folders that contain .git folders or .workspace files
      if [[ -d $dir/.git || -f $dir/.workspace ]]; then
        echo "$dir" | sed "s|$HOME|~|"
      fi
    done
  done
}

function find-project() {
  PROJECT_PATH=$(list-projects |fzf)

  if [[ $PROJECT_PATH == "" ]]; then
    return
  fi

  # TODO: in some cases the directories are called the same.
  NAME=$(echo $PROJECT_PATH| awk -F/ '{print $NF}')

  # Check if there is a session with the same name, if there is attach to that
  tmux has-session -t=$NAME > /dev/null 2>&1
  if [ $? -eq 1 ]; then
    tmux new-session -s $NAME -n $NAME -d -c $PROJECT_PATH
    tmux send-keys -t $NAME "cd $PROJECT_PATH && clear" C-m
  fi

  if [[ -n "$TMUX" ]]; then
    tmux switch -t $NAME
  else
    echo "tmux attach-session -t $NAME -c $PROJECT_PATH"
    tmux attach-session -t $NAME -c $PROJECT_PATH 
  fi
}

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

function kproxy {
    # Available methods 
    # inject-tcp
    # vpn-tcp
    method=${METHOD:-"vpn-tcp"}
    telepresence --deployment $MO_USER --method $method $@ --run $SHELL 
}

function kforward {
    kproxy --expose $1
}

function az-secrets {
  eval $(keyvault-env -environment $1)
  kubectx mo-$1-aks
}

function dev {
    if [ -z $1 ]; then
        if [ -z $DEFAULT_DEV_ENV ]; then
            echo "usage: dev <environment>"
            echo "Or export \$DEFAULT_DEV_ENV"
            return
        fi
    fi
    ENVIRONMENT=${1:-$DEFAULT_DEV_ENV}

    file=$(find $DEV_ENVPATH -name "$ENVIRONMENT.sh")
    if [ -z $file ]; then
        echo "Environment shell file not found in path $DEV_ENVPATH/$ENVIRONMENT.sh"
        return
    fi
    source $file
    echo "Environemt $ENVIRONMENT Loaded"
}

function prune-node {
    find . -name "node_modules" -type d -prune -exec rm -rf '{}' +
}

# Sign in to ECR 
function ecr-login {
    REGION=${AWS_REGION:-eu-central-1}  # Region to authenticate against
    PROFILE=${AWS_PROFILE:-default}     # AWS profile to use
    $(aws ecr get-login --no-include-email --region $REGION --profile $PROFILE)
}

# Get the aws-iam-authenticator token
function aws-token {
    TOKEN_ENV=${1:-$AWS_ENVIRONMENT}
    if [ -z "$TOKEN_ENV" ]; then
        echo "Argument (environment) or env var AWS_ENVIRONMENT must be set to run this command"
    else
        aws-iam-authenticator token -i $TOKEN_ENV | jq '.status.token' --raw-output
    fi
}

# Authenticate with samlAuth using aws-google-auth
function saml-auth {
    IPD_ID=${GIP_ID} # Google SSO IDP identifier
    SP_ID=${GSP_ID} # Google SSO SP identifier
    DURATION=${AWS_DURATION:-28800} # Duration set for the aws role
    REGION=${AWS_REGION:-eu-central-1} # Region to authenticate against
    PROFILE=${AWS_PROFILE:-default} # AWS profile to use
    SAML_USER=${1:-$GSAML_USER} # Saml user or first input to use for authentication

    # [-a] Saves password in keychain
    # [-k] Always ask for iam role
    aws-google-auth -u $SAML_USER -I $IPD_ID -S $SP_ID -R $REGION -d $DURATION -p $PROFILE -a -k
}

# Set up kubernetes config
function eks-kube-conf {
    REGION=${AWS_REGION:-eu-central-1} # Region to use for kubeconf
    aws --region $REGION eks update-kubeconfig --name ${1:-$AWS_ENVIRONMENT}
}

# AKS Kube config
function aks-kube-conf {
    RESOURCE=${1:-$AZ_RESOURCE} 
    RESOURCE=${RESOURCE:-mo-develop}
    az aks get-credentials --name ${RESOURCE}-aks --resource-group ${RESOURCE}-resources
}

function proxy-vault {
    VAULT_POD=$(kubectl get pods -n infrastructure -l "app=vault" -o jsonpath="{.items[0].metadata.name}")
    kubectl port-forward -n infrastructure $VAULT_POD 8200
}
function proxy-argo {
    kubectl port-forward svc/argocd-server -n argocd 8080:443
}
function proxy-consul {
    kubectl port-forward svc/consul -n infrastructure 8500
}
function proxy-kafka {
    kubectl port-forward svc/kafka -n infrastructure 9092
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


function argocd-add {
    REMOTE=$(git config --get remote.origin.url)
    argocd repo add $REMOTE --ssh-private-key-path ~/.ssh/id_argocd_rsa --insecure-ignore-host-key --upsert 
}


function argocd-login {
    argocd login localhost:8080 --sso
}

function kafka-list-topics {
    kubectl -n infrastructure exec ${KAFKA_TEST_POD} -- \
    /usr/bin/kafka-topics --zookeeper ${ZOOKEEPER_ADDR} --list
}

function kafka-describe-topic {
    kubectl -n infrastructure exec ${KAFKA_TEST_POD} -- \
    /usr/bin/kafka-topics --describe --zookeeper ${ZOOKEEPER_ADDR} --topic $1
}

function kafka-create-topic {
    kubectl -n infrastructure exec ${KAFKA_TEST_POD} -- \
    /usr/bin/kafka-topics --zookeeper ${ZOOKEEPER_ADDR} \
    --topic ${1} --create --partitions 1 --replication-factor 1
}

function kafka-delete-topic {
    kubectl -n infrastructure exec ${KAFKA_TEST_POD} -- \
    /usr/bin/kafka-topics --zookeeper ${ZOOKEEPER_ADDR} --delete \
    --topic ${1} 
}

function kafka-listen-topic {
    kubectl -n infrastructure exec -ti ${KAFKA_TEST_POD} -- \
    /usr/bin/kafka-console-consumer --bootstrap-server ${KAFKA_ADDR} \
    --topic $1 --from-beginning
}

function video-gif {
ulimit -Sv 1000000
filename=$(basename -- "$1")
ffmpeg \
  -i $1 \
  -r 10 \
  $filename.gif
}
  
# Updates editor information when the keymap changes.
function zle-keymap-select() {
  # update keymap variable for the prompt
  VI_KEYMAP=$KEYMAP

  zle reset-prompt
  zle -R
}

zle -N zle-keymap-select

function vi-accept-line() {
  VI_KEYMAP=main
  zle accept-line
}

# zle -N find-project
zle -N vi-accept-line


bindkey -v

# use custom accept-line widget to update $VI_KEYMAP
bindkey -M vicmd '^J' vi-accept-line
bindkey -M vicmd '^M' vi-accept-line

# allow v to edit the command line (standard behaviour)
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line

# allow ctrl-p, ctrl-n for navigate history (standard behaviour)
bindkey '^P' up-history
bindkey '^N' down-history

# run find-project when pressing ctrl+F
bindkey -s '^F' 'find-project\n'

# allow ctrl-h, ctrl-w, ctrl-? for char and word deletion (standard behaviour)
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word

# allow ctrl-r and ctrl-s to search the history
bindkey '^r' history-incremental-search-backward
bindkey '^s' history-incremental-search-forward

# allow ctrl-a and ctrl-e to move to beginning/end of line
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line

# if mode indicator wasn't setup by theme, define default
if [[ "$MODE_INDICATOR" == "" ]]; then
  MODE_INDICATOR="%{$fg_bold[red]%}<%{$fg[red]%}<<%{$reset_color%}"
fi

function vi_mode_prompt_info() {
  echo "${${VI_KEYMAP/vicmd/$MODE_INDICATOR}/(main|viins)/}"
}

# define right prompt, if it wasn't defined by a theme
if [[ "$RPS1" == "" && "$RPROMPT" == "" ]]; then
  RPS1='$(vi_mode_prompt_info)'
fi
