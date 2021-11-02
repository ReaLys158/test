#!/bin/bash

echo "installing"

systemctl stop moonbeam.service
cd /var/lib/alphanet-data/
rm -f moonbeam

VERSION=$(curl -s 'https://api.github.com/repos/PureStake/moonbeam/releases/latest' | jq -r ".tag_name")
wget https://github.com/PureStake/moonbeam/releases/download/$VERSION/moonbeam
chmod +x /var/lib/alphanet-data/moonbeam

cd ~
systemctl enable moonbeam.service
systemctl start moonbeam.service
echo -n > tut.log
journalctl -u moonbeam.service --since "2021-01-01" -n 30 --no-pager > ~/tut.log

echo "done"
