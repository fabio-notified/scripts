$resource_group = 'Notified-Test'
$plan_name = 'plan-notified-linux-test'
$sku = 'P1V2'
$app_service_name = 'TestNotifiedItemsService'

#  $plan = az appservice plan create --name $plan_name --resource-group $resource_group --is-linux --sku $sku | convertfrom-json

#  az webapp create  "-g Notified-Test  -p Notified-Test-Linux -n TestNotifiedItemService -r DOTNETCORE|3.1"

az webapp deployment slot create --name $app_service_name --resource-group $resource_group --slot warmup

az webapp config appsettings list --name StagingNotifiedItemsService --resource-group Notified --slot warmup --output json | Out-File ./appsetting.json


 az webapp config appsettings set --name $app_service_name --resource-group $resource_group --slot warmup --settings '@appsetting.json'