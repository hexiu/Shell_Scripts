#!/bin/bash
#by cutyy@qq.com 2015.03
#必须root用户执行
if [[ $EUID -ne 0 ]]; then
   echo "This script. must be run as root" 
   exit 1
fi

set_rhel7_bond_config ()
{
unset OPTIND
while getopts 'b:m:i:n:g:s:t:' opt; do
    case $opt in
        b) bond_name=$OPTARG;;
        m) bond_mode=$OPTARG;;
        i) ip=$OPTARG;;
        n) mask=$OPTARG;;
        g) gateway=$OPTARG;;
        s) bond_opts=$OPTARG;;
        t) network_type=$OPTARG;;
    esac
done
bond_config_file="/etc/sysconfig/network-scripts/ifcfg-$bond_name"
echo $bond_config_file
if [ -f $bond_config_file ]; then
    echo "Backup original $bond_config_file to bondhelper.$bond_name"
    mv $bond_config_file /etc/sysconfig/network-scripts/bondhelper.$bond_name -f
fi

if [ "static" == $network_type ]; then 
    ip_setting="IPADDR=$ip
NETMASK=$mask
GATEWAY=$gateway
USERCTL=no"
else
    ip_setting="USERCTL=no"
fi
cat << EOF > $bond_config_file
DEVICE=$bond_name
ONBOOT=yes
BOOTPROTO=$network_type
$ip_setting
BONDING_OPTS="mode=$bond_mode $bond_opts"
NM_CONTROLLED=no
EOF
}
set_rhel7_ethx_config()  {
    bond_name=$1
    eth_name=$2

    eth_config_file="/etc/sysconfig/network-scripts/ifcfg-$eth_name"
    if [ -f $eth_config_file ]; then
        echo "Backup original $eth_config_file to bondhelper.$eth_name"
        mv $eth_config_file /etc/sysconfig/network-scripts/bondhelper.$eth_name -f
    fi

    cat << EOF  > $eth_config_file
DEVICE=$eth_name
BOOTPROTO=none
ONBOOT=yes
MASTER=$bond_name
SLAVE=yes
USERCTL=no
NM_CONTROLLED=no
EOF
}

##1.从用户取得信息
##2.检查网卡状态
##3.生成配置


##1.从用户取得信息
#get  device name 

read  -p  "键入绑定设备名称，比如:trunk0 eth1 eth2 表示将eth1和eth2绑定为trunk0:" -a ETH
BOND_NAME=${ETH[0]} 
unset ETH[0];

#子网卡数，必须大于1
ETH_NUM=${#ETH[@]}
if [ ${ETH_NUM} -ge 2 ] ; then
	echo "(1/3)绑定后网卡名是 :${BOND_NAME}; 捆绑${ETH_NUM}块网卡，分别是 : ${ETH[*]}"
else
	echo "至少选择2块网卡，请重新运行脚本绑定"
	exit 1
fi 
#get ip config
# $TRUNK_IP  $TRUNK_MASK  $TRUNK_GW  
echo "(2/3)配置绑定网卡的IP，比如: 192.168.1.12 255.255.255.0 192.168.1.1 表示配置IP为192.168.1.12 掩码为255.255.255.0 网关192.168.1.1"
read  -p  "(2/3)直接回车表示使用dhcp方式获取IP:" -a TRUNK_CONFIG

if [ -z ${TRUNK_CONFIG}  ] ; then
        echo "已选择dhcp方式获取IP配置";
        TRUNK_BOOTPROTO=dhcp ;
else 
#提取IP信息
        TRUNK_BOOTPROTO=static;
        TRUNK_IP=${TRUNK_CONFIG[0]};
        TRUNK_MASK=${TRUNK_CONFIG[1]};
        TRUNK_GW=${TRUNK_CONFIG[2]};
        echo  -e "配置信息如下：\n IP是${TRUNK_IP} \t掩码是${TRUNK_MASK}；\t 网关是${TRUNK_GW}；";
fi
read -p "是否继续[yes/no]: " YN
case "$YN" in
 [Yy]|[Yy][Ee][Ss])
 echo "正在执行网卡绑定.."
 ;;
 *)
 exit 1
 ;;
esac


##2.检查网卡状态
for i in ${ETH[*]} ; do 
ethtool $i > /dev/null
if [ $? -ne 0 ] ;then
    echo "获取网卡$i状态异常"
	exit 1
fi
done

##3.生成配置
# $TRUNK_IP  $TRUNK_MASK  $TRUNK_GW  
#set_rhel7_bond_config -b bond0 -m 1 -i 1.1.1.2 -n 255.255.255.0 -g 1.1.1.1 -t static -s "miimon=100 primary=eth0"
if [ ${TRUNK_BOOTPROTO} == 'dhcp' ] ; then
	set_rhel7_bond_config -b  ${BOND_NAME} -m 1 -t dhcp -s "miimon=100 primary=${ETH[0]}"
else
	set_rhel7_bond_config -b ${BOND_NAME} -m 1 -i ${TRUNK_IP} -n ${TRUNK_MASK} -g ${TRUNK_GW} -t static -s "miimon=100 primary=${ETH[1]}"
fi

#set_rhel7_ethx_config bond0 eth0
#set_rhel7_ethx_config bond0 eth1
for i in ${ETH[*]} ; do 
	set_rhel7_ethx_config ${BOND_NAME} $i
done


echo "(3/3)重启网络服务.."
service network restart
echo "完成绑定!"
cat /proc/net/bonding/${BOND_NAME}