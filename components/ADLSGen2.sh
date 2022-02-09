#!/bin/bash

# Params
resourceGroupLocation="eastus2"
ResourceGroupName="TESTRG2"
storageaccountname="SRGODEMO288"
subscriptionid="6f931dc1-9715-4a59-a849-0c049740fa0f"
email="srgolla@microsoft.com"

# Create RGs
az login
az account set --subscription $subscriptionid
az group create --name $ResourceGroupName --location $resourceGroupLocation

# Create ADLS Gen2 storage accounts
# Modify ADLSGen2ARM.parameters.json file for your own values
az deployment group create --resource-group $ResourceGroupName --template-file ADLSGen2ARM.json --parameters @ADLSGen2ARM.parameters.json storageAccountName=$storageaccountname

az role assignment create --role "Storage Blob Data Contributor"    --assignee $email --scope "/subscriptions/$subscriptionid/resourceGroups/$ResourceGroupName/providers/Microsoft.Storage/storageAccounts/$storageaccountname"

az storage fs create -n inputs --account-name $storageaccountname --auth-mode login
az storage fs create -n outputs --account-name $storageaccountname --auth-mode login