#!/bin/bash

sudo apt-get update

rm -rf /var/lib/alphanet-data

mkdir /var/lib/alphanet-data

chown moonbase_service /var/lib/alphanet-data

cd /var/lib/alphanet-data

RESULT=$(curl --silent "https://api.github.com/repos/PureStake/moonbeam/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

echo $RESULT

wget https://github.com/PureStake/moonbeam/releases/download/$RESULT/moonbeam

chmod +x /var/lib/alphanet-data/moonbeam

chmod 777 /var/lib/alphanet-data/

cd ~

touch /root/tut.log

adduser moonbase_service --system --no-create-home

if [ ! $MOONBEAM_NODENAME ]; then
		read -p "Enter your node name: " MOONBEAM_NODENAME
		echo 'export MOONBEAM_NODENAME='${MOONBEAM_NODENAME} >> $HOME/.bash_profile
	fi
	echo -e '\n\e[42mYour node name:' $MOONBEAM_NODENAME '\e[0m\n'
	. $HOME/.bash_profile

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

sleep 5

systemctl enable moonbeam.service

systemctl start moonbeam.service

cd /root

wget https://raw.githubusercontent.com/ReaLys158/test/main/install.sh

chmod +x install.sh

wget https://raw.githubusercontent.com/ReaLys158/test/main/autoupdate.sh

chmod +x autoupdate.sh

(EDITOR=nano crontab -e -l 2>/dev/null; echo "*/60 * * * * ./autoupdate.sh") | crontab -

sleep 15

systemctl stop moonbeam.service

sleep 5

tar -cvzf alphanet-data.tar.gz /var/lib/alphanet-data

sleep 5

systemctl start moonbeam.service 

sleep 5

journalctl -u moonbeam.service > /root/tut.log --since "1970-01-01" -n 30 --no-pager

cat tut.log
