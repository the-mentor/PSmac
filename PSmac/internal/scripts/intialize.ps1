# Commands run on module import go here
# E.g. Argument Completers could be placed here

if (!$IsMacOS) {
	Write-Warning "This module is only supported on macOS. Importing it on other platforms may lead to unexpected behavior or errors."
}