echo -e "Now have :\n"
grep -o "zone .*.*" /etc/named.conf |cut -d'"' -f2|sed "1,5d"
echo
read -p "You want to delete(eg:piwik.com):" DOMAIN
[ ! -d /www/$DOMAIN ] && echo " Domain  Error ..." && exit 2
rm -fr /www/$DOMAIN 
[ $? -eq 0 ]&& echo "Input sure ! delete ing ..." || echo "Tnput Error!" 
[ $? -eq 0 ] && sed -i "/zone[[:space:]]\?\"$DOMAIN\"/,+3d" /etc/named.conf
rm -fr /var/named/$DOMAIN.zone 
sed -i "/#$DOMAIN/,+4d" /etc/httpd/conf.d/virtualhost.conf
service httpd reload
service named reload
[ $? -eq 0 ]||echo "Starting named failure..."&&echo "delete finished ."





