#!/bin/bash

folders=(
  "alacritty"
  "zsh"
  "nvim"
  "karabiner"
  "tmux"
  "git"
  "gh"
)
submodules=(
  "dotfiles-rakentaa"
  "dotfiles-maritimeoptima"
)

for folder in "${folders[@]}"
do
  echo "Stowing $folder"
  stow -D $folder
  stow $folder
done

for submodule in "${submodules[@]}"
do
  echo "----------------------------"
  echo "Stowing submodule $submodule"
  if [ -f "$submodule/stow.sh" ]; then
    cd $submodule 
    echo "Running stow.sh in $submodule"
    ./stow.sh
    cd -
  else
    echo -e "\tNo stow.sh found in $submodule"
  fi
done
