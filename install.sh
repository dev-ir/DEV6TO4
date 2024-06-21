#!/bin/bash

#add color for text
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
plain='\033[0m'
NC='\033[0m' # No Color

install_jq


# Get server IP
SERVER_IP=$(hostname -I | awk '{print $1}')

# Fetch server country using ip-api.com
SERVER_COUNTRY=$(curl -sS "http://ip-api.com/json/$SERVER_IP" | jq -r '.country')

# Fetch server isp using ip-api.com 
SERVER_ISP=$(curl -sS "http://ip-api.com/json/$SERVER_IP" | jq -r '.isp')



cur_dir=$(pwd)
# check root
#[[ $EUID -ne 0 ]] && echo -e "${RED}Fatal error: ${plain} Please run this script with root privilege \n " && exit 1

init(){

    #clear page .
    clear

    echo "+--------------------------------------------------------------+"
    echo "|  _____   ______ __      __   __   _______   ____   _  _      |"
    echo "| |  __ \ |  ____|\ \    / /  / /  |__   __| / __ \ | || |     |"
    echo "| | |  | || |__    \ \  / /  / /_     | |   | |  | || || |_    |"
    echo "| | |  | ||  __|    \ \/ /  | '_ \    | |   | |  | ||__   _|   |"
    echo "| | |__| || |____    \  /   | (_) |   | |   | |__| |   | |     |"
    echo "| |_____/ |______|    \/     \___/    |_|    \____/    |_|     |"  
    echo "|                                                              |"
    echo "+--------------------------------------------------------------+"
    echo -e "${GREEN}Server Country:${NC} $SERVER_COUNTRY"
    echo -e "${GREEN}Server IP:${NC} $SERVER_IP"
    echo -e "${GREEN}Server ISP:${NC} $SERVER_ISP"
    echo "+---------------------------------------------------------------+"
    echo -e "${GREEN}Please choose an option:${NC}"
    echo "+---------------------------------------------------------------+"
    echo -e "${BLUE}| 1  - Install"
    echo -e "${BLUE}| 2  - Status "
    echo -e "${BLUE}| 3  - Unistall"
    echo -e "${BLUE}| 0  - Exit"
    echo "+---------------------------------------------------------------+"
    echo -e "\033[0m"

    read -p "Enter option number: " choice
    case $choice in
    1)
        install_tunnel
        ;;
    2)
        echo "simple 2"
        ;;
    0)
        echo -e "${GREEN}Exiting program...${NC}"
        exit 0
        ;;
    *)
        echo "Not valid"
        ;;
    esac
        

}


install_tunnel(){

    clear

    echo "+--------------------------------------------------------------+"
    echo "|  _____   ______ __      __   __   _______   ____   _  _      |"
    echo "| |  __ \ |  ____|\ \    / /  / /  |__   __| / __ \ | || |     |"
    echo "| | |  | || |__    \ \  / /  / /_     | |   | |  | || || |_    |"
    echo "| | |  | ||  __|    \ \/ /  | '_ \    | |   | |  | ||__   _|   |"
    echo "| | |__| || |____    \  /   | (_) |   | |   | |__| |   | |     |"
    echo "| |_____/ |______|    \/     \___/    |_|    \____/    |_|     |"  
    echo "|                                                              |"
    echo "+--------------------------------------------------------------+"
    echo -e "${GREEN}Server Country:${NC} $SERVER_COUNTRY"
    echo -e "${GREEN}Server IP:${NC} $SERVER_IP"
    echo -e "${GREEN}Server ISP:${NC} $SERVER_ISP"
    echo "+---------------------------------------------------------------+"
    echo -e "${GREEN}Please choose an option:${NC}"
    echo "+----------------------------------------------------------------+"
    echo -e "${BLUE}| 1  - IRAN"
    echo -e "${BLUE}| 2  - Kharej "
    echo -e "${BLUE}| 0  - Exit"
    echo "+----------------------------------------------------------------+"
    echo -e "\033[0m"

    read -p "Enter option number: " choice_ip

    case $choice_ip in
    1)
        read -p "Enter IRAN IP   : " iran_ip
        read -p "Enter Kharej IP : " kharej_ip

        ip tunnel add 6to4_To_KH mode sit remote ${kharej_ip} local ${iran_ip}
        ip -6 addr add fd4b:fd23:92e9::de01/64 dev 6to4_To_KH
        ip link set 6to4_To_KH mtu 1480
        ip link set 6to4_To_KH up

        ip -6 tunnel add GRE6Tun_To_KH mode ip6gre remote fd4b:fd23:92e9::de02 local fd4b:fd23:92e9::de01
        ip addr add 172.20.20.1/30 dev GRE6Tun_To_KH
        ip link set GRE6Tun_To_KH mtu 1436
        ip link set GRE6Tun_To_KH up


        sysctl net.ipv4.ip_forward=1
        iptables -t nat -A PREROUTING -j DNAT --to-destination 172.20.20.2
        iptables -t nat -A POSTROUTING -j MASQUERADE 


        echo "Setting for IRAN VPS has been done , please complate in kharej vps"
        ping 172.20.20.2

        ;;
    2)
        read -p "Enter IRAN IP   : " iran_ip
        read -p "Enter Kharej IP : " kharej_ip

        ip tunnel add 6to4_To_IR mode sit remote ${iran_ip} local ${kharej_ip}
        ip -6 addr add fd4b:fd23:92e9::de02/64 dev 6to4_To_IR
        ip link set 6to4_To_IR mtu 1480
        ip link set 6to4_To_IR up


        ip -6 tunnel add GRE6Tun_To_IR mode ip6gre remote fd4b:fd23:92e9::de01 local fd4b:fd23:92e9::de02
        ip addr add 172.20.20.2/30 dev GRE6Tun_To_IR
        ip link set GRE6Tun_To_IR mtu 1436
        ip link set GRE6Tun_To_IR up


        ping 172.20.20.1

        ;;
    0)
        echo -e "${GREEN}Exiting program...${NC}"
        exit 0
        ;;
    *)
        echo "Not valid"
        ;;
    esac


}

install_jq() {
    if ! command -v jq &> /dev/null; then
        # Check if the system is using apt package manager
        if command -v apt-get &> /dev/null; then
            echo -e "${RED}jq is not installed. Installing...${NC}"
            sleep 1
            sudo apt-get update
            sudo apt-get install -y jq
        else
            echo -e "${RED}Error: Unsupported package manager. Please install jq manually.${NC}\n"
            read -p "Press any key to continue..."
            exit 1
        fi
    fi
}

# Install jq
init