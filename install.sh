#!/bin/bash

echo "installing"

ALL_VERSIONS=$(curl --silent "https://api.github.com/repos/PureStake/moonbeam/releases" | jq -r ".[].tag_name")
VERSION=""
for v in $ALL_VERSIONS
do
    echo $v
    if [[ $v =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]
    then
        VERSION=$v
        break
    fi
done

systemctl stop moonbeam.service

cd /var/lib/alphanet-data/
rm -f moonbeam
wget https://github.com/PureStake/moonbeam/releases/download/$VERSION/moonbeam
chmod +x /var/lib/alphanet-data/moonbeam
chmod 777 -R /var/lib/alphanet-data/

cd ~
systemctl enable moonbeam.service
systemctl start moonbeam.service
echo -n > tut.log
journalctl -u moonbeam.service > /root/tut.log --since "2021-01-01" -n 60 --no-pager

echo "done"
