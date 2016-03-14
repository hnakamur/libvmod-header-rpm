#!/bin/bash
source .env
WHO=$(whoami)
COPR_LOGIN=${COPR_LOGIN:-$WHO}
read -p "Enter copr login (default: $COPR_LOGIN): " LOGIN
COPR_LOGIN=${LOGIN:-$COPR_LOGIN}

COPR_USERNAME=${COPR_USERNAME:-$WHO}
read -p "Enter copr username (default: $COPR_USERNAME): " USERNAME
COPR_USERNAME=${USERNAME:-$COPR_USERNAME}

read -p "Enter copr token: (enter to use default): " -s TOKEN
COPR_TOKEN=${TOKEN:-$COPR_TOKEN}
echo ''

cat <<EOF > .env
COPR_LOGIN=$COPR_LOGIN
COPR_USERNAME=$COPR_USERNAME
COPR_PWD=$COPR_TOKEN
EOF
