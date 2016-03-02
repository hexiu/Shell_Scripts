#!/bin/bash
#
if [ -z $1 ];then 
    echo "error,no projects "&&exit 2
fi

DIR=/mnt/golang/projects
GOPRO=$1

mkdir -p $DIR/$1/src/$1 $DIR/$1/bin $DIR/$1/pkg
[ -d $DIR/$1 ] && echo " Create Go projects $1 success! pwd: /mnt/golang/projects/$1 "

export GOPATH=$GOPATH:$DIR/$GOPRO && echo "Add GoPath"&&echo "GOPATH $GOPATH"
echo "Please Copy this : export GOPATH=\$GOPATH:$DIR/$1"
