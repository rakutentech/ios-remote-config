#!/bin/sh -e

NOCOLOR='\033[0m'
RED='\033[0;31m'
SECRETS_FILE=Sample/Sample-Secrets.xcconfig

echo "Configuring project's build secrets in $SECRETS_FILE"

#
# New secrets should be added below (following the same format)
#
declare -a vars=(RRC_CONFIG_URL RAS_SUBSCRIPTION_KEY RAS_APPLICATION_IDENTIFIER)
for var_name in "${vars[@]}"
do
  if [ -z "$(eval "echo \$$var_name")" ]; then
    echo "${RED}ERROR:${NOCOLOR} Before building the project you must set environment variable $var_name. See project README for instructions."
  fi
done

# Overwrite secrets xcconfig and add file header
echo "// Secrets configuration for the app." > $SECRETS_FILE
echo "//" >> $SECRETS_FILE
echo "// **DO NOT** add this file to git." >> $SECRETS_FILE
echo "//" >> $SECRETS_FILE
echo "// Auto-generated file. Any modifications will be lost on next 'pod install'" >> $SECRETS_FILE
echo "//" >> $SECRETS_FILE
echo "// Add new secrets configuration in ./scripts/configure-secrets.sh" >> $SECRETS_FILE
echo "//" >> $SECRETS_FILE
echo "// In order to have the // in https://, we need to split it with an empty" >> $SECRETS_FILE
echo "// variable substitution via $() e.g. ROOT_URL = https:/$()/www.endpoint.com" >> $SECRETS_FILE

# Set secrets from environment variables e.g.
# `echo "FOO_VAR = ${FOO_VAR}" >> $SECRETS_FILE`
echo "RRC_CONFIG_URL = ${RRC_CONFIG_URL}" >> $SECRETS_FILE
echo "RAS_SUBSCRIPTION_KEY = ${RAS_SUBSCRIPTION_KEY}" >> $SECRETS_FILE
echo "RAS_APPLICATION_IDENTIFIER = ${RAS_APPLICATION_IDENTIFIER}" >> $SECRETS_FILE
