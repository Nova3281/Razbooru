BEGIN {
	RS = "\""
	if(index(tolower(ENVIRON["OS"]), "windows") > 0) { OS = "windows" }
	else {
		OS = "linux"
		# TODO: OSX etc.
	}
}

/^open/ {
	if(OS == "windows") {
		gsub("'", "\"") # windows doesn't support raw strings so convert to string literal
		$1 = "start explorer" # opens in user's default browser
	}
	else {
		"for exec in 'xdg-open' 'open' 'sensible-browser' 'kde-open5' 'kde-open' 'gnome-open'; do echo -n $(which \"$exec\" 2>/dev/null) && break; done" | getline $1
		$0 = $0" &>/dev/null"
	}
	
	printf "\xf\x0\x0\x0{\"text\":\"okay\"}" # hack :( TODO: figure out why messages sent after system() never reach extension
	if ( system($0) == 0) { printf "\xf\x0\x0\x0{\"text\":\"okay\"}" }
	else { printf "\xf\x0\x0\x0{\"text\":\"bad.\"}" }
}
/^chrome/ {
	if(OS == "windows") {
		gsub("'", "\"")
		$1 = "start chrome"
	}
	else {
		"for exec in 'google-chrome' 'chrome' 'chrome-browser' 'chromium' 'chromium-browser'; do echo -n $(which \"$exec\" 2>/dev/null) && break; done || echo -n 'open -a \"Google Chrome\" -n --args'" | getline $1
		$0 = $0" &>/dev/null"
	}
	
	printf "\xf\x0\x0\x0{\"text\":\"okay\"}"
	if ( system($0) == 0) { printf "\xf\x0\x0\x0{\"text\":\"okay\"}" }
	else { printf "\xf\x0\x0\x0{\"text\":\"bad.\"}" }
}
/^firefox/ {
	if(OS == "windows") {
		gsub("'", "\"")
		"for exec in 'firefox'; do echo -n $(which \"$exec\" 2>/dev/null) && break; done || echo -n 'open -a \"Firefox\" -n --args'" | getline $1
		$1 = "start firefox"
	}
	else { $0 = $0" &>/dev/null" }
	
	printf "\xf\x0\x0\x0{\"text\":\"okay\"}"
	if ( system($0) == 0) { printf "\xf\x0\x0\x0{\"text\":\"okay\"}" }
	else { printf "\xf\x0\x0\x0{\"text\":\"bad.\"}" }
}
