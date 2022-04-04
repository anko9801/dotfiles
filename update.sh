#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0); pwd)

for f in .??*
do
[[ "$f" == ".git" ]] && continue
[[ "$f" == ".DS_Store" ]] && continue
[[ "$f" == "readme.md" ]] && continue

echo $f
if [ -d "${f}" ]; then
ln -sf $SCRIPT_DIR/$f/ ~/$f
else
ln -sf $SCRIPT_DIR/$f ~/$f
fi
done

ln -sf $SCRIPT_DIR/.gitconfig ~/.gitconfig
