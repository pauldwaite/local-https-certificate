#! /bin/sh

docker run \
  --env EXPIRES_IN_DAYS=1000 \
  --env FILENAME=asterisk_lists_localhost.pem \
  --env HOSTNAME='*.lists.localhost' \
  --volume .:/usr/local/share \
  local-https-certificate
