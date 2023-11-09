
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Azure Web App Authentication and Authorization Problems

This incident type refers to issues related to user authentication and authorization in an Azure web application. This can happen due to incorrect configuration of authentication and authorization settings, such as identity provider settings, application roles, and access control. Resolving this incident requires verifying and correcting these settings to ensure proper user authentication and authorization in the application.

### Parameters

```shell
export WEBAPP_NAME="PLACEHOLDER"
export RESOURCE_GROUP_NAME="PLACEHOLDER"
export APPLICATION_ID="PLACEHOLDER"
export SUBSCRIPTION_ID="PLACEHOLDER"
export TOKEN_AUDIENCE_URL="PLACEHOLDER"
export CLIENT_ID="PLACEHOLDER"
export CLIENT_SECRET="PLACEHOLDER"
export TOKEN_ISSUER_URL="PLACEHOLDER"
```

## Debug

### Check if the web app is running

```shell
az webapp show --name ${WEBAPP_NAME} --resource-group ${RESOURCE_GROUP_NAME} --query "state"
```

### Check if authentication and authorization is enabled for the web app

```shell
az webapp auth show --name ${WEBAPP_NAME} --resource-group ${RESOURCE_GROUP_NAME} --query "enabled"
```

### Check if the identity provider is correctly configured

```shell
az webapp identity show --name ${WEBAPP_NAME} --resource-group ${RESOURCE_GROUP_NAME}
```

### Check if the application roles are correctly configured

```shell
az ad app show --id ${APPLICATION_ID}
```

### Check if access control is correctly configured

```shell
az role assignment list --assignee ${APPLICATION_ID} --scope /subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP_NAME}
```

## Repair

### Check and update the authentication and authorization settings in the Azure web application and verify that they are correctly configured.

```shell
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
```