#! /bin/sh

docker build --tag local-https-certificate .

docker run \
  --env EXPIRES_IN_DAYS=1000 \
  --env FILENAME=pauldwaite_co_uk_localhost.pem \
  --env HOSTNAME='pauldwaite.co.uk.localhost' \
  --volume .:/usr/local/share \
  local-https-certificate
