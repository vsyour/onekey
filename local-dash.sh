#!/bin/bash
# from https://github.com/doristeo/SwarmBeeBzzz

export COLOR_NC='\e[0m' # No Color
export COLOR_GREEN='\e[0;32m'
export COLOR_RED='\e[0;31m'

echo -n "Bee version " ; bee version 
echo ""
echo "Your address:"
curl -s localhost:1635/addresses | jq .ethereum
echo "Your chequebook:"
curl -s localhost:1635/chequebook/address | jq .chequebookaddress
echo ""
if pgrep -x "bee" > /dev/null
then
    echo -e "Bee node is ${COLOR_GREEN}running :)${COLOR_NC}"
    echo -n "Active peers: "; curl -s http://localhost:1635/peers | jq '.peers | length'
else
    echo -e "Bee node is ${COLOR_RED}NOT RUNNING! :(${COLOR_NC}"
fi
echo ""
PS3='Please enter your choice:'
options=("Balance" "Manual cashout" "chequebook --gBzz--> node" "chequebook <--gBzz-- node" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Balance")
            echo "Balance of chequebook:"
            curl -s localhost:1635/chequebook/balance
            ;;
        "Manual cashout")
            echo "Manual cashout (./cashout.sh cashout-all)..."
            ~/cashout.sh cashout-all
            ;;
        "chequebook --gBzz--> node")
            echo "Move gBzz from cheque book to address of node..."
            curl -XPOST -s localhost:1635/chequebook/withdraw\?amount\=1000 | jq
            
            ;;
        "chequebook <--gBzz-- node")
            echo "Move gBzz from node's address to cheque book..."
            curl -XPOST -s localhost:1635/chequebook/deposit\?amount\=1000 | jq
            
            ;;

        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
