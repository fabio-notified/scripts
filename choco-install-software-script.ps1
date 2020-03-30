#Requires -RunAsAdministrator

# Set history file path
[System.Environment]::SetEnvironmentVariable("PSReadlineHistory", "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt", "Machine")
 [System.Environment]::SetEnvironmentVariable("Dev", "S:\dev", "Machine")
 [System.Environment]::SetEnvironmentVariable("AZURE_DEVOPS_EXT_PAT", "obcs5qpwcpafins3voetjmpvduxrnxqvahgagg6eywtqmotqdi2q", "Machine")
$resultTest = ""

# Install choco Installer
${software-list} = @(

	@{ 	Name = "git"; Params = @("--params='/GitAndUnixToolsOnPath /NoAutoCrlf /WindowsTerminal'", "--Install-arguments='/DIR=C:\git'" ) } 
	@{ 	Name = "gh"; Params = @() } 
	@{ 	Name = "slack"; Params = @() } 
	@{ 	Name = "vscode"; Params = @() } 
	@{ 	Name = "azure-cli"; Params = @() } 
	@{ 	Name = "spotify"; Params = @() } 
	@{ 	Name = "vim"; Params = @() } 
	@{ 	Name = "git-credential-manager-for-windows"; Params = @() } 
	@{ 	Name = "docker-desktop"; Params = @() } 
	@{ 	Name = "nuget.commandline"; Params = @() } 
	@{ 	Name = "azure-devops"; Params = @() } 
	@{ 	Name = "microsoftazurestorageexplorer"; Params = @() } 

)

$choco = @(where.exe choco.exe)[0]

if ( $null -eq $choco ) {
	Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/Install.ps1'))
}

${software-list} | ForEach-Object -Begin { } -Process {     

	$currentSoftwareItem = $_ 
	$params = $currentSoftwareItem.Params

	if ($params) {
		$numberOfParams = $params.Length

  $resultTest = ($numberOfParams -gt 1) ?  $params -join ' ' : $params
	}
	else {
		$resultTest = $params[0]
	}

	&$choco install $currentSoftwareItem.Name  -y $resultTest


} 

&$choco install microsoftazurestorageexplorer -y 
# Install Nuget CLI
&$choco install nuget.commandline -y

# Install Slack

&$choco install slack -y

#Install git
&$choco install git -y --params="'/GitAndUnixToolsOnPath /NoAutoCrlf /WindowsTerminal'" --Install-arguments="'/DIR=C:\git'"

&$choco install git-credential-manager-for-windows -y

[System.Environment]::SetEnvironmentVariable("Path", $env:Path + "C:\git\cmd\" , [System.EnvironmentVariableTarget]::User)

# Install Docker Desktop
&$choco install docker-desktop -y
# Install vim editor 

&$choco install vim -y

&$choco install microsoft-teams

# Add .vimrc file and content 

${vimrc-file-path} = "~/.vimrc"

if ( -not (Test-Path ${vimrc-file-path})) { 

	New-Item -ItemType File -Path ${vimrc-file-path}

	Add-Content -Path ${vimrc-file-path} -Value "Set number"
}
#Install vscode

&$choco install vscode -y 

# Install github cli
&$choco install gh

# Install azure cli

&$choco install azure-cli -y

[System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files (x86)\Microsoft SDKs\Azure\CLI2\wbin" , [System.EnvironmentVariableTarget]::User)

# Install powershell modules

Install-Module Posh-Git -Confirm:$false -Force
Install-Module Pester -Confirm:$false -Force
#Create powershell profile

if ( -not (Test-Path $profile)) {
	New-Item -ItemType File -Path $profile
	Add-Content -Path $profile -Value "Import-Module posh-git"
}

#Install vs code extensions 

$extensions = @("ms-vscode.powershell", "vscodevim.vim", "ms-azure-devops.azure-pipelines", "ms-vscode.azure-account", "msazurermtools.azurerm-vscode-tools","ms-vscode.azurecli")

$vscode = @(where.exe code)[0]

if ($vscode) {

	$extensions | ForEach-Object { &$vscode --Install-extension  $_ }  

}

# Install spotiify

&$choco Install spotify -y
