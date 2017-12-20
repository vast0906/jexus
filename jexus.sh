#!/bin/bash
XZXT_DOWNLOAD_URL="ftp://127.0.0.1"
XZXT_VERSION="123.zip"

JEXUS_DOWNLOAD_URL="http://linuxdot.net"

JEXUS_VERSION="jexus-5.8.1-x64"


check_sys(){
   if [[ -f /etc/redhat-release ]]; then
           release="centos"
   elif cat /etc/issue | grep -q -E -i "debian"; then
           release="debian"
   elif cat /etc/issue | grep -q -E -i "ubuntu"; then
           release="ubuntu"
   elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
           release="centos"
   elif cat /proc/version | grep -q -E -i "debian"; then
           release="debian"
   elif cat /proc/version | grep -q -E -i "ubuntu"; then
           release="ubuntu"
   elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
           release="centos"
   else echo "不支持此类操作系统"; exit 1
   fi
   bit=`uname -m`
}

install_jexus(){
   if !  curl -L -#  $JEXUS_DOWNLOAD_URL/down/$JEXUS_VERSION.tar.gz -o /tmp/$JEXUS_VERSION.tar.gz > /dev/null 2>&1; then
       echo  "JEXUS 下载失败!" && exit 1
   else
        if [ -f /usr/jexus/jwss ];then
            echo "JEXUS 已存在"
        else
            tar -zxf /tmp/$JEXUS_VERSION.tar.gz -C /usr
            cp  /usr/jexus/jws /usr/local/bin/jws
            sed -i 's#^JWS_HOME=\(.*\)#JWS_HOME=/usr/jexus#g' /usr/jexus/jws
            ln -s /usr/jexus/jws /etc/init.d/jws
            echo "/etc/init.d/jws restart"  >> /etc/rc.d/rc.local
            /usr/jexus/jws restart
            if [ $? != 0 ];then
                echo "JEXUS 启动失败"
            fi
        fi 
   fi
}
install_xzxt(){
    if ! wget -N --no-check-certificate $XZXT_DOWNLOAD_URL/$XZXT_VERSION -P /tmp > /dev/null 2>&1; then
        echo  "XZXT 下载失败!" && exit 1
    else
        if [ -d /var/www/default/xz_admin ];then
            echo "XZXT 已存在"
        else
            mkdir -p /var/www/default/
            mv /var/www/default/* /tmp > /dev/null 2>&1
            unzip /tmp/$XZXT_VERSION -d /var/www/default > /dev/null 2>&1
            echo "XZXT 安装完成"
        fi  
    fi
}
init_sys(){
    if [ "$release" = "centos" ];then
        yum install -y wget 
        service iptables stop > /dev/null 2>&1
        chkconfig iptables off > /dev/null 2>&1
        systemctl stop firewalld.service > /dev/null 2>&1
        systemctl disable firewalld.service  > /dev/null 2>&1
    elif [ "$release" = "ubuntu" ];then
        apt-get install wget -y
        service iptables stop > /dev/null 2>&1
        chkconfig iptables off > /dev/null 2>&1
    fi
}

check_sys
init_sys
install_jexus
install_xzxt
