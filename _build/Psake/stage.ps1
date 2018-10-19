Framework "4.5.2"

properties {
	$nugetExePath				= "..\..\.nuget\NuGet.exe"
	$slnPath					= "..\..\<SOLUTION.sln>"
	$assemblyInfoPath			= "..\..\SharedAssemblyInfo.cs"
	$generateVersion			= $true
	
	$websiteProjPath			= "..\..\<SITE>\<SITE.csproj>"
	$websiteDir					= "..\..\<SITE>"	
	
	$componentDir				= "..\..\<NON-SITE PROJECT>"
	$componentDir_force			= "false"
	$componentCIDirName			= "<NON-SITE PROJECT>"				
	
	$dbDir						= "..\..\<DB>"
		
    $stageRepoUrl         		= "https://crcappsrv01d.crc.loc/svn/projects/Infrastructure/Applications/<APPLICATION>"
    $stageDir	         		= "..\..\..\<APPLICATION>.CI"
	$environment				= "<ENVIRONMENT>"    
	
    $autoCommitBatPath     		= "..\Dos\SvnAutoCommit.bat"
    $autoCheckoutBatPath   		= "..\Dos\SvnAutoCheckout.bat"
	$autoUpdateBatPath     		= "..\Dos\SvnAutoUpdate.bat"
}

################ Main #################################################
Task Default -depends Push


################ Specific Tasks #######################################
Task Init						-depends EnsureStageFolderExists, UpdateFromSvn, GenerateAssemblyVersion, BuildSolution
Task Copy						-depends Init, PublishSite, CopyComponent, CopyDatabase
Task Push						-depends Copy, CommitToSvn, WriteSuccessMessage


################ Generic Tasks ########################################
Task BuildSolution -depends RestoreNugetPackages {	
	Write-Host "Building solution: $slnPath" -ForegroundColor Green	
	$safeSln = Safe-Resolve-Path $slnPath
	Exec { msbuild $safeSln /t:Clean /t:Build /p:Configuration=$environment /p:Platform="Any CPU" /p:WarningLevel=1  /v:q }    
}

Task PublishSite {	
	# Since we're assuming everything gets built correctly in BuildSolution,
	# we are relying on the MsBuild compiler efficiencies to not force a second
	# build when we go to publish the web side of things (hence the absence of
	# the clean and build flags)

	$safeWebsiteProjPath = Safe-Resolve-Path $websiteProjPath
	$safePublishProfile = Safe-Resolve-Path $websiteDir
	if (-Not ([string]::IsNullOrWhiteSpace($safePublishProfile))) {		
		$safePublishProfile = AppendEnvironmentTo "$safePublishProfile\Properties\PublishProfiles"
		$safePublishProfile = "$safePublishProfile.pubxml"
	}
	
	Write-Host "Publish Profile: $safePublishProfile"		
	Exec { msbuild $safeWebsiteProjPath /p:DeployOnBuild=true /p:PublishProfile=$safePublishProfile /p:Configuration=$environment /p:Platform="AnyCPU" /p:WarningLevel=1  /v:q }    

	# copy to CI folder
	Invoke-Psake .\stage.ps1 CopyComponent -properties @{'componentDir'='..\..\_output\Site'; 'componentCIDirName'='Site'; 'componentDir_force'='true'}
}

Task CopyComponent {
	$componentDirFinal = $componentDir
	if (-Not ($componentDir_force -eq "true")) {
		$componentDirFinal = "$componentDir\bin"
	}	
	
	$safeComponentDirOutputPath = Safe-Resolve-Path $componentDirFinal
	if ([string]::IsNullOrWhiteSpace($safeComponentDirOutputPath)) {
		Throw "Invalid component directory supplied: $componentDir"		
		Return
	}
	
	if (-Not ($componentDir_force -eq "true")) {
		$safeComponentDirOutputPath	= AppendEnvironmentTo $safeComponentDirOutputPath.ToString()
	}	
	
	$safeComponentDirOutputPath = "$safeComponentDirOutputPath\*"
	Write-Host "Component Output Dir: $safeComponentDirOutputPath"
	
	$target = AppendEnvironmentTo $stageDir
	$target = "$target\_components\$componentCIDirName"
	Write-Host "Target Dir: $target"
	
	If (-Not (Test-Path $target))
	{
		Write-Host "Creating $target ..."
		New-Item $target -ItemType Directory
	}
	
	Copy-Item $safeComponentDirOutputPath $target -Recurse -Force 
}

Task CommitToSvn {
	$fullStagePath = AppendEnvironmentTo $stageDir
	$resolved_ci_path = Safe-Resolve-Path -path $fullStagePath

    $currentVersion = GetCurrentVersionInfo
	$commitMsg = "Stage files for $environment - $currentVersion"
	
    Write-Host "Committing to SVN: $resolved_ci_path" -ForegroundColor Green
    Exec { & $autoCommitBatPath "$resolved_ci_path" $commitMsg }
}

Task CopyDatabase {
	$fullStagePath = AppendEnvironmentTo $stageDir

	$safeDbDir = Safe-Resolve-Path $dbDir
	if ([string]::IsNullOrWhiteSpace($safeDbDir)) {
		Throw "Invalid dbDir: $dbDir"
		Return
	}
	
	$source = $safeDbDir.ToString()
	$source = "$source"
	$dbFolderName = [System.IO.Directory]::GetParent("$source\dummy.txt").Name
	
	Write-Host "dbFolderName = $dbFolderName"	
	
    $source = "$source\*"
    $target = "$fullStagePath\_db\$dbFolderName"
    
	If (-Not (Test-Path $target))
	{
		Write-Host "Creating $target ..."
		New-Item $target -ItemType Directory
	}
	
    Copy-Item $source $target -Recurse -Force    	
	
    RemoveItem "$target\bin\*"
	RemoveItem "$target\bin"
    RemoveItem "$target\obj"
    RemoveItem "$target\Properties"
    RemoveItem "$target\*.csproj"
    RemoveItem "$target\*.csproj.user"
    
    If (Test-Path "$target\StyleCop.Cache"){
        Remove-Item "$target\StyleCop.Cache" -Force
    }
}

Task EnsureStageFolderExists {
	$fullStagePath = AppendEnvironmentTo $stageDir

    If (-Not (Test-Path $fullStagePath))
    {
        New-Item $fullStagePath -ItemType Directory
        $resolved_ci_path = Safe-Resolve-Path -path $fullStagePath
		
		$fullStageRepo = AppendEnvironmentTo $stageRepoUrl
        Exec { & $autoCheckoutBatPath "$fullStageRepo" "$resolved_ci_path" }
	}
}

Task GenerateAssemblyVersion {
	If (-Not ($generateVersion -eq $true)) {
		Write-Host "Will not generate version during this staging process"
		Return
	}

	If (-Not (Test-Path $assemblyInfoPath)) {
		Throw "$assemblyInfoPath does not exist"
	}
	
	If (-Not ($assemblyInfoPath.EndsWith("cs"))) {
		Throw "Non-C# assembly info files are not supported currently"
	}
	
	# find the currentVersion using the assembly file
	$currentVersion = "<NOT FOUND>"
	$resolvedAssemblyInfoPath = Resolve-Path $assemblyInfoPath
	$assemblyVersionMatcher = 'AssemblyVersion\("([^)]+)"\)'
	(Get-Content $resolvedAssemblyInfoPath) |
			Foreach-Object {
				$found = $_ -match $assemblyVersionMatcher			
				if ($found) {						
					$currentVersion = $matches[1]
				}
		}
	if ($currentVersion -eq "<NOT FOUND>") {
		Throw "Could not find current version"
	}	
	Write-Host "currentVersion = $currentVersion"
	
	# build the new version string
	$now = [DateTime]::Now;
	$build = [string]::Format("{0}{1}", $now.ToString("yy"), $now.DayOfYear);
	$revision = $now.ToString("HHmm")
	
	Write-Host "build = $build"
	Write-Host "revision = $revision"
	$currentVersionParts = $currentVersion.Split('.')
	
	$major = $currentVersionParts[0]
	$minor = $currentVersionParts[1]
	$newVersion = "$major.$minor.$build.$revision"
	Write-Host "newVersion = $newVersion"
	
	# replace the version in the file
	$assemblyVersionString = 'AssemblyVersion("' + $newVersion + '")'
	$assemblyFileVersionString = 'AssemblyFileVersion("' + $newVersion + '")'
	(Get-Content $resolvedAssemblyInfoPath) |
			Foreach-Object {
					$_ -replace $assemblyVersionMatcher, $assemblyVersionString `
					-replace 'AssemblyFileVersion\("([^)]+)"\)',$assemblyFileVersionString
			} |
			Out-File $resolvedAssemblyInfoPath
	
	LogCurrentVersion $newVersion
}

Task RestoreNugetPackages {
	$resolvedSlnPath = Safe-Resolve-Path $slnPath	
	Exec { & $nugetExePath restore "$resolvedSlnPath" }
}

Task UpdateFromSvn {
	$fullStagePath = AppendEnvironmentTo $stageDir
	$resolved_ci_path = Safe-Resolve-Path -path $fullStagePath

    Write-Host "Updating Stage from SVN" -ForegroundColor Green
	Exec { & $autoUpdateBatPath $resolved_ci_path }
}

Task WriteSuccessMessage {
	$currentVersion = GetCurrentVersionInfo
	$msg = "Version $currentVersion has been staged for $environment"
	Write-Host ""
	Write-Host "   U  ___ u  _   _        __   __U _____ u    _       _   _    _   " -ForegroundColor Green 
	Write-Host "    \/ _ \/ |'| |'|       \ \ / /\| ___ |/U  / \  u  |'| |'| U| |u " -ForegroundColor Green 
	Write-Host "    | | | |/| |_| |\       \ V /  |  _|    \/ _ \/  /| |_| |\\| |/ " -ForegroundColor Green 
	Write-Host ".-,_| |_| |U|  _  |u      U_| |_u | |___   / ___ \  U|  _  |u |_|  " -ForegroundColor Green 
	Write-Host " \_)-\___/  |_| |_|         |_|   |_____| /_/   \_\  |_| |_|  (_)  " -ForegroundColor Green 
	Write-Host "      \\    //   \\     .-,//|(_  <<   >>  \\    >>  //   \\  |||_ " -ForegroundColor Green 
	Write-Host "     (__)  (_ ) ( _)     \_) (__)(__) (__)(__)  (__)(_ ) ( _)(__)_)" -ForegroundColor Green 
	Write-Host ""
	Write-Host $msg -ForegroundColor Green
}
################ Generic Functions ####################################
Function AppendEnvironmentTo ($path) {
	if ([string]::IsNullOrWhiteSpace($path)) {
		return $path
	}
	
	$separator = "\"
	if ($path.Contains("/")) {
		$separator = "/"
	}
	
	if ($path.EndsWith($separator)) {
		return $path + $environment
	}
	
	return $path + $separator + $environment
}

Function LogCurrentVersion ($version) {
	# copy version info over to meta directory
	$fullStagePath = AppendEnvironmentTo $stageDir
	$target = "$fullStagePath" + '\_info'
	
	If (-Not (Test-Path $target)) {
		New-Item $target -ItemType Directory
	}
	
	$target = $target + "\currentVersion.txt"
	If (Test-Path $target) {
		Remove-Item $target
	}
	
	$source = $resolvedAssemblyInfoPath
	$version | Out-File $target
}

Function GetCurrentVersionInfo() {
	$fullStagePath = AppendEnvironmentTo $stageDir
	$target = "$fullStagePath" + '\_info\currentVersion.txt'
	if (-Not (Test-Path $target)) {
		Throw "Could not get currentVersionInfo because file was missing: $target"
	}
	
	$resolvedTarget = Resolve-Path $target
	$output = ""
	(Get-Content $resolvedTarget -First 1) |
		Foreach-Object {
				$output = $_
		}
	
	Return $output
}

Function RemoveItem($path) {
	If (Test-Path $path) {
		Remove-Item $path -Force -Recurse
	}	
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