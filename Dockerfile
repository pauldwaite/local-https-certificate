FROM alpine:3.19.1

# https://letsencrypt.org/docs/certificates-for-localhost/
# https://stackoverflow.com/questions/16480846/x-509-private-public-key
# https://www.openssl.org/docs/man3.0/man1/openssl-req.html
# https://www.feistyduck.com/library/openssl-cookbook/online/openssl-command-line/signing-your-own-certificates.html
# https://www.feistyduck.com/library/openssl-cookbook/online/openssl-command-line/creating-certificates-valid-for-multiple-hostnames.html


RUN apk update && apk add openssl && apk add envsubst

COPY --chmod=644 <<"END_CERTIFICATE_CONFIG" /usr/local/bin/certificate_config.template.conf
  [req]
  distinguished_name = req_distinguished_name
  x509_extensions = v3_req
  prompt = no

  [req_distinguished_name]
  CN = ${HOSTNAME}

  [v3_req]
  keyUsage = keyEncipherment, dataEncipherment
  extendedKeyUsage = serverAuth
  subjectAltName = @alt_names

  [alt_names]
  DNS.1 =  ${HOSTNAME}
  DNS.2 =*.${HOSTNAME}
END_CERTIFICATE_CONFIG

COPY --chmod=700 <<"END_CREATE_CERTIFICATE" /usr/local/bin/create_certificate.sh
  #!/bin/sh

  envsubst < /usr/local/bin/certificate_config.template.conf > /usr/local/bin/certificate_config.conf

  cat /usr/local/bin/certificate_config.conf

  openssl req \
    -x509 \
    -out    /usr/local/share/${FILENAME} \
    -keyout /usr/local/share/${FILENAME} \
    -newkey rsa:2048 \
    -days ${EXPIRES_IN_DAYS:-730} \
    -nodes \
    -sha256 \
    -config /usr/local/bin/certificate_config.conf \
    -extensions 'v3_req' \

    #-subj '/CN=*.'${HOSTNAME}'/CN='${HOSTNAME}'' \

  chmod 644 /usr/local/share/${FILENAME:-localhost.pem}
END_CREATE_CERTIFICATE

ENTRYPOINT /usr/local/bin/create_certificate.sh
