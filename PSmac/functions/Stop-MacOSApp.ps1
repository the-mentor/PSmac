function Stop-MacOSApp { 
	param(
		[Parameter(Mandatory, Position = 0)]
		[ValidateScript(
			{ $_ -in (Get-Process).Name },
			ErrorMessage = 'Please specify the name of a subdirectory in the current directory.'
		)]
		[ArgumentCompleter(
			{
				param($cmd, $param, $wordToComplete)
				# This is the duplicated part of the code in the [ValidateScipt] attribute.
				[array] $validValues = (Get-Process).Name
				$validValues -like "$wordToComplete*"
			}
		)]
		[String]$AppName
	)
        
	Get-Process $AppName | Stop-Process 
}