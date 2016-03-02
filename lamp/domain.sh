#!/bin/bash
#

read -p "Enter your domain:(eg: baidu.com):"  DOMAIN
read -p "Enter your IPaddress(default: 192.168.88.88):" IPADDR

read -p "Enter Port (default:80):" PORT
[ -z $PORT ] && PORT=80
[ -z $IPADDR ]&& IPADDR=192.168.88.88
echo  "zone \"$DOMAIN\" IN { 
		type master; 
		file \"$DOMAIN.zone\"; 
		};" >> /etc/named.conf
echo -e "#$DOMAIN
<VirtualHost $IPADDR:$PORT>
	Servername "www.$DOMAIN" 
	DocumentRoot /www/$DOMAIN 
</Virtualhost> \n" >> /etc/httpd/conf.d/virtualhost.conf 
mkdir /www/$DOMAIN
touch /var/named/$DOMAIN.zone
cat /var/named/xiyouant.com.zone > /var/named/$DOMAIN.zone
sed -i s#xiyouant.com.#$DOMAIN.#g /var/named/$DOMAIN.zone
sed -i s#192.168.88.88#$IPADDR#g /var/named/$DOMAIN.zone
echo -e "<title>For Example!</title>\n<h1>Hello ,Welcome to $DOMAIN</h1>" > /www/$DOMAIN/index.php
service httpd reload &>/dev/null
service named reload &>/dev/null
echo "Your Domain :$DOMAIN ,Create sucess."
echo "Your Website IP&PORT: $IPADDR:$PORT.   ....[OK]."


