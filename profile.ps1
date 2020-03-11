using namespace System.Management.Automation
Import-Module posh-git

class ValidAdaptersGenerator : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $Values = Get-NetAdapter | Select-Object -ExpandProperty Name
        return $Values
    }
}

function Restart-InternetConnection {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateSet( [ValidAdaptersGenerator] )]
        [string]
        $Protocol
    )

    Get-NetAdapter -Name  $Protocol | Restart-NetAdapter -Verbose
}

Set-PSReadLineOption -EditMode Vi -BellStyle None -ViModeIndicator Script -ViModeChangeHandler  {
    if ($args[0] -eq 'Command') {
        # Set the cursor to a blinking block.
        Write-Host -NoNewLine "$([char]0x1b)[1 q"
    }
    else {
        # Set the cursor to a blinking line.
        Write-Host -NoNewLine "$([char]0x1b)[5 q"
    }
         
}

Set-Alias -Name ric -Value Restart-InternetConnection