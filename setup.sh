#!/bin/bash

# 隠しファイルは展開する
for f in .??*; do
	[[ "$f" == ".git" ]] && continue
	[[ "$f" == ".gitignore" ]] && continue
	[[ "$f" == ".DS_Store" ]] && continue

	if [ -d "$HOME/$f" ]; then
		echo "$f already exists."
		read -p "Do you want to replace it? [y/n] " yn
		case $yn in
			y ) ln -snfv "$(pwd)/$f" "$HOME/$f";;
			n ) ;;
			* ) echo "invalid"; exit 1;;
		esac
	elif [ -e "$HOME/$f" ]; then
		echo "$f already exists."
		read -p "Do you want to replace it? [y/n] " yn
		case $yn in
			y ) ln -snfv "$(pwd)/$f" "$HOME/$f";;
			n ) ;;
			* ) echo "invalid"; exit 1;;
		esac
	else
		ln -snfv "$(pwd)/$f" "$HOME/$f"
	fi
done

# update and install ansible
# apt install -y python3-pip
# pip install ansible
if type "ansible" > /dev/null 2>&1; then
	echo "install ansible"

	if type "pacman" > /dev/null 2>&1; then
		sudo pacman -Syu

		sudo pacman -S ansible
	elif type "apt" > /dev/null 2>&1; then
		sudo apt update
		sudo apt upgrade

		sudo apt install software-properties-common
		sudo add-apt-repository --yes --update ppa:ansible/ansible
		sudo apt install ansible
	elif type "yum" > /dev/null 2>&1; then
		sudo yum update

		sudo yum install ansible
	elif type "brew" > /dev/null 2>&1; then
		sudo brew update
		sudo brew upgrade

		sudo brew install ansible
	else
		echo "Unsupported OS."
		exit 1
	fi

	if [ $? -ne 0 ]; then
		echo "error: cannot install ansible"
		exit 1
	fi

	echo "installed"
fi

# ansible
cd ansible

# base
read -p "install base-tools? [y/n] " yn
case $yn in
	y ) ansible-playbook playbook.yml -K -t base;;
	n ) ;;
	* ) echo "invalid"; exit 1;;
esac

# vim


# golang
read -p "install golang? [y/n] " yn
case $yn in
	y ) ansible-playbook playbook.yml -K -t golang;;
	n ) ;;
	* ) echo "invalid"; exit 1;;
esac

# asdf
read -p "install asdf? [y/n] " yn
case $yn in
	y ) ansible-playbook playbook.yml -K -t asdf;;
	n ) ;;
	* ) echo "invalid"; exit 1;;
esac

# nodejs
read -p "install nodejs which depends on asdf? [y/n] " yn
case $yn in
	y ) ansible-playbook playbook.yml -K -t nodejs;;
	n ) ;;
	* ) echo "invalid"; exit 1;;
esac

# python
read -p "install python which depends on asdf? [y/n] " yn
case $yn in
	y ) ansible-playbook playbook.yml -K -t python;;
	n ) ;;
	* ) echo "invalid"; exit 1;;
esac

# python3
read -p "install python3 which depends on asdf? [y/n] " yn
case $yn in
	y ) ansible-playbook playbook.yml -K -t python3;;
	n ) ;;
	* ) echo "invalid"; exit 1;;
esac

# rust
read -p "install rust? [y/n] " yn
case $yn in
	y ) ansible-playbook playbook.yml -K -t rust;;
	n ) ;;
	* ) echo "invalid"; exit 1;;
esac

# modern command
read -p "install modern commands which depends on rust? [y/n] " yn
case $yn in
	y ) ansible-playbook playbook.yml -K -t commands;;
	n ) ;;
	* ) echo "invalid"; exit 1;;
esac

# ruby
read -p "install ruby which depends on asdf? [y/n] " yn
case $yn in
	y ) ansible-playbook playbook.yml -K -t ruby;;
	n ) ;;
	* ) echo "invalid"; exit 1;;
esac

# perl
read -p "install perl? [y/n] " yn
case $yn in
	y ) ansible-playbook playbook.yml -K -t perl;;
	n ) ;;
	* ) echo "invalid"; exit 1;;
esac

# neovim
read -p "install neovim? [y/n] " yn
case $yn in
	y ) ansible-playbook playbook.yml -K -t neovim;;
	n ) ;;
	* ) echo "invalid"; exit 1;;
esac

# chisel
read -p "install chisel? [y/n] " yn
case $yn in
	y ) ansible-playbook playbook.yml -K -t chisel;;
	n ) ;;
	* ) echo "invalid"; exit 1;;
esac


