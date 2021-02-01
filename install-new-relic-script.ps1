$LICENSE_KEY=""; `
(New-Object System.Net.WebClient).DownloadFile("https://download.newrelic.com/infrastructure_agent/windows/newrelic-infra.msi", "$env:TEMP\newrelic-infra.msi"); `
msiexec.exe /qn /i "$env:TEMP\newrelic-infra.msi" GENERATE_CONFIG=true LICENSE_KEY="$LICENSE_KEY" | Out-Null; `
net start newrelic-infra