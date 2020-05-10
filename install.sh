#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
install_gost(){
	install_tool
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

install_tool() {
    echo "===> Start to install tool"    
    if [ -x "$(command -v yum)" ]; then
        command -v curl > /dev/null || yum install -y curl
        systemctl stop firewalld.service
        systemctl disable firewalld.service
    elif [ -x "$(command -v apt)" ]; then
        command -v curl > /dev/null || apt install -y curl
    else
        echo "Package manager is not support this OS. Only support to use yum/apt."
        exit -1
    fi 
}

install_gost
