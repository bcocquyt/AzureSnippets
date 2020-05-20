# AzureSnippets
Bits of Code that come in handy when using Microsoft Azure.

Here, you can find examples of ARM scripts to deploy Azure Function App, Service Bus and queue, storage account and a keyvault.

There are also some powershell scripts for the folowing tasks:
* deploy resources for a given arm script (deploy.ps1)

```
.\deploy.ps1 -subscriptionId <subscriptionId> `
	-resourceGroupName <resourceGroup> `
	-resourceGroupLocation <location> `
	-templateFile <templatefile>
```

* generate a parameter file with actual values by replacing template placeholders like #{Template.Variable.Name}# (untemplatize.ps1). This script doesn't need any parameters. It finds all parameter files in the ARM\ folder and generates and untemplatized paramter file when apropriate.
* Create access policies for a given active directory user for a given keyvault.

```
.\Assign AccessPolicy to Keyvault.ps1 `
	-subscriptionId <subscriptionId> `
	-userName <userName> `
    -keyVaultName <keyVaultName>
```


Hope you find these usefull.