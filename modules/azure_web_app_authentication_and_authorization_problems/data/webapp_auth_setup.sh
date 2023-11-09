#!/bin/bash

# Set variables
resource_group=${RESOURCE_GROUP_NAME}
webapp_name=${WEBAPP_NAME}
token_audience_url=${TOKEN_AUDIENCE_URL}
client_id=${CLIENT_ID}
client_secret=${CLIENT_SECRET}
token_issuer_url=${TOKEN_ISSUER_URL}

# Verify that the resource group exists
if az group show --name $resource_group &>/dev/null; then
  echo "Resource group exists: $resource_group"
else
  echo "Resource group not found: $resource_group"
  exit 1
fi

# Verify that the web app exists
if az webapp show --name $webapp_name --resource-group $resource_group &>/dev/null; then
  echo "Web app exists: $webapp_name"
else
  echo "Web app not found: $webapp_name"
  exit 1
fi

# Check the authentication and authorization settings
if az webapp auth show --name $webapp_name --resource-group $resource_group --query enabled &>/dev/null; then
  echo "Authentication and authorization enabled"
else
  echo "Authentication and authorization not enabled"
  echo "Enabling authentication and authorization..."
  az webapp auth update --name $webapp_name \ 
  --resource-group $resource_group \
  --enabled true \
  --action LoginWithAzureActiveDirectory \
  --aad-allowed-token-audiences $token_audience_url \
  --aad-client-id $client_id \
  --aad-client-secret $client_secret \
  --aad-token-issuer-url $token_issuer_url
  echo "Authentication and authorization enabled"
fi