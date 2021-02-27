#!/bin/bash
#
# This is a Shell script for configure and start bee-clef + bee.
#
# Copyright © 2015-2099 vksec <QQ Group: 397745473>
#
# Reference URL:
# https://medium.com/ethereum-swarm/swarm-is-airdropping-1-000-000-bzz-bd3b706918d3
# https://docs.ethswarm.org/docs/
# https://www.vksec.com

echo "
+----------------------------------------------------------------------
| Configure And Start bee-clef + bee FOR CentOS/Ubuntu/Debian
+----------------------------------------------------------------------
| Copyright © 2015-2099 vksec (https://www.vksec.com) All rights reserved.
+----------------------------------------------------------------------
| The Can Use will systemctl status bee when installed.
+----------------------------------------------------------------------
";sleep 5
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
LANG=en_US.UTF-8
cd ~


logPath='/root/bee-run.log'
cashlogPath='/root/bee-cash.log'
passPath='/root/bee-pass.txt'
swapEndpoint='https://goerli.prylabs.net'
cashScriptPath='/root/bee-cashout.sh'

homedir=$HOME
red='\e[91m'
green='\e[92m'
yellow='\e[93m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'
_red() { echo -e ${red}$*${none}; }
_green() { echo -e ${green}$*${none}; }
_yellow() { echo -e ${yellow}$*${none}; }
_magenta() { echo -e ${magenta}$*${none}; }
_cyan() { echo -e ${cyan}$*${none}; }

# Root
[[ $(id -u) != 0 ]] && echo -e "\n You must be ${red}root ${none}to run this script ( Enter: sudo su) ${yellow}~(^_^) ${none}\n" && exit 1

PM="apt-get"
sys_bit=$(uname -m)

case $sys_bit in
i[36]86)
	v2ray_bit="32"
	caddy_arch="386"
	;;
'amd64' | x86_64)
	v2ray_bit="64"
	caddy_arch="amd64"
	;;
*armv6*)
	v2ray_bit="arm32-v6"
	caddy_arch="arm6"
	;;
*armv7*)
	v2ray_bit="arm32-v7a"
	caddy_arch="arm7"
	;;
*aarch64* | *armv8*)
	v2ray_bit="arm64-v8a"
	caddy_arch="arm64"
	;;
*)

	echo -e " 
	LoL ... This ${red}junk script${none} does not support your system.。 ${yellow}(-_-) ${none}

	Note: Only support Ubuntu 16+ / Debian 8+ / CentOS 7+ system
	" && exit 1
	;;
esac

# check os
if [[ $(command -v apt-get) || $(command -v yum) ]] && [[ $(command -v systemctl) ]]; then
	if [[ $(command -v yum) ]]; then
		PM="yum"
	fi
else
	echo -e " 
	LoL ... This ${red}junk script${none} does not support your system.。 ${yellow}(-_-) ${none}

	Note: Only support Ubuntu 16+ / Debian 8+ / CentOS 7+ system
	" && exit 1
fi

createSwarmService(){
    date "+【%Y-%m-%d %H:%M:%S】 Installing the Swarm Bee service" 2>&1 | tee -a $logPath
	if [ ! -f /etc/systemd/system/bee.service ]; then
	cat >> /etc/systemd/system/bee.service << EOE
[Unit]
Description=Bee Bzz Bzzzzz service
After=network.target
StartLimitIntervalSec=0
[Service]
Type=simple
Restart=always
RestartSec=60
User=root
ExecStart=/usr/local/bin/bee start --config $homedir/bee-default.yaml
[Install]
WantedBy=multi-user.target
EOE
	else date "+【%Y-%m-%d %H:%M:%S】 There is already a service" 2>&1 | tee -a $logPath
fi

systemctl daemon-reload
systemctl enable bee
systemctl start bee
}

getCashoutScript(){
	if [ ! -f $cashScriptPath ]; then
		date "+【%Y-%m-%d %H:%M:%S】 Installing a script for cashing checks" 2>&1 | tee -a $logPath
	    wget -O $cashScriptPath https://gist.githubusercontent.com/ralph-pichler/3b5ccd7a5c5cd0500e6428752b37e975/raw/7ba05095e0836735f4a648aefe52c584e18e065f/cashout.sh && chmod a+x $cashScriptPath
	else
	    date "+【%Y-%m-%d %H:%M:%S】 '$cashScriptPath' File already exists" 2>&1 | tee -a $logPath
	fi
	echo "*/60 * * * * root    /bin/bash $cashScriptPath cashout-all >> $cashlogPath >/dev/null 2>&1" >> /etc/crontab
	
	
}


createConfig(){
	date "+【%Y-%m-%d %H:%M:%S】 Start Create Config" 2>&1 | tee -a $logPath
	if [ ! -f $homedir/bee-default.yaml ]; then
	cat >> $homedir/bee-default.yaml << EOF
api-addr: :1633
bootnode:
- /dnsaddr/bootnode.ethswarm.org
clef-signer-enable: false
clef-signer-endpoint: ""
config: /root/.bee.yaml
cors-allowed-origins: []
data-dir: /root/.bee
db-capacity: "5000000"
debug-api-addr: :1635
debug-api-enable: true
gateway-mode: false
global-pinning-enable: false
help: false
nat-addr: ""
network-id: "1"
p2p-addr: :1634
p2p-quic-enable: false
p2p-ws-enable: false
password: ""
password-file: ${passPath}
payment-early: "1000000000000"
payment-threshold: "10000000000000"
payment-tolerance: "50000000000000"
resolver-options: []
standalone: false
swap-enable: true
swap-endpoint: ${swapEndpoint}
swap-factory-address: ""
swap-initial-deposit: "100000000000000000"
tracing-enable: false
tracing-endpoint: 127.0.0.1:6831
tracing-service-name: bee
verbosity: 3
welcome-message: ""
EOF
	else date "+【%Y-%m-%d %H:%M:%S】 The configuration file already exists!" 2>&1 | tee -a $logPath
fi
}

checkDesk(){	
	desk=`df |grep "/dev/vda1"|awk '{print $5}'|awk -F '%' {'print $1'}`
	if [ $desk -gt 90 ];then
	    date "+【%Y-%m-%d %H:%M:%S】 Error: Hard disk usage reaches $desk%!" 2>&1 | tee -a $logPath
		systemctl restart bee-clef
		systemctl restart bee
	else
	    date "+【%Y-%m-%d %H:%M:%S】 Info: Hard disk usage $desk%!" 2>&1 | tee -a $logPath
	fi
}

Auto_Swap(){
    swap=$(free |grep Swap|awk '{print $2}')
	if [ "${swap}" -gt 1 ];then
	    echo "Swap total sizse: $swap";
		return;
    fi
	
	swapFile="/var/swapfile"
	dd if=/dev/zero of=$swapFile bs=1M count=1025
	mkswap -f $swapFile
	swapon $swapFile
	echo "$swapFile    swap    swap    defaults    0 0" >> /etc/fstab
	
	swap=`free |grep Swap|awk '{print $2}'`
	if [ $swap -gt 1 ];then
	    echo "Swap total sizse: $swap";
		return;
	fi
	
	sed -i "/\/var\/swapfile/d" /etc/fstab
	rm -f $swapFile
}


Install_Main(){
    startTime=`date +%s`
	
	if [ ! -f "${passPath}" ]; then
	    MEM_TOTAL=$(free -g|grep Mem|awk '{print $2}')
        if [ "${MEM_TOTAL}" -le "1" ];then
		    Auto_Swap
        fi
		
		date "+【%Y-%m-%d %H:%M:%S】 Generate ${passPath}" 2>&1 | tee -a $logPath
		passwd=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c32;echo`
		echo  $passwd > $passPath;
		date "+【%Y-%m-%d %H:%M:%S】 Your node wallet password: " && cat $passPath  2>&1 | tee -a $logPath
		
		date "+【%Y-%m-%d %H:%M:%S】 Start Installing packages" 2>&1 | tee -a $logPath
		date "+【%Y-%m-%d %H:%M:%S】 Start Installing Swarm Bee" 2>&1 | tee -a $logPath
		curl -s https://raw.githubusercontent.com/ethersphere/bee/master/install.sh | TAG=v0.5.1 bash
		if [ "${PM}" = "yum" ]; then
		    ${PM} -y update
		    ${PM} -y install curl wget tmux jq
			date "+【%Y-%m-%d %H:%M:%S】 Start Installing Bee Clef" 2>&1 | tee -a $logPath
			wget https://github.com/ethersphere/bee-clef/releases/download/v0.4.7/bee-clef_0.4.7_amd64.rpm && rpm -i bee-clef_0.4.7_amd64.rpm
        elif [ "${PM}" = "apt-get" ]; then
		    ${PM} -y update
		    ${PM} -y install curl wget tmux jq
			date "+【%Y-%m-%d %H:%M:%S】 Start Installing Bee Clef" 2>&1 | tee -a $logPath
			wget https://github.com/ethersphere/bee-clef/releases/download/v0.4.7/bee-clef_0.4.7_amd64.deb && dpkg -i bee-clef_0.4.7_amd64.deb
        fi
		createConfig
		getCashoutScript
		createSwarmService
		
		echo ''
		echo -e "\e[42mInstallation completed!\e[0m"; echo ''; echo 'Your node password:' && cat $passPath && echo '' && echo -e "Please backup the password file: \e[42m$passPath\e[0m";
		sleep 3
		echo ''
		echo 'To activate the node, replenish with tokens according to the instructions:'
		echo 'https://vksec.com/2021/02/24/163.SwarmBee/'
		echo ''
		echo -e 'Is the node up and running? Check with the command \e[42msystemctl status bee\e[0m'
		echo -e 'Show the work log of bees. Check with the command \e[42mjournalctl -f -u bee\e[0m'
		sleep 10
		address="0x`cat ~/.bee/keys/swarm.key | jq '.address'|sed 's/\"//g'`" && echo ${address}
		echo -e " Go to Swarm official https://discord.gg/r9sBAqnw, start chat #bee-russian"
		echo -e " enter \e[42msprinkle ${address}\e[0m"
		echo ''
	
		#write out current crontab
		#crontab -l > mycron
		#echo new cron into cron file
		echo "*/5 * * * *  root    $homedir/run.sh >/dev/null 2>&1 >> $logPath >/dev/null 2>&1" >> /etc/crontab
		#install new cron file
		#crontab mycron
		#rm -f mycron
		/etc/init.d/cron restart
		
		endTime=`date +%s`
		((outTime=($endTime-$startTime)/60))
		echo -e "Time consumed:\033[32m $outTime \033[0mMinute!"
	else
	    checkDesk
	fi
}

Install_Main
