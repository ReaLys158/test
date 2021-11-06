#!/bin/bash

if [ -f /var/lib/alphanet-data/moonbeam ]; then
    echo "moonbeam found, checking its version"
    
    VERSIONNOW=$(/var/lib/alphanet-data/moonbeam --version | grep -oP "(\d+)\.(\d+)\.(\d+)")
    VERSIONNOW="v$VERSIONNOW"
    
    RESULT=$(curl --silent "https://api.github.com/repos/PureStake/moonbeam/releases/latest" | jq -r ".tag_name")
    
    if [[ "$RESULT" != "$VERSIONNOW" ]] && [[ $RESULT =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "moonbeam is not up to date, installing new version"
        bash ./install.sh
    else
        echo "moonbeam is up to date"
    fi
else
    echo "moonbeam not found, downloading it"
    
    ALL_VERSIONS=$(curl --silent "https://api.github.com/repos/PureStake/moonbeam/releases" | jq -r ".[].tag_name")
    VERSION=""
    for v in $ALL_VERSIONS
    do
        if [[ $v =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]
        then
            VERSION=$v
            break
        fi
    done

    if [ ! -d /var/lib/alphanet-data ]; then
        mkdir /var/lib/alphanet-data
    fi
    
    cd /var/lib/alphanet-data/
    wget https://github.com/PureStake/moonbeam/releases/download/$VERSION/moonbeam
    chmod +x /var/lib/alphanet-data/moonbeam
    chmod 777 -R /var/lib/alphanet-data/
    cd ~
    
    echo "done"
fi
