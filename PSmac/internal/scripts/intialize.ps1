# Commands run on module import go here
# E.g. Argument Completers could be placed here

if (!$IsMacOS) {
	Write-Warning "This module is only supported on macOS. Importing it on other platforms may lead to unexpected behavior or errors."
}
else {
	Write-Verbose "Running on macOS, proceeding with module initialization."

	# Init Brew if it exists.
	if (Get-Item -Path /opt/homebrew/bin/brew -ErrorAction SilentlyContinue) {
		/opt/homebrew/bin/brew shellenv | Invoke-Expression
	}
}


