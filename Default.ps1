
Properties {
	if(!$OutDir) {
		$OutDir = "bin"
	}
	if(!$ProjectDir) {
		$ProjectDir = $PSake.build_script_dir
	}
	if(!$TargetDir) {
		$TargetDir = Join-Path -Path $ProjectDir -ChildPath $OutDir
	}
	if(!$ProjectName) {
		$ProjectName = Split-Path -Path $ProjectDir -Leaf
	}
	if(!$NuSpecFile) {
		$NuSpecFile = Join-Path -Path $ProjectDir -ChildPath "$ProjectName\$ProjectName.nuspec"
	}
	if(!$BasePath) {
		$BasePath = Join-Path -Path $ProjectDir -ChildPath $ProjectName
	}
}

Task default -Depends Pack

Task Pack {
	ipmo NuGet
	Assert (Test-Path $NuSpecFile) -FailureMessage "$NuSpecFile does not exist"
	if(!(Test-Path $TargetDir)) {
		mkdir $TargetDir > $null
	}
	$NuSpecXml = [Xml](Get-Content $NuSpecFile)
	$NuSpecVersion = [Version]($NuSpecXml.Package.Metadata.Version)
	$VersionDate = [int][Datetime]::Now.ToString("yyyyMMdd")
	$OutputVersion = New-Object System.Version($NuSpecVersion.Major, $NuSpecVersion.Minor, $VersionDate, $BuildNumber)
	exec { nuget pack $NuSpecFile -OutputDirectory $TargetDir -BasePath $BasePath -NoPackageAnalysis -NonInteractive -Version ($OutputVersion.ToString())}
}