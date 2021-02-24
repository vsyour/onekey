# onekey
一键部署Swarm获得空投100万枚BZZ代币

QQ群： 397745473

vultr OS: CentOS/Ubuntu/Debian 测试通过

![](https://i.imgur.com/e6EQhuP.png)

图文教程： https://vksec.com/2021/02/22/162.%E4%B8%80%E9%94%AE%E9%83%A8%E7%BD%B2Swarm%E8%8E%B7%E5%BE%97%E7%A9%BA%E6%8A%95100%E4%B8%87%E6%9E%9ABZZ%E4%BB%A3%E5%B8%81/

执行：
```
wget --no-check-certificate -O /root/run.sh https://git.io/JtHhx && chmod 755 /root/run.sh && bash /root/run.sh
```
领取代币： https://vksec.com/2021/02/24/163.SwarmBee/


```
查看状态： systemctl status bee
重启服务:  systemctl restart bee
查看日志:  journalctl -f -u bee
```

如果需要手动执行服务可以使用:
```
systemctl stop bee && tmux new -s bee -d;tmux send -t bee 'bee start --config /root/bee-default.yaml' Enter && tmux a -t bee
```

水龙头领币地址： https://faucet.ethswarm.org/
领币查询： https://goerli.etherscan.io/



