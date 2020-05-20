param (
	# Target Subscription
	[Parameter(Mandatory=$true)][string] $subscriptionId,

	# Resource Group Name
	[Parameter(Mandatory=$true)][string] $resourceGroupName,

	# Resource Group Location
	[Parameter(Mandatory=$true)][string] $resourceGroupLocation,

	# ARM Template file
	[Parameter(Mandatory=$true)][string] $templateFile,

	# ARM Parameter File
	[Parameter(Mandatory=$false)][string] $ParameterFileName
)

# Untemplatize
invoke-expression -Command (Join-Path -Path $PSScriptRoot 'untemplatize.ps1')

if (-not (Test-Path $templateFile)) {
	$templateFile = Join-Path -Path $PSScriptRoot $templateFile
}

if (-not $ParameterFileName){
	$ParameterFileName = Join-Path -Path (Get-Item $templateFile).Directory.FullName  ((Get-Item $templateFile).BaseName + '.parameters_untemplatized.json')
	if (-not (Test-Path $ParameterFileName)) {
		$ParameterFileName = Join-Path -Path (Get-Item $templateFile).Directory.FullName  ((Get-Item $templateFile).BaseName + '.parameters.json')
	}
}

if (-not (Test-Path $ParameterFileName)) {
	$ParameterFileName = Join-Path -Path $PSScriptRoot $ParameterFileName
}

$deploymentName = 'Scripted_Deployment_'+ (Get-Date  -Format "yyyMMdd")

New-AzureRmResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation -Verbose -Force

$deployment = (New-AzureRmResourceGroupDeployment -Name $deploymentName -ResourceGroupName $resourceGroupName -TemplateFile $templateFile -TemplateParameterFile $ParameterFileName)

Write-Host "Outputs:"
foreach ($key in $deployment.Outputs.Keys) { Write-Host ($key.Substring(0,1).ToUpper() + $key.Substring(1) +  ' ' + $deployment.Outputs[$key].Value) }

# Add Or Update new keys in template configuration file
$location = $PSScriptRoot

# Load Template Configuration
$config_json = (Get-Content (Join-Path -Path $location -ChildPath "..\Template\template_values.json") -Raw)
$config = (ConvertFrom-Json -InputObject $config_json)
$changes = 0

foreach ($key in $deployment.Outputs.Keys) {
	$CorrectedKey = $key.Substring(0,1).ToUpper() + $key.Substring(1)
	if (-not ($config | Where-Object {$_.Name -eq $CorrectedKey})){
		$config = $config + (Select-Object @{n='Name'; e={$CorrectedKey}},@{n='Type'; e={'Auto'}},@{n='Value'; e={$deployment.Outputs[$key].Value}} -InputObject '')
		$changes += 1
	}
	else {
		($config | Where-Object {$_.Name -eq $CorrectedKey}).Value = $deployment.Outputs[$key].Value
		($config | Where-Object {$_.Name -eq $CorrectedKey}).Type = 'Auto'
		$changes += 1
	}
}

if ($changes -gt 0){
	$config_json = ($config | ConvertTo-Json)
	Copy-Item -Path (Join-Path -Path $location -ChildPath "..\Template\template_values.json") -Destination (Join-Path -Path $location -ChildPath "..\Template\template_values.json.bak")
	Set-Content -Path (Join-Path -Path $location -ChildPath "..\Template\template_values.json") -Value $config_json
}