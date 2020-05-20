param (
    [string][parameter(Mandatory=$true)] $subscriptionId,
    [string][parameter(Mandatory=$true)] $userName,
    [string][parameter(Mandatory=$true)] $keyVaultName
)

# Below permissions match the default "Key, Secret & Certificate Management"-template.
[String[]] $permissionsToSecrets = ("get","list","set","delete","recover","backup","restore")
[String[]] $permissionsToKeys = ("get","list","update","create","import","delete","recover","backup","restore")
[String[]] $permissionsToCertificates = ("get","list","update","create","import","delete","recover","Managecontacts","Getissuers","Listissuers","Setissuers","Deleteissuers","Manageissuers","Purge")

# Login to Azure if needed
if (-not (Get-AzureRmContext)) { Login-AzureRmAccount }

if ($userName -match "@hotmail.com"){
    $userName = (($userName -replace "@","_") + '#EXT#@' + ($userName -replace "@hotmail","hotmail.onmicrosoft"))
    #$username_parts = $userName.Split('@')
    #$userName = ($username_parts[0] + '@' + ($userName -replace "@hotmail","hotmail.onmicrosoft"))
}

$userObjectId = (Get-AzureRmADUser -UserPrincipalName $userName).Id

# Select the correct subscription
Select-AzureRmSubscription -SubscriptionId $subscriptionId

try{
    # Create/Update an AccessPolicy for the specified user, with the specified permissions.
    Set-AzureRmKeyVaultAccessPolicy -VaultName $keyVaultName -ObjectId $userObjectId -PermissionsToSecrets $permissionsToSecrets -PermissionsToKeys $permissionsToKeys -PermissionsToCertificates $permissionsToCertificates
    Write-Information "Access policy has been created."
}
catch
{
    $errorMessage = $_.Exception.Message
    Write-Error "Failed to create access policy: $errorMessage"
}