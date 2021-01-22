Param(
    [Parameter (Mandatory = $true)]
    [string]$AppServiceName,


    [Parameter (Mandatory = $true)]
    [string]$ResourceGroupName
)  

$connectionName = "AzureRunAsConnection"
try {
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection) {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    }
    else {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

$ErrorActionPreference = "stop"

$appSettingsName = 'WEBSITE_LOAD_CERTIFICATES'

Write-Output "Get AppService: $AppServiceName..."
$webapp = Get-AzWebApp -Name $AppServiceName

$certficateThumbprint = (Get-AzWebAppSSLBinding -WebApp $webapp | Select-Object  -First 1).Thumbprint

Write-Output "Found certificate for $AppServiceName, $certficateThumbprint"

$appsettingsCertificateThumbprint = $webapp.SiteConfig.AppSettings | Where-Object -Property Name -Like  $appSettingsName | Select-Object -ExpandProperty Value

if ( ($null -ne $appsettingsCertificateThumbprint) -and ($certficateThumbprint -ne $appsettingsCertificateThumbprint)) {

    Write-Output "Found new certificate thumprint: $certficateThumbprint ..."
    $appSettingList = $webApp.SiteConfig.AppSettings

    $appsettings = @{}

    ForEach ($kvp in $appSettingList) {
        $appsettings[$kvp.Name] = $kvp.Value
    }

    $appsettings[$appSettingsName] = $certficateThumbprint 
    Write-Output "Setting new appsettings thumbprint value to $certficateThumbprint..." 
    Set-AzWebApp -AppSettings $appSettings -Name $AppServiceName -ResourceGroupName $ResourceGroupName 

}
else{
    Write-Output "No certificate to set..."
}