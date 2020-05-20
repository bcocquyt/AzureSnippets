$location = $PSScriptRoot

# Load Template Configuration
$config_json = (Get-Content (Join-Path -Path $location -ChildPath "..\Template\template_values.json") -Raw)
$config = (ConvertFrom-Json -InputObject $config_json)

#Apply Template on arm parameter files
$ArmFiles = Get-ChildItem -Path (Join-Path -Path $location -ChildPath "..\ARM\*parameters.json")

foreach ($file in $ArmFiles) {
	$content = (Get-Content -Path $file -Raw)
	$changed = $false

	foreach ($item in $config){
		$key = '#{'+$item.Name+'}#'
		$value = $item.Value
		if ($content -match $key){
			Write-Host "$file matched $key}"
			$content = ($content -replace "$key","$value")
			$changed = $true
		}
	}

	if ($changed) {
		Write-Host "Changed: $file.Name"
		Set-Content -Path ($file.Directory.FullName+"\" + $file.BaseName + "_untemplatized.json") -Value $content
	}
}