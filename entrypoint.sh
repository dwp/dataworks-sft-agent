#!/bin/sh
set -e

export HTTP_PROXY="http://${internet_proxy}:3128"
export HTTPS_PROXY="$HTTP_PROXY"
export NO_PROXY="${non_proxied_endpoints},${dks_fqdn}"

echo "INFO: Checking container configuration..."
if [ -z "${SFT_AGENT_CONFIG_S3_BUCKET}" -o -z "${SFT_AGENT_CONFIG_S3_PREFIX}" ]; then
  echo "ERROR: SFT_AGENT_CONFIG_S3_BUCKET and SFT_AGENT_CONFIG_S3_PREFIX environment variables must be provided"
  exit 1
fi

S3_URI="s3://${SFT_AGENT_CONFIG_S3_BUCKET}/${SFT_AGENT_CONFIG_S3_PREFIX}"

# If either of the AWS credentials variables were provided, validate them
if [ -n "${AWS_ACCESS_KEY_ID}${AWS_SECRET_ACCESS_KEY}" ]; then
  if [ -z "${AWS_ACCESS_KEY_ID}" -o -z "${AWS_SECRET_ACCESS_KEY}" ]; then
    echo "ERROR: You must provide both AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY variables if you want to use access key based authentication"
    exit 1
  else
    echo "INFO: Using supplied access key for authentication"
  fi

  # If either of the ASSUMEROLE variables were provided, validate them and configure a shared credentials fie
  if [ -n "${AWS_ASSUMEROLE_ACCOUNT}${AWS_ASSUMEROLE_ROLE}" ]; then
    if [ -z "${AWS_ASSUMEROLE_ACCOUNT}" -o -z "${AWS_ASSUMEROLE_ROLE}" ]; then
      echo "ERROR: You must provide both the AWS_ASSUMEROLE_ACCOUNT and AWS_ASSUMEROLE_ROLE variables if you want to assume role"
      exit 1
    else
      ASSUME_ROLE="arn:aws:iam::${AWS_ASSUMEROLE_ACCOUNT}:role/${AWS_ASSUMEROLE_ROLE}"
      echo "INFO: Configuring AWS credentials for assuming role to ${ASSUME_ROLE}..."
      mkdir ~/.aws
      cat > ~/.aws/credentials << EOF
[default]
aws_access_key_id=${AWS_ACCESS_KEY_ID}
aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}

[${AWS_ASSUMEROLE_ROLE}]
role_arn=${ASSUME_ROLE}
source_profile=default
EOF
      PROFILE_OPTION="--profile ${AWS_ASSUMEROLE_ROLE}"
    fi
  fi
  if [ -n "${AWS_SESSION_TOKEN}" ]; then
    sed -i -e "/aws_secret_access_key/a aws_session_token=${AWS_SESSION_TOKEN}" ~/.aws/credentials
  fi
else
  echo "INFO: Using attached IAM roles/instance profiles to authenticate with S3 as no AWS_ACCESS_KEY_ID or AWS_SECRET_ACCESS_KEY have been provided"
fi

echo "INFO: Copying SFT-agent configuration file(s) from ${S3_URI} to /app/..."
aws ${PROFILE_OPTION} s3 cp ${S3_URI}/agent-config.yml agent-config.yml
aws ${PROFILE_OPTION} s3 cp ${S3_URI}/agent-application-config.yml agent-application-config.yml

export ACM_KEY_PASSWORD=$(uuidgen -r)
echo "Retrieving acm certs"
acm-cert-retriever \
--acm-cert-arn "${acm_cert_arn}" \
--acm-key-passphrase "$ACM_KEY_PASSWORD" \
--private-key-alias "${private_key_alias}" \
--truststore-aliases "${truststore_aliases}" \
--truststore-certs "${truststore_certs}"

cd /usr/local/share/ca-certificates/
touch data_egress_sft_ca.pem

TRUSTSTORE_ALIASES="${truststore_aliases}"
for F in $(echo $TRUSTSTORE_ALIASES | sed "s/,/ /g"); do
(cat "$F.crt"; echo) >> data_egress_sft_ca.pem;
done
cd ../../../../


echo "INFO: Starting the SFT agent..."
exec java -jar sft-agent.jar server agent-config.yml
