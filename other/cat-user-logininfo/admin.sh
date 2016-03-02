#1/bin/bash
#

read -p "Enter username :" USERNAME

while ! id $USERNAME &>/dev/null ;do
	echo "user don't exist."
	read -p "Enter username :" USERNAME
done

NUM=`last $USERNAME |grep "192.168"| wc -l`
MOUTH=`date |cut -d' ' -f2`
LAST=`last $USERNAME  | grep -o "\<$MOUTH.*" |awk '{print $1" "$2}'|sort -n | uniq | wc -l`
echo -e "Different Time total login :$NUM, This mounth login days:$LAST\n"

[ ! $LAST -eq 0 ]&&echo "`date | awk '{ print $6 }'`:"
last $USERNAME  | grep -o "[A-Z].* $MOUTH.*" | awk '{print $1" "$2" "$3}' |sort -u

read -p "Cat more ? (Y/N):" JUD 
[ $JUD == Y -o $JUD == y ]&&last ${USERNAME}| more



