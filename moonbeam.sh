#!/bin/bash

sudo apt-get update && sudo apt-get upgrade -y

RESULT=$(curl --silent "https://api.github.com/repos/PureStake/moonbeam/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && echo $RESULT && wget https://github.com/PureStake/moonbeam/releases/download/$RESULT/moonbeam

adduser moonbase_service --system --no-create-home

mkdir /var/lib/alphanet-data && chown moonbase_service /var/lib/alphanet-data

cp ./moonbeam /var/lib/alphanet-data

chmod +x /var/lib/alphanet-data/moonbeam

if [ ! $PORTA_NODENAME ]; then
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
EOF

[Install]
WantedBy=multi-user.target

systemctl enable moonbeam.service && systemctl start moonbeam.service

journalctl -f -u moonbeam.service
