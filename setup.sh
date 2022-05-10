echo #!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0); pwd)
cd $SCRIPT_DIR

# expand dotfiles
for f in .??*; do
	[[ "$f" == ".git" ]] && continue
	[[ "$f" == ".gitignore" ]] && continue
	[[ "$f" == ".DS_Store" ]] && continue

	if [ -d "$HOME/$f" ]; then
		echo "$f already exists."
		read -p "Do you want to replace it? [y/N] " yn
		case $yn in
			y* ) mv "$HOME/$f" "$HOME/${f}_old"; ln -snfv "$SCRIPT_DIR/$f" "$HOME/$f";;
			n* | * ) ;;
		esac
	elif [ -e "$HOME/$f" ]; then
		echo "$f already exists."
		read -p "Do you want to replace it? [y/N] " yn
		case $yn in
			y* ) ln -snfv "$SCRIPT_DIR/$f" "$HOME/$f";;
			n* | * ) ;;
		esac
	else
		ln -snfv "$SCRIPT_DIR/$f" "$HOME/$f"
	fi
done

# update and install ansible
# apt install -y python3-pip
# pip install ansible
if !(type "ansible" > /dev/null 2>&1); then
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

# Future: divide roles but use shell script
# base
read -p "install base-tools? [Y/n] " yn
case $yn in
	n* ) ;;
	y* | * ) ansible-playbook playbook.yml -K -t base;;
esac

# asdf
read -p "install asdf? [Y/n] " yn
case $yn in
	n* ) ;;
	y* | * ) ansible-playbook playbook.yml -K -t asdf;;
esac

# You should set bashrc for not interactive
if !(type "asdf" > /dev/null 2>&1); then
	echo "Reload .bashrc"
	echo "Please type . ~/.bashrc and run it one more time"
	exit 0
fi

# nodejs
read -p "install nodejs which depends on asdf? [Y/n] " yn
case $yn in
	n* ) ;;
	y* | * ) ansible-playbook playbook.yml -K -t nodejs;;
esac

# deno
read -p "install deno which depends on asdf? [Y/n] " yn
case $yn in
	n* ) ;;
	y* | * ) ansible-playbook playbook.yml -K -t deno;;
esac

# python
read -p "install python which depends on asdf? [Y/n] " yn
case $yn in
	n* ) ;;
	y* | * ) ansible-playbook playbook.yml -K -t python;;
esac

# python3
read -p "install python3 which depends on asdf? [Y/n] " yn
case $yn in
	n* ) ;;
	y* | * ) ansible-playbook playbook.yml -K -t python3;;
esac

# golang
read -p "install golang? [Y/n] " yn
case $yn in
	n* ) ;;
	y* | * ) ansible-playbook playbook.yml -K -t golang;;
esac

# rust
read -p "install rust? [Y/n] " yn
case $yn in
	n* ) ;;
	y* | * ) ansible-playbook playbook.yml -K -t rust;;
esac

# modern command
read -p "install modern commands which depends on rust? [Y/n] " yn
case $yn in
	n* ) ;;
	y* | * ) ansible-playbook playbook.yml -K -t commands;;
esac

# ruby
read -p "install ruby which depends on asdf? [Y/n] " yn
case $yn in
	n* ) ;;
	y* | * ) ansible-playbook playbook.yml -K -t ruby;;
esac

# perl
read -p "install perl? [Y/n] " yn
case $yn in
	n* ) ;;
	y* | * ) ansible-playbook playbook.yml -K -t perl;;
esac

# chisel
read -p "install chisel? [Y/n] " yn
case $yn in
	n* ) ;;
	y* | * ) ansible-playbook playbook.yml -K -t chisel;;
esac

# vim
read -p "install vim plugins through dein? [Y/n] " yn
case $yn in
	n* ) ;;
	y* | * ) ansible-playbook playbook.yml -K -t dein;;
esac

# neovim
read -p "install neovim? [Y/n] " yn
case $yn in
	n* ) ;;
	y* | * ) ansible-playbook playbook.yml -K -t neovim;;
esac


