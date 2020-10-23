


$webapps = az webapp list --query '[?contains(@.name, ''Staging'')==`true`].{ group:resourceGroup,name:name}' | ConvertFrom-Json
# az webapp list --query '[?contains(@.name, ''StagingNotifiedWeb'')==`true`].name' | ConvertFrom-Json

$webapps | ForEach-Object -Parallel { 
    az webapp config appsettings set -g $_.group -n $_.name --settings WEBSITE_RUN_FROM_PACKAGE=0 --slot warmup
    az webapp config appsettings set -g $_.group -n $_.name --settings WEBSITE_RUN_FROM_PACKAGE=0 }

    az webapp config appsettings set -g Notified-Test -n 'TestNotifiedItemsService' --settings ASPNETCORE_ENVIRONMENT=Test --slot warmup
    az webapp config appsettings set -g Notified-Test -n 'TestNotifiedItemsService' --settings ASPNETCORE_ENVIRONMENT=Test