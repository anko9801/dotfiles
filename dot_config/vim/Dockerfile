FROM ubuntu:20.04

RUN apt-get update
RUN apt-get -y install vim curl git python3-pip
RUN pip3 install neovim
RUN git clone https://github.com/Vane11ope/.files
RUN curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > installer.sh
RUN mkdir ~/.cache/dein
RUN sh ./installer.sh ~/.cache/dein

