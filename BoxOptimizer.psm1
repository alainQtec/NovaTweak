
#!/usr/bin/env pwsh
#region    Classes
#endregion Classes
$Private = Get-ChildItem ([IO.Path]::Combine($PSScriptRoot, 'Private')) -Filter "*.ps1" -ErrorAction SilentlyContinue
$Public = Get-ChildItem ([IO.Path]::Combine($PSScriptRoot, 'Public')) -Filter "*.ps1" -ErrorAction SilentlyContinue
# Load dependencies
$PrivateModules = [string[]](Get-ChildItem ([IO.Path]::Combine($PSScriptRoot, 'Private')) -ErrorAction SilentlyContinue | Where-Object { $_.PSIsContainer } | Select-Object -ExpandProperty FullName)
if ($PrivateModules.Count -gt 0) {
  ForEach ($Module in $PrivateModules) {
    Try {
      Import-Module $Module -ErrorAction Stop
    } Catch {
      Write-Error "Failed to import module $Module : $_"
    }
  }
}
# Dot source the files
ForEach ($Import in ($Public, $Private)) {
  Try {
    . $Import.fullname
  } Catch {
    Write-Warning "Failed to import function $($Import.BaseName): $_"
    $host.UI.WriteErrorLine($_)
  }
}
# Export Public Functions
$Param = @{
  Function = $Public.BaseName
  Variable = '*'
  Cmdlet   = '*'
  Alias    = '*'
}
Export-ModuleMember @Param -Verbose
