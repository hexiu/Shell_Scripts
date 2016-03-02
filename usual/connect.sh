#!/bin/bash

#get cookie
curl -c cookie.txt -A "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 6.0)" -H "Accept-Language: en-us,en;q=0.5" http://222.24.19.190:8080/portal/index_default.jsp &> getcookie.log

if [ "$?" == "0" ]; then
        echo "get cookie ok~~~";
fi

#ip=$(ifconfig | egrep 'inet addr:222' | cut -d: -f2 | awk '{print $1}')
ip=$(ifconfig | egrep '222' | awk '{print $2}')

#user=fengjingchao
#pwd=85383224

user=xiyoucube
pwd=metc513

PostData="userName=$user&userPwd=$(echo -n $pwd | base64)&serviceType=&isSavePwd=on&userurl=http%3A%2F%2Fwww.baidu.com&userip=$ip&basip=&language=Chinese&portalProxyIP=222.24.19.190&portalProxyPort=50200&dcPwdNeedEncrypt=1&assignIpType=0&assignIpType=0&appRootUrl=http://222.24.19.190:8080/portal/&manualUrl=&manualUrlEncryptKey=rTCZGLy2wJkfobFEj0JF8A=="

while true;
do
    ping -c 1 www.baidu.com -W 1 &>/dev/null;
    if [ "$?" == "0" ]; then
            sleep 1s;
    else
        curl -b cookie.txt -A "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 6.0)" -H "Accept-Language: en-us,en;q=0.5" -d "$PostData" "http://222.24.19.190:8080/portal/pws?t=li" > tmp.log;
        grep "\"errorNumber\":1" tmp.log > /dev/null;
        if [ "$?" == "0" ]; then
                echo "激活成功~~~";
        else
                awk -F ',' '{print $2 }' tmp.log | awk -F ':' '{ print $3 }';
                echo "失败";
                exit 0;
		break;

        fi
        sleep 10s;
    fi
done

