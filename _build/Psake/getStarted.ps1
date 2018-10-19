Framework "4.5.2"

Properties {   
	$nugetExePath				= "..\..\.nuget\NuGet.exe"
	$slnPath					= "..\..\DeveloperInterview.sln"
}

Task default -depends RefreshDb, RestoreNugetPackages

Task RefreshDb {
	Invoke-Psake .\default.ps1 db -properties @{'db_mode'='restore';}
}

Task RestoreNugetPackages {
	$resolvedSlnPath = Safe-Resolve-Path $slnPath	
	Exec { & $nugetExePath restore "$resolvedSlnPath" }
}

Function Safe-Resolve-Path($path) {
	If ([string]::IsNullOrWhiteSpace($path)) {
		Return ""
	}
	
	If (Test-Path $path) {
		Return Resolve-Path $path
	}
	
	return $path
}
