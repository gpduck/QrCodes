$Script:ModuleRoot = $PSScriptRoot

dir (Join-Path $ModuleRoot "ExportedFunctions\*.ps1") | %{
	. $_.fullname
}