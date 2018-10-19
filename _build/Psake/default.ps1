Framework "4.5.2"

Properties {    
    $build_output_path     		= "..\_output"
			
    $db_server             		= ".\SQLEXPRESS"
    $db_name               		= "CRC.DeveloperInterview"
			
    $db_mode               		= "restore"		# possible values: restore, migrate
    $db_restore_mode	   		= "drop"		# possible values: drop, fromBackup
    $db_environment        		= "LOCAL"
		
    $db_files_path         		= "..\..\DeveloperInterview.Database"
    $db_backup_path		   		= $db_files_path
	
    $db_backup_name        		= ""
}

Task default 	-depends showNoDefaultTaskDefinedWarning
Task db 		-depends clean, buildDb

Task buildDb -depends restoreDb {
    $sql_files_directory = resolve-path $db_files_path
    write-host "Running database migrations..."
    exec { & "..\RoundhousE\rh.exe" /s=$db_server /d=$db_name /env=$db_environment /f=$sql_files_directory --silent } 
}

Task clean {
    Write-Host "Cleaning previous build..."

    if (Test-Path -Path $build_output_path) {
        Remove-Item -Path $build_output_path -recurse
    }

    new-item -Path $build_output_path –itemtype directory
}

Task restoreDb {
    if ($db_mode -eq 'restore'){      
        
		If ($db_restore_mode.ToLower() -eq "drop") {
			write-host "Deleting database..."
			exec { & "..\RoundhousE\rh.exe" /s=$db_server /d=$db_name /drop --silent }
			Return
		}
		
		If ($db_restore_mode.ToLower() -eq "frombackup") {
			write-host "Restoring the last database backup..."
			$backup_full_path = $db_backup_path + "\" + $db_backup_name 
			Write-Host "Backup Path: $backup_full_path"
			exec { & "..\RoundhousE\rh.exe" /s=$db_server /d=$db_name /env=$db_environment /restore /rfp=$backup_full_path --silent }
		}
        
		Write-Host "Unknown db_restore_mode supplied, so restore did nothing: [db_restore_mode=$db_restore_mode]"
    }
    else {
        write-host "Ignoring the restoreDb routing..."
    }
}

Task showNoDefaultTaskDefinedWarning {
    Write-Host "There are no default tasks defined.  Use one of the following: db, build, ci"
}