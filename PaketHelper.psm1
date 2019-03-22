$Bootstrapper = Join-Path $PSScriptRoot ".paket/paket.bootstrapper.exe"
$PaketExe = Join-Path $PSScriptROot ".paket/paket.exe"

function Load-PaketAssembly {
  param(
    $Path
  )
  if($PSVersionTable["PSEdition"] -eq "Core") {
    $a = [System.Runtime.Loader.AssemblyLoadContext]::Default.LoadFromAssemblyPath($Path)
  } else {
    $a = [System.Reflection.Assembly]::LoadFrom($Path)
  }
}

function Install-ModulePackages {
  &$PaketExe install
}
Export-ModuleMember -Function Install-ModulePackages

function Restore-ModulePackages {
  &$PaketExe restore
}
Export-ModuleMember -Function Restore-ModulePackages

function Load-DependenciesFile {
  param(
    $Path
  )
  [Paket.Dependencies]::New($Path)
}

function Get-Libraries {
  param(
    [Parameter(Mandatory=$true)]
    $Dependencies,

    [Parameter(Mandatory=$true)]
    $TargetFramework,

    [Parameter(Mandatory=$true)]
    $PackageName
  )
  $Group = "Main"
  $Framework = [Paket.TargetProfile]::new($Null, $TargetFramework)
  $Dependencies.GetLibraries($Group, $PackageName, $Framework)
}

function Copy-Library {
  param(
    [Parameter(ValueFromPipelineByPropertyName = $True)]
    $Path,
    
    $TargetPath,

    $Framework
  )
  begin {
    $TargetPath = Join-Path $TargetPath $Framework
    if(!(Test-Path $TargetPath)) {
      New-Item -Path $TargetPath -ItemType Directory -Force > $null
    }
  }
  process {
    Write-Verbose "Copy $Path into $TargetPath"
    Copy-Item -Path $Path -Destination $TargetPath
  }
}

function Install-ModuleDllDependencies {
  param(
    $RootPath = $pwd,

    $BinPath = "$pwd\src\bin",

    $CoreFramework = "netstandard2.0",

    $DesktopFramework = "net45"
  )
  Install-ModulePackages
  $DependencyFile = Join-Path $RootPath "paket.dependencies"
  $Dependencies = Load-DependenciesFile $DependencyFile
  $CoreFramework,$DesktopFramework | ForEach-Object {
    $FrameworkName = $_
    $Dependencies.GetInstalledPackages() | ForEach-Object {
      Get-Libraries -Dependencies $Dependencies -TargetFramework $FrameworkName -PackageName $_.Item2 | Copy-Library -TargetPath $BinPath -Framework $FrameworkName
    }
  }
  $LoaderPath = Join-Path $BinPath "Loader.ps1"
  Get-ModuleLoadScript -Dependencies $Dependencies -CoreFramework $CoreFramework -DesktopFramework $DesktopFramework | Set-Content $LoaderPath
}
Export-ModuleMember -Function Install-ModuleDllDependencies

function Get-ModuleLoadScript {
  param(
    $Dependencies,

    $CoreFramework = "netstandard2.0",

    $DesktopFramework = "net45"
  )
  $Framework = $DesktopFramework
  $DesktopLibraries = $Dependencies.GetDirectDependencies() | ForEach-Object {
    $Dependency = $_
    Get-Libraries -Dependencies $Dependencies -TargetFramework $Framework -PackageName $Dependency.Item2 | ForEach-Object {
      $FileName = Split-Path $_.Path -Leaf
@"
`"$DesktopFramework/$Filename`"
"@
    }
  }
  $Framework = $CoreFramework
  $CoreLibraries = $Dependencies.GetDirectDependencies() | ForEach-Object {
    $Dependency = $_
    Get-Libraries -Dependencies $Dependencies -TargetFramework $Framework -PackageName $Dependency.Item2 | ForEach-Object {
      $FileName = Split-Path $_.Path -Leaf
@"
`"$CoreFramework/$Filename`"
"@
    }
  }
@"
if(`$PSVersionTable["PSEdition"] -eq "Core") {
    $($CoreLibraries -join ", ") | ForEach-Object {
        `$DllPath = Join-Path `$PSScriptRoot `$_
        Add-Type -Path `$DllPath
    }
} else {
    $($DesktopLibraries -join ", ") | ForEach-Object {
        `$DllPath = Join-Path `$PSScriptRoot `$_
        Add-Type -Path `$DllPath
    }
}
"@
}

&$Bootstrapper
Load-PaketAssembly -Path $PaketExe