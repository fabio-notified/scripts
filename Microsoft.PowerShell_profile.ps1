Import-Module posh-git
Set-Location S:\dev\team-services-projects\

Import-Module powershell-yaml

function Push-NewBranch {

    Invoke-Expression ( git push 2>&1 | Select-String git | Select-Object -ExpandProperty line | ForEach-Object { $_.Trim() } )

}

# az boards work-item create --title 'Create installation script wiki.' --type 'User Story' --assigned-to 'Fabio Östlind' --fields "Tags=DevOps"


function New-WorkItem {

    [CmdletBinding(SupportsShouldProcess = $true)]
    [Alias()]
    [OutputType([PSCustomObject])]
    Param (
        # Param1 help description
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [Alias("message")] 
        $Title,
        
        [Parameter(Mandatory = $false,
            Position = 1
        )]
        [ValidateNotNullOrEmpty()]
        [Alias("to")] 
        $AssignedTo = "Fabio Östlind",
        
        [Parameter(Mandatory = $false,
            Position = 2
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("User Story","Product Backlog Item" ,"Bug" )]
        [Alias("type")] 
        $WorkItemType = "User Story",

        [Parameter(Mandatory = $false,
            Position = 3
        )]
        [ValidateNotNullOrEmpty()]
        [Alias("tags")] 
        $Fields= "Tags=DevOps"

    )
    
    begin {
    }
    
    process {
        if ($pscmdlet.ShouldProcess("Target", "Operation")) {
           
            $workItemQuery = '{ Id: id, Title: fields.\"System.Title\", AssignedTo: fields.\"System.AssignedTo\".displayName, Tags: fields.\"System.Tags\", Status: fields.\"System.State\" }'
            $workItem = az boards work-item create --title $Title --type $WorkItemType --assigned-to $AssignedTo --fields $Fields --query $workItemQuery | ConvertFrom-Json
        }

        return $workItem
    }

}

function New-Branch {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [Alias()]
    [OutputType([PSCustomObject])]

    Param(
        [Parameter(Mandatory = $true, 
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [PSCustomObject]
        [Alias("item")]
        $WorkItem
    ) 

    
    process {

        if ($pscmdlet.ShouldProcess("Target", "Operation")) {
           
            $branchName = "$($WorkItem.AssignedTo.split(' ')[0])/$($WorkItem.Id)-$(($WorkItem.Title -replace ' ', '-'))".ToLower()
           
            $pattern = "\.$"

            if (($branchName -match $pattern )) {
            
                $branchName = $branchName -replace $pattern, ""
            }
        
    
            &"git.exe" checkout -b $branchName

            Invoke-Expression ( git push 2>&1 | Select-String git | Select-Object -ExpandProperty line | ForEach-Object { $_.Trim() } )
        }

        Write-Host "Created branch: $branchName"

        Return $WorkItem

    }
}