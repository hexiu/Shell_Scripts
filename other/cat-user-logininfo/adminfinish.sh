#!/bin/bash
#
echo "Finish : "
MOUTH=`date | cut -d' ' -f2`
for I in `cat /root/finish_user | grep -v "finish"` ;do
        echo "name: $I"
        echo " $I
N"| /root/admin.sh | tee -a /root/message
        DAY=`last $I  | grep -o "\<$MOUTH.*" |awk '{print $1" "$2}'|sort -n | uniq | wc -l`
echo "--------------------------------------------------------------"
done

