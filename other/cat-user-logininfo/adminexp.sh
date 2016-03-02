#!/bin/bash
#

MOUTH=`date | cut -d" " -f2`

rm -fr /root/message /root/finish_user


echo "finished user : " > /root/finish_user
for I in `ls /home/`;do
echo "======================================================="
	echo -e "\033[42m$I\033[0m" | tee -a /root/message
	echo " $I
N"| /root/admin.sh | tee -a /root/message 
	DAY=`last $I  | grep -o "\<$MOUTH.*" |awk '{print $1" "$2}'|sort -n | uniq | wc -l`
	if [ $DAY -ge 1 ];then
		echo $I >> /root/finish_user
		echo $I wrinte in. 
	fi 



done
echo -e "\nOK... logmessage in /root/message." 
cat /root/finish_user
