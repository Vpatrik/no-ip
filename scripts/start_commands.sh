#!/bin/sh

# based on https://docs.docker.com/config/containers/multi-service_container/

printf "Check and import env variables\n"

printf "Checking filename env variables\n"
if [ -z "$USERNAME_FILE" ] && [ -z "$PASSWORD_FILE" ] && [ -z "$DOMAINS_FILE" ] && [ -z "$INTERVAL_FILE" ]; then
  printf "Secret filenames doesn't exist\n"

  printf "Checking if env variables exist\n"
  if [ -z "$USERNAME" ] && [ -z "$PASSWORD" ] && [ -z "$DOMAINS" ] && [ -z "$INTERVAL" ]; then
    printf "env variables doen't exist\n"
    exit 1
  else
    printf "env variables exist\n"
  fi
else
  printf "Secret filenames exist\n"

  export USERNAME="$(cat $USERNAME_FILE)"
  export PASSWORD="$(cat $PASSWORD_FILE)"
  export DOMAINS="$(cat $DOMAINS_FILE)"
  export INTERVAL="$(cat $INTERVAL_FILE)"
fi

# Start the second process
# start no-ip dns update client
echo "Starting noip-duc"

noip-duc --hostnames "$DOMAINS" --check-interval "$INTERVAL" --username "$USERNAME" --password "$PASSWORD" &

while sleep 10; do

  ps aux | grep noip-duc | grep -q -v grep
  PROCESS_1_STATUS=$?

  if [ $PROCESS_1_STATUS -ne 0 ]; then
    echo "Error."
    exit 1
  fi
done
