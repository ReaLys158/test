#!/bin/bash

cd /root

docker stop moonbeam

docker rm moonbeam

sudo apt-get update

rm install.sh

rm autoupdate.sh

rm -rf /var/lib/alphanet-data

mkdir /var/lib/alphanet-data

adduser moonbase_service --system --no-create-home

chown moonbase_service /var/lib/alphanet-data

cd /var/lib/alphanet-data

sudo apt -y install jq 

ALL_VERSIONS=$(curl --silent "https://api.github.com/repos/PureStake/moonbeam/releases" | jq -r ".[].tag_name")
RESULT=""
for v in $ALL_VERSIONS
do
    if [[ $v =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]
    then
        RESULT=$v
        break
    fi
done

echo $RESULT

wget https://github.com/PureStake/moonbeam/releases/download/$RESULT/moonbeam

chmod +x /var/lib/alphanet-data/moonbeam

chmod 777 -R /var/lib/alphanet-data/

cd ~

touch /root/tut.log

if [ ! $MOONBEAM_NODENAME ]; then
    read -e -p "Enter your node name: " MOONBEAM_NODENAME
    echo 'export MOONBEAM_NODENAME='${MOONBEAM_NODENAME}' >> $HOME/.bash_profile
fi

echo -e '\n\e[42mYour node name:' $MOONBEAM_NODENAME '\e[0m\n'
. $HOME/.bash_profile
source ~/.bash_profile

sleep 5

sudo tee <<EOF >/dev/null /etc/systemd/system/moonbeam.service
[Unit]
Description="Moonbase Alpha systemd service"
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=on-failure
RestartSec=10
User=moonbase_service
SyslogIdentifier=moonbase
SyslogFacility=local7
KillSignal=SIGHUP
ExecStart=/var/lib/alphanet-data/moonbeam \
     --port 30333 \
     --rpc-port 9933 \
     --ws-port 9944 \
     --execution wasm \
     --wasm-execution compiled \
     --pruning=archive \
     --state-cache-size 1 \
     --base-path /var/lib/alphanet-data \
     --chain alphanet \
     --name "$MOONBEAM_NODENAME" \
     -- \
     --port 30334 \
     --rpc-port 9934 \
     --ws-port 9945 \
     --pruning=archive \
     --name="$MOONBEAM_NODENAME (Embedded Relay)"

[Install]
WantedBy=multi-user.target
EOF

systemctl enable moonbeam.service

systemctl start moonbeam.service

cd /root

wget https://raw.githubusercontent.com/ReaLys158/test/main/install.sh

chmod +x install.sh

wget https://raw.githubusercontent.com/ReaLys158/test/main/autoupdate.sh

chmod +x autoupdate.sh

(crontab -u $(whoami) -l; echo "*/10 * * * * ./autoupdate.sh" ) | crontab -u $(whoami) -

sleep 20

systemctl stop moonbeam.service

tar -cvzf alphanet-data.tar.gz /var/lib/alphanet-data

systemctl start moonbeam.service 

journalctl -u moonbeam.service > /root/tut.log --since "2021-01-01" -n 60 --no-pager

cat tut.log
