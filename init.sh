#!/bin/sh
if !(type "vim" > /dev/null 2>&1); then
  sudo apt install vim
fi
if !(type "zsh" > /dev/null 2>&1); then
  sudo apt install zsh
fi
if !(type "asdf" > /dev/null 2>&1); then
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf
fi
if !(type "git" > /dev/null 2>&1); then
  sudo apt install git
fi
if !(type "gawk" > /dev/null 2>&1); then
  sudo apt install gawk
fi
if !(type "fzf" > /dev/null 2>&1); then
  sudo apt install fzf
fi
# install zinit
sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"

chsh -s $(which zsh)
