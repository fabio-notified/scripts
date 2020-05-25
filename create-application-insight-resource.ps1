${insights-components} = az monitor app-insights component show --query [].name
${action-group-name } = 'restart-app-service'
${web-apps} = az webapp list --query "[?contains(@.name, 'Staging')].{Name:name,Id:id,group:resourceGroup,Location:location}"


${web-apps} | ForEach-Object { 

    $currentWebApp = $_
    if ( -not (${insights-components} -contains $currentWebApp.Name)) {

        ${app-insight} = az monitor app-insights component create --app $currentWebApp.Name --location $currentWebApp.Location --resource-group $currentWebApp --application-type web --kind web

        
    }
    else {
        ${app-insight } = az monitor app-insights component show --app $currentWebApp.Name -g $currentWebApp.Location
    }

    ${action-group } = az monitor action-group show --name ${action-group-name } |
    az monitor metrics alert create -n alert1 -g $currentWebApp.Location --scopes $currentWebApp.Id \
    --condition "avg Percentage CPU > 90" --window-size 5m --evaluation-frequency 1m \
    --action { actionGroupId } apiKey= { APIKey } type=HighCPU --description "High CPU"
    
} 