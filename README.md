# Convertto-VSCodeSnippet
PowerShell function for converting ISE Snippets into VSCode snippets
## EXAMPLE
   ```powershell
   ConvertTo-VSCodeSnippet -Snippet do-until -ExportToJSON
   ```
   Convert a single ISE snippet into JSON and export it into the VSCode PowerShell Snippet file
## EXAMPLE
   ```powershell
   $psise.CurrentPowerShellTab.Snippets | Select-Object -Expand DisplayTitle | Foreach {ConvertTo-VSCodeSnippet -Snippet $_ -ExportToJSON}
   ```
   Convert all ISE snippets in the current session into JSON and export them into the VSCode PowerShell Snippet file
## NOTES
   Author: Logan Boydell (L-Bo)
