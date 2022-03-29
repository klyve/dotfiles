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

function serveo {
    if [[ $# -lt 2 ]]; then
        echo "Useage serveo <name> <port>"
    else
        ssh -o ServerAliveInterval=60 -R $1:80:localhost:$2 serveo.net
    fi
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

function tab {
    [ `uname -s` != "Darwin" ] && echo "Cannot run on non-macosx system." && return
    local cmd=""
    local cdto="$PWD"
    local args="$@"

    if [ -d "$1" ]; then
        cdto=`cd "$1"; pwd`
        args="${@:2}"
    fi

    if [ -n "$args" ]; then
        cmd="$args"
    fi

    osascript -i <<EOF
tell application "iTerm"
    tell current window
        create tab with default profile
        tell the current session
            write text "cd \"$cdto\"; $cmd"
            write text "clear; $cmd"
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

function squarespace {
    squarespace-server https://${SQUARESPACE_WEBSITE}.squarespace.com --auth --verbose
}

function cd {
    builtin cd "$@" && exa -abghHliS
}
function ls {
  exa "$@" -abghHlS
}

function create-service {
    hub create MaritimeOptima/$1 -p
}

function git-clone {
    git clone git@github.com:MaritimeOptima/$1.git
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

function ecr-repo {
    if [ -z $1 ]; then
        echo "Requires repository name"
        return
    fi
    name="${ECR_NAMESPACE}${1}"
    repo=$(aws ecr describe-repositories|grep "repository/${name}\",")
    if [ -z "$repo" ]; then
        aws ecr create-repository --repository-name $name
    else
        echo "Repo already exists"
    fi
}

function video-gif {
ulimit -Sv 1000000
filename=$(basename -- "$1")
ffmpeg \
  -i $1 \
  -r 10 \
  $filename.gif
}


function vault-login {
    token=$(curl --request POST --data '{"token": "'${GITHUB_TOKEN}'"}' ${VAULT_ADDR}/v1/auth/github/login| jq -r '.auth.client_token')
    export VAULT_TOKEN=$token
}

function render-consul-template {
    vault-login
    echo "Starting consul template"
    consul-template -once -config $1 $2
}


function vault-db {
    if [ -z $VAULT_TOKEN ]; then
        echo "No vault token set"
        return
    fi
    eval "$(curl --header "X-Vault-Token: $VAULT_TOKEN" -s -k  ${VAULT_ADDR}/v1/database/creds/$1| jq -r '.data | to_entries | .[] | .key + "=\"" + .value + "\""')"
   
    export VAULT_DB_USERNAME=$username
    export VAULT_DB_PASSWORD=$password
    echo "*************************************"
    echo "Set Vault DB environment variables"
    echo
    echo "VAULT_DB_USERNAME"
    echo "VAULT_DB_PASSWORD"
    echo
    echo "*************************************"
}

function vault-aws {
    if [ -z $VAULT_TOKEN ]; then
        echo "No vault token set"
        return
    fi
    eval "$(curl --header "X-Vault-Token: $VAULT_TOKEN" -s -k  ${VAULT_ADDR}/v1/aws/creds/$1| jq -r '.data | to_entries | .[] | .key + "=\"" + .value + "\""')"
   
    export VAULT_AWS_SECRET_KEY=$secret_key
    export VAULT_AWS_ACCESS_KEY=$access_key
    echo "*************************************"
    echo "Set Vault AWS environment variables"
    echo
    echo "VAULT_AWS_SECRET_KEY"
    echo "VAULT_AWS_ACCESS_KEY"
    echo
    echo "*************************************"
}

function set-aws-environment-vars {
    mkdir -p ~/.maritimeoptima
    echo "$(aws ssm get-parameters --name $AWS_ENVIRONMENT --with-decryption --query "Parameters[*].{Name:Name,Value:Value}" |jq '.[0].Value' --raw-output)" > ~/.maritimeoptima/environment.sh
    source ~/.maritimeoptima/environment.sh
    # rm ~/.maritimeoptima/environment.sh
}

function az-secrets {
  eval $(keyvault-env -environment $1)
  kubectx mo-$1-aks
}

function git-video {
    gource -c 4.0 -o - | ffmpeg -y -r 60 -f image2pipe -vcodec ppm -i - -vcodec libx264 -preset ultrafast -pix_fmt yuv420p -crf 1 -threads 0 -bf 0 gource.mp4
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

function jql() {
  curl "https://${JIRA_TEAM}.atlassian.net/rest/api/2/search?jql=$1&maxResults=100&startAt=$(($2 * 100))" \
    -s -u "${JIRA_USER}:${JIRA_TOKEN}" \
    |  jq -r '.issues[] | "\(.key): \(.fields.summary)"'
}

# type = Subtask and parent = "MR-466" and status != Done
# Child issues
function fjql() {
  ticket=$({for ((req=0;req<5;req++)); do
    jql $1 $req &
  done} | fzf --no-hscroll +m | cut -d ':' -f 1)
  [ ${#ticket} -eq 0 ] return

  open "https://${JIRA_TEAM}.atlassian.net/browse/${ticket}"
}

alias fj="fjql 'order%20by%20updated%20DESC'"
alias fjm="fjql 'project%20%3D%20%22${JIRA_PROJECT}%22%20AND%20assignee%20%3D%20currentUser%28%29%20AND%20sprint%20in%20openSprints%28%29%20AND%20resolution%20%3D%20Unresolved%20order%20by%20updated%20DESC'"
