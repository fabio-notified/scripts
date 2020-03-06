${resource-group} = "Notified-Test"

$version = "10.16.3"

$webAppNames = az webapp list  --resource-group ${resource-group} --query [].name | ConvertFrom-Json

$webAppNames | ForEach-Object {
     
    $currentAppName = $_; 

    # Get slot names for web app. 

    $slotNames = az webapp deployment slot list --resource-group ${resource-group} --name $currentAppName --query [].name | ConvertFrom-Json

    $slotNames | ForEach-Object { 
        
        $currentVersion = az webapp config appsettings list --name $currentAppName --resource-group ${resource-group} --slot $_ --query '[?name==`WEBSITE_NODE_DEFAULT_VERSION`]' | ConvertFrom-Json
        
        if ( $currentVersion.value -ne $version) {
            
            # Set the value for slots
            az webapp config appsettings set -g ${resource-group} -n $currentAppName --settings WEBSITE_NODE_DEFAULT_VERSION=$version --slot $_ 
        }
    }

    # Set default slot (ie Production)
    az webapp config appsettings set -g ${resource-group} -n $currentAppName --settings WEBSITE_NODE_DEFAULT_VERSION=$version
}
 
function UpdateSettings ([string]$slot) {
   

    if ($slot) {
        az webapp config appsettings set -g ${resource-group} -n $currentAppName --settings WEBSITE_NODE_DEFAULT_VERSION=$version --slot $slot 
    }

    az webapp config appsettings set -g ${resource-group} -n $currentAppName --settings WEBSITE_NODE_DEFAULT_VERSION=$version
}