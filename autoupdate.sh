#!/bin/bash

RESULT=$(curl --silent "https://api.github.com/repos/PureStake/moonbeam/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

VERSIONNOW=$(/var/lib/alphanet-data/moonbeam --version | grep -oP "(\d+)\.(\d+)\.(\d+)")
VERSIONNOW="v$VERSIONNOW"

if [ "$RESULT" != "$VERSIONNOW" ]; then
    sh ./install.sh
fi
