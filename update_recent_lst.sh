#!/bin/bash

# IP list to ckeck

ips=(
    "82.64.170.162"
    "178.150.176.166"
    "43.135.144.127"
    "38.180.234.197"
    "82.67.131.236"
    "89.213.150.45"
    "209.126.8.6"
    "94.191.153.190"
    "81.9.127.10"
    "82.66.161.84"
    "34.1.33.150"
    "34.1.2.195"
    "43.153.17.166"
    "178.212.194.73"
    "178.249.213.181"
    "93.38.52.49"
    "120.35.45.164"
    "188.94.33.33"
    "35.208.202.76"
    "217.76.158.158"
    "35.211.14.30"
    "34.0.50.72"
    "34.0.152.211"
    "146.71.78.134"
    "81.9.126.78"
    "188.126.61.18"
    "68.146.246.131"
    "37.166.7.233"
    "73.207.65.241"
    "95.203.10.208"
    "67.2.221.142"
    "185.17.154.232"
    "37.169.140.95"
    "5.42.199.102"
    "193.124.112.72"
    "2.34.93.62"
    "216.238.76.129"
    "2.233.89.77"
    "178.68.148.157"
    "117.182.120.156"
    "188.116.128.51"
    "188.165.77.50"
    "35.217.54.252"
    "35.207.204.134"
    "216.238.79.112"
    "62.171.132.0"
    "194.158.219.102"
    "178.120.162.47"
    "213.64.123.80"
    "90.233.208.133"
    "72.0.243.163"
    "38.15.41.236"
    "86.217.243.230"
    "178.20.45.143"
    "159.224.197.220"
    "35.207.18.193"
    "35.215.126.105"
    "35.213.49.238"
    "188.226.7.147"
    "46.72.31.248"
    "46.250.224.119"
    "46.250.241.212"
    "8.209.212.71"
    "167.179.167.186"
)


# recent.lst location
recent_lst="/opt/mochimo/d/recent.lst"

# creating tmp list for valid ips
valid_ips=()



# checking port 2095
echo "Checking IPs on port 2095..."
for ip in "${ips[@]}"; do
    echo -n "Checking $ip on port 2095... "

    # try to connect on port 2095
    nc -z -w 1 $ip 2095

    # check the exit code of nc
    if [ $? -eq 0 ]; then
        echo "Port 2095 is open"
        # add valid ip to list
        valid_ips+=("$ip")
    else
        echo "Port 2095 is closed or unreachable"
    fi
done





# if no valid ip stop the script
if [ ${#valid_ips[@]} -eq 0 ]; then
    echo "No Valids IPs found. Canceling the update."
    exit 1
fi

# Stop mochimo service
echo "Stoping service mochimo..."
sudo systemctl stop mochimo.service

# Rename the recent.lst file with timestamp
timestamp=$(date +%Y%m%d_%H%M%S)
echo "Renaming recent.lst to recent_$timestamp.lst"
sudo mv "$recent_lst" "/opt/mochimo/d/recent_$timestamp.lst"

# making new recent.lst
echo "Building new recent.lst with valid IPs..."
echo "# Peer list (saved by node)" | sudo tee "$recent_lst" > /dev/null
for ip in "${valid_ips[@]}"; do
    echo "$ip" | sudo tee -a "$recent_lst" > /dev/null
done

# Restart service mochimo
echo "Restarting service mochimo..."
sudo systemctl start mochimo.service

echo "Finished"
echo ""
echo "Now your miner will reconnect to your updated node, just wait 3 minuts, it takes some time, and during these 3 minuts wait it s normal if you see a lot of messages like ...Aborted..."
echo "Just wait 3 minutes and all should be ok"

echo "and to revert/uninstall to the previous situation, your original recent.lst file is in /opt/mochimo/d folder"
