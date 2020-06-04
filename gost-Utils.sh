#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
sh_ver="1.2.7"
github="raw.githubusercontent.com/bobkjl/gost-Utils/master"

# 设置字体颜色函数
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"

function blue(){
    echo -e "\033[34m\033[01m $1 \033[0m"
}
function green(){
    echo -e "\033[32m\033[01m $1 \033[0m"
}
function greenbg(){
    echo -e "\033[43;42m\033[01m $1 \033[0m"
}
function red(){
    echo -e "\033[31m\033[01m $1 \033[0m"
}
function redbg(){
    echo -e "\033[37;41m\033[01m $1 \033[0m"
}
function yellow(){
    echo -e "\033[33m\033[01m $1 \033[0m"
}
function white(){
    echo -e "\033[37m\033[01m $1 \033[0m"
}


#check version

Update(){
    echo -e "当前版本为 [ ${sh_ver} ]，开始检测最新版本..."
    sh_new_ver=$(wget --no-check-certificate -qO- "http://${github}/gost-Utils.sh"|grep 'sh_ver="'|awk -F "=" '{print $NF}'|sed 's/\"//g'|head -1)
    [[ -z ${sh_new_ver} ]] && echo -e "${Error} 检测最新版本失败 !" && start_menu
    if [[ ${sh_new_ver} != ${sh_ver} ]]; then
        echo -e "发现新版本[ ${sh_new_ver} ]，是否更新？[Y/n]"
        read -p "(默认: y):" yn
        [[ -z "${yn}" ]] && yn="y"
        if [[ ${yn} == [Yy] ]]; then
            wget -N --no-check-certificate http://${github}/gost-Utils.sh && bash gost-Utils.sh
            echo -e "脚本已更新为最新版本[ ${sh_new_ver} ] !"
        else
            echo && echo "    已取消..." && echo
        fi
    else
        echo -e "当前已是最新版本[ ${sh_new_ver} ] !"
        sleep 5s
        start_menu
    fi
}

#function

gostonline(){
    wget -qO /etc/profile.d/gostonline.sh https://raw.githubusercontent.com/bobkjl/gostonline/master/gostonline.sh||{
        echo "脚本不存在，请通过github提交issue通知作者"
        exit 1
    }
    echo 
}

setupService(){
    wget -qO /usr/local/bin/gostonline.sh https://raw.githubusercontent.com/bobkjl/gostonline/master/gostonline.sh||{
        echo "脚本不存在，请通过github提交issue通知作者"
        exit 1
    }
    echo 


cat > /lib/systemd/system/gostonline.service <<\EOF
[Unit]
Description=Gost配置文件开机自启

[Service]
ExecStart=/bin/bash /usr/local/bin/gostonline.sh

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable gostonline > /dev/null 2>&1
service gostonline stop > /dev/null 2>&1
service gostonline start > /dev/null 2>&1
}

check_wget() {
	if [ -x "$(command -v wget)" ]; then
		blue "wget is installed"
		# command
	else
		echo "Install wget"
		# command
		install_wget
	fi
}

install_wget(){
       yum install wget
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

gost_stop(){
while :
do
echo "请输入要停止的隧道PID：(Ctrl+C退出)"
read id
kill -9 $id
echo "成功停止PID为 $id 的隧道！"
done
clear
start_menu
}

gost_running(){
    green "下面是正在运行中的隧道:"
ps -ef | grep "gost" | grep -v "$0" | grep -v "grep" 
echo "----------------------------"
gost_stop
}

install_gost(){
    clear
     `wget https://github.com/ginuerzh/gost/releases/download/v2.11.0/gost-linux-amd64-2.11.0.gz`
                `gunzip gost-linux-amd64-2.11.0.gz`
                `mv gost-linux-amd64-2.11.0 gost`
                `chmod +x gost`
                echo "gost安装成功"
                sleep 5s
        start_menu
}

set_Client(){
    clear
        echo "==============================================================="
        echo "程序：GOST安装程序 客户端"
        echo "系统：Centos7.x、Ubuntu、Debian等"
        echo "==============================================================="
        echo
    white "本脚本支持 普通协议 和 Relay协议 两种对接方式"
    green "请选择对接方式(默认普通协议)"
    yellow "[1] 普通协议(部分传输类型支持UDP)"
    yellow "[2] Relay协议（全传输类型支持UDP）"
    echo
    read -e -p "请输入数字[1~2](默认1)：" vnum
    [[ -z "${vnum}" ]] && vnum="1" 
	if [[ ${vnum} == [12] ]]; then
        echo ————————————选择传输类型————————————
        green "[1] tls"
        green "[2] mtls"
        green "[3] ws"
        green "[4] mws"
        green "[5] wss"
        green "[6] mwss"
        green "[7] 自定义协议（请参考官方文档，不会就不要选择）"
        read -p "输入选择:" opt
        echo " "
        if [ "$opt" = "1" ]; then
        tunnelType="tls"

        elif [ "$opt" = "2" ]; then
        tunnelType="mtls"

        elif [ "$opt" = "3" ]; then
        tunnelType="ws"

        elif [ "$opt" = "4" ]; then
        tunnelType="mws"

        elif [ "$opt" = "5" ]; then
        tunnelType="wss"

        elif [ "$opt" = "6" ]; then
        tunnelType="mwss"

        elif [ "$opt" = "7" ]; then
        read -p "自定义协议:" answer
          if [ -z "$answer" ]; then
             tunnelType="ws"

          else
             tunnelType=$answer
          fi
        else
        echo -e "输入错误"
        set_Client
        fi
        green "使用前请准备好 ${Red_font_prefix}中转机端口、落地机地址、落地机端口、内网端口${Font_color_suffix}"
        read -p "中转机端口 :" clientPort
        read -p "落地机地址 :" serviceAddr
        read -p "落地机端口:" servicePort
        green "请输入隧道传输端口，有些机器屏蔽80，8080，443等端口，若有屏蔽，请输入其他端口，如不用修改,可直接回车下一步"
        read -e -p "请输入隧道传输端口(默认值80)：" tunnelPort
        [[ -z "${tunnelPort}" ]] && tunnelPort="80"
        echo -e "隧道类型：${tunnelType}\n中转机端口：${clientPort}\n落地机地址：${serviceAddr}\n落地机端口：${servicePort}\n隧道传输端口：${tunnelPort}\n"
        echo -e "确认参数正确？[Y/n]"
        read -p "(默认: y):" yn
        [[ -z "${yn}" ]] && yn="y"
        if [[ ${yn} == [Yy] ]]; 
        then
            echo -e "是否生成日志？[Y/n]"
           read -p "(默认: y):" yynn
           [[ -z "${yynn}" ]] && yynn="y"
           if [[ ${yynn} == [Yy] ]]; 
           then
           creatlog="1.log"
           else
           creatlog="/dev/null"
           fi
                if [ "${vnum}" = "1" ]; then
                cmd="nohup ./gost -L=tcp://:"${clientPort}"/"${serviceAddr}":"${servicePort}" -L=udp://:"${clientPort}"/"${serviceAddr}":"${servicePort}" -F="${tunnelType}"://"${serviceAddr}":"${tunnelPort}" >"${creatlog}" 2>&1 & "
            echo -e "$cmd\n"
            eval $cmd
            echo -e "客户端隧道部署成功！"
            echo -e "加入开机自启动!"
            sed -i "/gost_start(){/ a\\$cmd" gost_start.sh
            autostart
                elif [ "${vnum}" = "2" ]; then
                cmd="nohup ./gost -L=tcp://:"${clientPort}"/"${serviceAddr}":"${servicePort}" -L=udp://:"${clientPort}"/"${serviceAddr}":"${servicePort}" -F="relay+${tunnelType}"://"${serviceAddr}":"${tunnelPort}" >"${creatlog}" 2>&1 & "
            echo -e "$cmd\n"
            eval $cmd
            echo -e "客户端隧道部署成功！"
              echo -e "加入开机自启动!"
            sed -i "/gost_start(){/ a\\$cmd" gost_start.sh
            autostart
                fi
        else
                set_Client
        fi
    else
     echo -e "输入错误"
        set_Client
    fi   
}

set_Server(){
    clear
        echo "==============================================================="
        echo "程序：GOST安装程序 服务端"
        echo "系统：Centos7.x、Ubuntu、Debian等"
        echo "==============================================================="
        echo
    white "本脚本支持 普通协议 和 Relay协议 两种对接方式"
    green "请选择对接方式(默认普通协议)"
    yellow "[1] 普通协议(部分传输类型支持UDP)"
    yellow "[2] Relay协议（全传输类型支持UDP）"
    echo
    read -e -p "请输入数字[1~2](默认1)：" vnum
    [[ -z "${vnum}" ]] && vnum="1" 
	if [[ ${vnum} == [12] ]]; then
        echo ————————————选择传输类型————————————
        green "[1] tls"
        green "[2] mtls"
        green "[3] ws"
        green "[4] mws"
        green "[5] wss"
        green "[6] mwss"
        green "[7] 自定义协议（请参考官方文档，不会就不要选择）"
        read -p "输入选择:" opt
        echo " "
        if [ "$opt" = "1" ]; then
        tunnelType="tls"

        elif [ "$opt" = "2" ]; then
        tunnelType="mtls"

        elif [ "$opt" = "3" ]; then
        tunnelType="ws"

        elif [ "$opt" = "4" ]; then
        tunnelType="mws"

        elif [ "$opt" = "5" ]; then
        tunnelType="wss"

        elif [ "$opt" = "6" ]; then
        tunnelType="mwss"

        elif [ "$opt" = "7" ]; then
        read -p "自定义协议:" answer
          if [ -z "$answer" ]; then
             tunnelType="ws"

          else
             tunnelType=$answer
          fi
        else
        echo -e "输入错误"
        set_Server
        fi
        green "使用前请准备好 ${Red_font_prefix}隧道传输端口${Font_color_suffix}"
        green "请输入隧道传输端口，有些机器屏蔽80，8080，443等端口，若有屏蔽，请输入其他端口，如不用修改,可直接回车下一步"
        read -e -p "请输入隧道传输端口(默认值80)：" tunnelPort
        [[ -z "${tunnelPort}" ]] && tunnelPort="80"
        echo -e "隧道传输端口：${tunnelPort}\n隧道类型：${tunnelType}\n"
        echo -e "确认参数正确？[Y/n]"
        read -p "(默认: y):" yn
        [[ -z "${yn}" ]] && yn="y"
        if [[ ${yn} == [Yy] ]]; 
        then
          echo -e "是否生成日志？[Y/n]"
          read -p "(默认: y):" yynn
          [[ -z "${yynn}" ]] && yynn="y"
          if [[ ${yynn} == [Yy] ]]; 
          then
          creatlog="1.log"
          else
          creatlog="/dev/null"
          fi
                if [ "${vnum}" = "1" ]; then
                 cmd="nohup ./gost -L="${tunnelType}"://:"${tunnelPort}" >"${creatlog}" 2>&1 &"
            echo -e "$cmd\n"
            eval $cmd
            echo -e "服务端端隧道部署成功！"
              echo -e "加入开机自启动!"
            sed -i "/gost_start(){/ a\\$cmd" gost_start.sh
            autostart
                elif [ "${vnum}" = "2" ]; then
                 cmd="nohup ./gost -L="relay+${tunnelType}"://:"${tunnelPort}" >"${creatlog}" 2>&1 &"
            echo -e "$cmd\n"
            eval $cmd
            echo -e "服务端端隧道部署成功！"
              echo -e "加入开机自启动!"
            sed -i "/gost_start(){/ a\\$cmd" gost_start.sh
            autostart
                fi
        else
                set_Server
        fi
    else
     echo -e "输入错误"
        set_Server
    fi   
}

check_log(){
    cat 1.log
}

rm_log(){
    rm -f 1.log
}

autostart(){
            chmod -R 777 /etc/rc.d/rc.local
            chmod -R 777 /root/Gost-Utils/gost_start.sh
            echo "bash /root/Gost-Utils/gost_start.sh">/etc/rc.d/rc.local
}

start_menu(){
    echo -e " GOST 一键安装管理脚本 ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}"
    echo "###        Gost Utils             ###"
    echo "###       By @DerrickZH           ###"
    echo "###     Update: 2020-04-22        ###"
    echo ""
    green "[0] 检查更新"
    echo ————————————GOST管理————————————
    green "[1] 安装GOST（默认已安装）"
    echo ————————————隧道配置管理————————————
    green "[2] 配置 客户端"
    green "[3] 配置 服务端"
#   echo -e "[4] 捐赠开发者"
    echo ————————————其他管理————————————
    green "[4] 管理运行中的隧道"
    #green "[5] 停止运行中的隧道"
    green "[5] 查看日志"
    green "[6] 删除日志"
    echo "请输入选项以继续，ctrl+C退出"

    opt=0
     read opt
    if [ "$opt" = "1" ]; then
        install_gost

    elif [ "$opt" = "2" ]; then
        set_Client
        
    elif [ "$opt" = "3" ]; then
        set_Server

    elif [ "$opt" = "4" ]; then
        gost_running
        
    elif [ "$opt" = "5" ]; then
        check_log

    elif [ "$opt" = "6" ]; then
        rm_log

    elif [ "$opt" = "0" ]; then
        Update
    
    else
        echo -e "输入错误"
        bash gost-Utils.sh
    fi
}
gostonline
#setupService
clear
start_menu
