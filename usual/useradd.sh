#!/bin/bash 
#
read -p "Enter username:" USERNAME 
until [ $USERNAME == quit ];do

if ! id $USERNAME &>/dev/null ;then
	useradd $USERNAME &>/dev/null 
	 echo "$USERNAME" | passwd --stdin $USERNAME
	echo "Useradd OK..."
else 
	echo "User exist..."
fi

read -p "Enter username:" USERNAME 

done

