export PROJECT_SEARCH_DEPTH=3
function list-projects {
  project_roots=(
    "$HOME/personal"
    "$HOME/work"
    "$HOME/dotfiles"
  )

  # Loop over project roots and find ll directories that contain a .git folder
  for project_root in "${project_roots[@]}"; do
    for dir in $(find $project_root -maxdepth $PROJECT_SEARCH_DEPTH -type d); do
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

  # The name is the last two directories in the path
  # This is to avoid duplicates
  NAME=$(echo $PROJECT_PATH | awk -F/ '{print $(NF-1)"/"$NF}')
  PANE_NAME=$(echo $PROJECT_PATH| awk -F/ '{print $NF}')

  # Check if there is a session with the same name, if there is attach to that
  tmux has-session -t=$NAME > /dev/null 2>&1
  if [ $? -eq 1 ]; then
    tmux new-session -s $NAME -n $PANE_NAME -d -c $PROJECT_PATH
    tmux send-keys -t $NAME "cd $PROJECT_PATH && clear" C-m
  fi

  if [[ -n "$TMUX" ]]; then
    tmux switch -t $NAME
  else
    tmux attach-session -t $NAME -c $PROJECT_PATH 
  fi
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

