#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
install_gost(){
    check_git
    git clone https://github.com/bobkjl/Gost-Utils.git
chmod -R 777 Gost-Utils && cd Gost-Utils && bash gost-Utils.sh
}

check_git() {
	if [ -x "$(command -v git)" ]; then
		echo "git is installed"
		# command
	else
		echo "Install Git"
		# command
		install_git
	fi
}

install_git() {
	yum install git
    git init
}

install_gost