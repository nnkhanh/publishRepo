#!/bin/sh
export ARM_CLIENT_ID="361f772c-d4ae-43fc-8e46-9d9ab5a2db26"
export ARM_SUBSCRIPTION_ID="9b4c827b-f9d9-4824-9cab-79c59cc8a808"
export ARM_TENANT_ID="00361803-b14b-4604-8809-69c97fa1d059"
export ARM_ACCESS_KEY=$(az keyvault secret show --name terraform-backend-key --vault-name devopstraining --query value -o tsv)
export ARM_CLIENT_SECRET=$(az keyvault secret show --name client-secret-sp1 --vault-name devopstraining --query value -o tsv)
