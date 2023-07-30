param name string
param tags object = {}
param keyVaultName string
@secure()
param secretValue string

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  name: name
  parent: keyVault
  tags: tags
  properties: {
    value: secretValue
  }
}

output keyVaultSecretName string = keyVaultSecret.name
