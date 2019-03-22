$Script:ModuleRoot = $PSScriptRoot

&$PSScriptRoot\bin\Loader.ps1

Get-ChildItem (Join-Path $ModuleRoot "ExportedFunctions\*.ps1") | ForEach-Object {
	. $_.fullname
}