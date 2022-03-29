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

for folder in "${folders[@]}"
do
  echo "Stowing $folder"
  stow $folder
done
