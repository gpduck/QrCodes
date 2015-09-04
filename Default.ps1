
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

Task default -Depends Clean,Pack
Task restore -Depends Clean,PackageRestore

Task Pack -Depends GetNuget,PackageRestore {
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

Task GetNuget {
	if(!(Test-Path $ProjectDir\nuget.exe)) {
		invoke-webrequest -uri https://nuget.org/nuget.exe -outfile $ProjectDir\nuget.exe
	}
	function script:nuget {
		&$ProjectDir\nuget.exe $Args
	}
}

Task PackageRestore {
	nuget install -ExcludeVersion -OutputDirectory $BasePath packages.config
}

Task Clean {
	rm $BasePath\ZXing.Net -recurse -erroraction SilentlyContinue
	rm bin -recurse -erroraction SilentlyContinue
}