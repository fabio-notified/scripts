${resource-group} = "notified"
$vnetName = "notified-production-vnet"
$appName = "ProductionNotifiedItemSvc"

${access-restrictions} = az webapp config access-restriction show -g notified --name "ProductionNotifiedItemsService" | ConvertFrom-Json -Depth 4

${access-restrictions}.ipSecurityRestrictions | ForEach-Object {

    $currentItem = $_

    if([string]::IsNullOrEmpty($currentItem.description))
    {
        $currentItem.description = "empty description"
    }

    if ($currentItem.name -eq "Access from VNet") {

        az webapp config access-restriction add -g ${resource-group} -n $appName `
            --action $currentItem.action `
            --rule-name $currentItem.name `
            --description $currentItem.description `
            --subnet  $currentItem.vnet_subnet_resource_id `
            --priority $currentItem.priority `
            --debug 

            return
    
    }


    az webapp config access-restriction add -g ${resource-group} -n $appName `
        --action $currentItem.action `
        --rule-name $currentItem.name `
        --description $currentItem.description `
        --ip-address  $currentItem.ip_address `
        --priority $currentItem.priority `
        --debug 

}


