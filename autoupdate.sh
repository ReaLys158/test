#!/bin/bash

RESULT=$(curl --silent "https://api.github.com/repos/PureStake/moonbeam/releases/latest" | jq -r ".tag_name")

VERSIONNOW=$(/var/lib/alphanet-data/moonbeam --version | grep -oP "(\d+)\.(\d+)\.(\d+)")
VERSIONNOW="v$VERSIONNOW"

if [[ "$RESULT" != "$VERSIONNOW" ]] && [[ $RESULT =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    sh ./install.sh
fi
