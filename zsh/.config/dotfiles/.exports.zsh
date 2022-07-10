export GOPATH="${HOME}/.go"
export GOROOT="$(brew --prefix golang)/libexec"
export PATH="$PATH:${GOPATH}/bin:${GOROOT}/bin"
test -d "${GOPATH}" || mkdir "${GOPATH}"
test -d "${GOPATH}/src/github.com" || mkdir -p "${GOPATH}/src/github.com"
test -d "${GOPATH}/src/bitbucket.org" || mkdir -p "${GOPATH}/src/bitbucket.org"

export PATH="$PATH:~/bin"
export DEV_ENVPATH=~/code/work
export DEFAULT_DEV_ENV=maritimeoptima
export GPG_TTY=$(tty)

export SQUARESPACE_WEBSITE='sheep-rhino-ms3x'


function pure_symbol {
    if [[ $(ps -f | grep "telepresence" | grep -v "grep"|wc -l) -ge 1 ]]; then
        if [ -z "$TELEPRESENCE_ROOT" ]; then
        PS1=$'\e[31m\λ \e[0m'
        else
            PS1=$'\e[43m\[T]\e[0m '
        fi
    else
        PS1='λ '
    fi
}

[ ${ZSH_VERSION} ] && precmd() { pure_symbol; }

# function called every time shell is about to draw prompt
#myprompt() {
  #if [ ${ZSH_VERSION} ]; then
    ## Zsh prompt expansion syntax
    #PS1='$(echo Hello, it is now $(date))'
  #elif [ ${BASH_VERSION} ]; then
    ## Bash prompt expansion syntax
    #PS1='\[\e[31m\]\u\[\e[0m\]@\[\e[31m\]\h \[\e[36m\]\w \[\e[37m\]\$ \[\e[0m\]'
  #fi
#}


git_prompt() {
 ref=$(git symbolic-ref HEAD | cut -d'/' -f3)
 echo $ref
}
#export PURE_PROMPT_SYMBOL="\\w:\$(pure_symbol)\$"
#export PURE_PROMPT_SYMBOL="\\w:\$(git branch 2>/dev/null | grep '^*' | colrm 1 2)\$"

export PURE_GIT_DOWN_ARROW='⍱'
export PURE_GIT_UP_ARROW='৳'
export PURE_GIT_UNTRACKED_DIRTY='⛈'
#export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_ADDR=http://vault.infrastructure:8200

# Kafka 
export KAFKA_TEST_POD="kafka-test-client"
export ZOOKEEPER_ADDR="kafka-zookeeper:2181"
export KAFKA_ADDR="kafka:9092"

# ECR namespace
export ECR_NAMESPACE="maritime-optima/microservices/"

export ANDROID_SDK=$HOME/Library/Android/sdk
export ANDROID_HOME=$ANDROID_SDK
export JAVA_HOME=$(brew --prefix java)
export PATH="$PATH:$ANDROID_SDK/emulator"
export PATH="$PATH:$ANDROID_SDK/tools"
export PATH="$PATH:$ANDROID_SDK/platform-tools"
export LD_LIBRARY_PATH=$ANDROID_SDK/tools/lib:$LD_LIBRARY_PATH
export AWS_ENVIRONMENT="development"
export EDITOR=nvim
export MO_USER=bjarte
export GOPRIVATE="github.com/MaritimeOptima"
export PYTHONPATH="/Applications/usdpython/USD/lib/python:$PYTHONPATH"
export PATH="/Applications/usdpython/USD:$PATH"
export PATH="/Applications/usdpython/usdzconvert:$PATH"

# Setup a local bin path 
mkdir -p ~/bin
export PATH=$PATH:"~/bin"
