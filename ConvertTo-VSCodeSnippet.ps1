<#
.Synopsis
   Convert ISE Snippets into VSCode Snippets
.DESCRIPTION
   Convert ISE Snippets into VSCode Snippets
.EXAMPLE
   ConvertTo-VSCodeSnippet -Snippet do-until -ExportToJSON

   Convert a single ISE snippet into JSON and export it into the VSCode PowerShell Snippet file
.EXAMPLE
   $psise.CurrentPowerShellTab.Snippets | Select-Object -Expand DisplayTitle | Foreach {ConvertTo-VSCodeSnippet -Snippet $_ -ExportToJSON}

   Convert all ISE snippets in the current session into JSON and export them into the VSCode PowerShell Snippet file
.NOTES
   Author: Logan Boydell (L-Bo)
#>
function ConvertTo-VSCodeSnippet
{
    [CmdletBinding()]
    Param
    (
      [switch]$ExportToJSON,
      $VSCodeSnippetPath = "$env:USERPROFILE\Appdata\Roaming\Code\User\Snippets"
    )

    DynamicParam {
        # Set the Dynamic Parameters name
        $ParameterName = 'Snippet'

        # Create the dictionary
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        # Create the collection of attributes
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute] 


        # Create and set the parameters' attributes
        $parameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $parameterAttribute.Mandatory = $true
        $parameterAttribute.Position = 0
        $parameterAttribute.ValueFromPipeline = $true

        # Add the attributes to the attributes collection
        $AttributeCollection.Add($parameterAttribute)

        # Generate and set the ValidateSet
        $arrSet = ($psISE.CurrentPowerShellTab.Snippets).DisplayTitle | Sort-Object
        $validateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)

        # Add the ValidateSet to the attributes collection
        $AttributeCollection.Add($validateSetAttribute)

        # Create and return the dynamic parameter
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string[]], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        return $RuntimeParameterDictionary    
    }

    Begin
    {
      $snippet = $PSBoundParameters[$ParameterName]
      if($ExportToJSON)
        {
          if(Test-Path -Path "$VSCodeSnippetPath\PowerShell.json")
            {
              $currentFile = Get-Content -Path "$VSCodeSnippetPath\PowerShell.json" -Raw
            }
          else
            {
              $ErrorMessage = @"
$VSCodeSnippetPath\PowerShell.json not found! Open VSCode and create a new PowerShell.json file
File > Preferences > User Snippets, type "PowerShell" and press "Enter"             
"@
              Throw $ErrorMessage
            }
        }
    }
    Process
    {
       
      $snippetColl = $psISE.CurrentPowerShellTab.Snippets.Where({$_.DisplayTitle -in $snippet})
      foreach($target in $snippetColl)
        {
          # Get code from Snippet, escaping '$'
          $body = ConvertTo-Json $(($target.codefragment).replace('$','$$')) 
          $description = ConvertTo-Json $target.description
          $hereString = @"
"$($target.DisplayTitle)" : {
`t"prefix": "ps$($target.DisplayTitle.ToUpper())",
`t"body": [$body],
`t"description": $description
`t},
"@
          return $hereString
        }

    }
    End
    {
      if($ExportToJSON)
        {
          $currentFile = $currentFile.TrimEnd("\}")
          $newfile = $currentFile + $hereString + "`r}"
          Set-Content -Path "$VSCodeSnippetPath\PowerShell.json" -Value ([byte[]][char[]]"$newfile") -Encoding Byte
        }
    }
}