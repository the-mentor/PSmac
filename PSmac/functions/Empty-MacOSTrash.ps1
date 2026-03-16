function Empty-MacOSTrash {
	# Empty the Trash on macOS per https://superuser.com/questions/1877663/how-can-i-empty-the-trash-from-the-macos-terminal
	osascript -e 'try' -e 'tell application "Finder" to empty' -e 'end try'
}