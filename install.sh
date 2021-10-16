#!/bin/bash

echo "installing"

systemctl stop moonbeam.service && cd /var/lib/alphanet-data/ && rm -rf moonbeam && RESULT=$(curl --silent "https://api.github.com/repos/PureStake/moonbeam/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && echo $RESULT && wget https://github.com/PureStake/moonbeam/releases/download/$RESULT/moonbeam && chmod +x /var/lib/alphanet-data/moonbeam && cd ~ && systemctl enable moonbeam.service && systemctl start moonbeam.service && echo -n > tut.log && journalctl -u moonbeam.service > /root/tut.log --since "1970-01-01" -n 30 --no-pager && cd ~
