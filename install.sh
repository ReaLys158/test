#!/bin/bash

echo "installing"

systemctl stop moonbeam.service
cd /var/lib/alphanet-data/
rm -rf moonbeam

ALL_VERSIONS=$(curl -s 'https://api.github.com/repos/PureStake/moonbeam/releases' | jq -r ".[].tag_name")
VERSION=""
for v in $ALL_VERSIONS
do
    if [[ $v =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]
    then
        VERSION=$v
        break
    fi
done

wget https://github.com/PureStake/moonbeam/releases/download/$VERSION/moonbeam
chmod +x /var/lib/alphanet-data/moonbeam

cd ~
systemctl enable moonbeam.service
systemctl start moonbeam.service
echo -n > tut.log
journalctl -u moonbeam.service > /root/tut.log --since "2021-01-01" -n 30 --no-pager

echo "done"
