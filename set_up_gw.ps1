param($p1, $p2, $p3, $p4, $p5)
Write-Output "gw_name: $p1"
Write-Output "application_id: $p2"
Write-Output "client_secret: $p3"
Write-Output "tenant: $p4"
Write-Output "recover_key: $p5"

## Install DataGateway module
Write-Output "Install DataGateway module"
Install-Module -Name DataGateway -Confirm:$False -Force

## Variable init
$gw_name=$p1
$application_id=$p2
$client_secret=convertto-securestring $p3 -asplaintext -force
$tenant=$p4
$recover_key=convertto-securestring $p5 -asplaintext -force

# Connect to the service account
Connect-DataGatewayServiceAccount -ApplicationId $application_id -ClientSecret $client_secret -Tenant $tenant

## Check if th GW exist or not
$result=Get-DataGatewayCluster | select Id, Name | where Name -eq $gw_name

if ($result) { # result is not null
  Write-Output "Result returned"
  if ($result.Count -eq 1) {
    Write-Output "One GW return in the result"
    Write-Output "Will Set one ..."
    Set-DataGatewayCluster -GatewayClusterId $result.Id -AllowCloudDatasourceRefresh $true
  } else {
    Write-Output "PROBLEM : More than one GW returned in the result"
  }
} else{
  Write-Output "No result returned for the Gateway name : $gw_name"
  Write-Output "Will Add one ..."
  Install-DataGateway -AcceptConditions
  Add-DataGatewayCluster -Name '${gateway_name}' -OverwriteExistingGateway -RecoveryKey $recover_key
  Add-DataGatewayClusterUser -GatewayClusterId $gw_info.GatewayObjectId -PrincipalObjectId '${principal_objectid}' -AllowedDataSourceTypes $null -Role '${role}'
}
