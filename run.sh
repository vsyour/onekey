#!/usr/bin/env bash
#
# This is a Shell script for configure and start bee-clef bee.
#
# Copyright (C) 2020 - 2021 vksec <QQ Qun: 397745473>
#
# Reference URL:
# https://www.vksec.com


# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script"
    exit 1
fi

if [ ! -f /root/mypass.txt ]; then
	date "+【%Y-%m-%d %H:%M:%S】 Generate /root/mypass.txt" 2>&1 | tee -a /root/run.log
	echo "ibR8THVExwrIikT9" > /root/mypass.txt;
fi

### debian
## apt install dos2unix;dos2unix run.sh;bash run.sh

if [ ! -d "/check/" ];then
	date "+【%Y-%m-%d %H:%M:%S】 Start to initialize the environment" 2>&1 | tee -a /root/run.log
	apt-get -y update;
	apt -y update;
	apt -y autoremove;
	apt-get -y upgrade;
	apt install -y curl jq;
	
	wget https://github.com/ethersphere/bee-clef/releases/download/v0.4.7/bee-clef_0.4.7_amd64.deb && dpkg -i bee-clef_0.4.7_amd64.deb
	wget https://github.com/ethersphere/bee/releases/download/v0.5.0/bee_0.5.0_amd64.deb && dpkg -i bee_0.5.0_amd64.deb
	wget -O cashout.sh https://gist.githubusercontent.com/ralph-pichler/3b5ccd7a5c5cd0500e6428752b37e975/raw/7ba05095e0836735f4a648aefe52c584e18e065f/cashout.sh && chmod a+x cashout.sh
	echo "*/5 * * * *  root       /root/run.sh >/dev/null 2>&1" >> /etc/crontab
	
	mkdir -p /check/; sed -i 's/mouse=a/mouse-=a/g' /usr/share/vim/vim81/defaults.vim;apt-get install -y tmux unzip && dd if=/dev/zero of=/var/swapfile bs=1M count=2048 && /sbin/mkswap /var/swapfile && /sbin/swapon /var/swapfile && chmod 0600 /var/swapfile && echo "/var/swapfile swap swap defaults 0 0" >>/etc/fstab && echo 'vm.swappiness=10'>> /etc/sysctl.conf && reboot
fi

function check(){
	date "+【%Y-%m-%d %H:%M:%S】 start run check()" 2>&1 | tee -a /root/run.log
	desk=`df |grep "/dev/vda1"|awk '{print $5}'|awk -F '%' {'print $1'}`
	if [ $desk -gt 90 ];then
	    date "+【%Y-%m-%d %H:%M:%S】 $desk is desk error!" 2>&1 | tee -a /root/run.log
		tmux kill-session -t service		
		systemctl restart bee-clef
		chmod 755 /var/lib/bee-clef/clef.ipc
		systemctl restart bee

		#rm -rf /root/.bee/localstore/*;
		tmux new -s service -d;tmux send -t service 'bee-clef-service start' Enter;
		tmux new -s bee -d;tmux send -t bee 'bee start --verbosity 5 --swap-endpoint https://goerli.prylabs.net --debug-api-enable --clef-signer-enable --clef-signer-endpoint /var/lib/bee-clef/clef.ipc --password-file /root/mypass.txt' Enter;
	fi
	
	tmuxNumber=`tmux ls|wc -l`
	if [ $tmuxNumber -lt 4 ];then	    
		date "+【%Y-%m-%d %H:%M:%S】 $tmuxNumber is tmuxNumber error!" 2>&1 | tee -a /root/run.log		
		chmod 755 /var/lib/bee-clef/clef.ipc
		tmux new -s service -d;tmux send -t service 'bee-clef-service start' Enter;
		tmux new -s bee -d;tmux send -t bee 'bee start --verbosity 5 --swap-endpoint https://goerli.prylabs.net --debug-api-enable --clef-signer-enable --clef-signer-endpoint /var/lib/bee-clef/clef.ipc --password-file /root/mypass.txt' Enter;
		tmux new -s cashout -d;tmux send -t cashout 'n=1;while :;do ((n++));echo "Runing [[$n]]";/root/cashout.sh cashout-all 5;sleep 7200;done' Enter;
		tmux new -s urandom -d;tmux send -t urandom 'n=1;while :;do ((n++));echo "Runing [[$n]]";dd if=/dev/urandom of=/tmp/test.txt bs=1M count=20 && curl -F file=@/tmp/test.txt http://localhost:1633/files;sleep 43200;done' Enter;
	fi
}

check