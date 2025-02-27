#!/bin/bash


if [[ -z "$NGROK_TOKEN" ]]; then
  echo "Please set 'NGROK_TOKEN'"
  exit 2
fi

if [[ -z "$USER_PASS" ]]; then
  echo "Please set 'USER_PASS' for user: $USER"
  exit 3
fi

echo "### Install ngrok ###"

#sudo tar -xvzf ~/Downloads/ngrok-v3-stable-linux-amd64.tgz -C /usr/local/bin

wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
tar zxvf  ngrok-v3-stable-linux-amd64.tgz
chmod +x ./ngrok

echo "### Update user: $USER password ###"
echo -e "$USER_PASS\n$USER_PASS" | sudo passwd "$USER"

echo "### Start ngrok proxy for 22 port ###"


rm -f .ngrok.log
./ngrok authtoken "$NGROK_TOKEN"
./ngrok tcp 22 --log ".ngrok.log" &

sleep 10
HAS_ERRORS=$(grep "command failed" < .ngrok.log)

if [[ -z "$HAS_ERRORS" ]]; then
  echo ""
  echo "=========================================="
  echo "To connect: $(grep -o -E "tcp://(.+)" < .ngrok.log | sed "s/tcp:\/\//ssh $USER@/" | sed "s/:/ -p /")"
  echo "=========================================="
else
  echo "$HAS_ERRORS"
  exit 4
fi
