
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
	exec { nuget pack $NuSpecFile -OutputDirectory $TargetDir -BasePath $BasePath -NoPackageAnalysis -NonInteractive }
}