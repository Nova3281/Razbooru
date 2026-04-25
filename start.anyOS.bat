#!/bin/sh
: # This is a sh/batch hybrid script that should work on Linux, OSX or Windows.
: # This application requires Google Chrome (or Chromium) to be installed to run.
: # If this fails to work on your system please file an issue at https://bitbucket.org/xkero/zenbooru/issues/new
: #
: # Chrome options explained:
: # --disable-web-security sounds scary, but it just disables the same origin policy restriction that stops us from making "cross site" requests.
: # --enable-experimental-web-platform-features enables some CSS features that aren't enabled by default in the current stable branch of chrome at the time of writing this.
: # --user-data-dir= creates a new chrome profile at the specified location, starting a new session like this is required for --disable-web-security and keeps it separate from your regular browsing (history, cache, etc).

: # Posix OSs
:; cd "$(dirname $0)"
:; alias browser=$(for exec in 'google-chrome' 'chrome' 'chrome-browser' 'chromium' 'chromium-browser'; do which "$exec" 2>/dev/null && break; done || echo 'open -a "Google Chrome" -n --args')
:; data="$PWD/chrome_data"
:; nm="$data/NativeMessagingHosts"
:; id="$data/Default/File System/000/t/00/00000000"
:; [ -f "$id" ] || browser --load-extension="$PWD/anyOS" --allow-file-access-from-files --user-data-dir="$data" --app="file://$PWD/Loading#setup"
:; id=$(cat "$id")
:; mkdir -p "$nm" &>/dev/null
:; echo '{"name":"org.gamemage.anyos","description":"anyOS Commands","path":"'"$PWD/anyOS/commands.sh"'","type":"stdio","allowed_origins":["chrome-extension://'$id'/"]}' > "$nm/org.gamemage.anyos.json"
:; browser --load-extension="$PWD/anyOS" --enable-experimental-web-platform-features --disable-web-security --user-data-dir="$data" --app="file://$PWD/Loading" ; exit $?

: # Windows
@echo OFF
echo Creating initial config, please wait a moment...
set data=%cd%\chrome_data
set id=%data%\Default\File System\000\t\00\00000000
if not exist "%id%" (
	start /min /wait chrome --disable-default-apps --load-extension="%cd%\anyOS" --allow-file-access-from-files --user-data-dir="%data%" --app="file://%cd%\Loading#setup"
)
set /p id=<"%id%"
echo {"name":"org.gamemage.anyos","description":"anyOS Commands","path":"commands.bat","type":"stdio","allowed_origins":["chrome-extension://%id%/"]} > "anyOS\org.gamemage.anyos.json"
reg add "HKCU\Software\Google\Chrome\NativeMessagingHosts\org.gamemage.anyos" /ve /t reg_sz /d "%cd%\anyOS\org.gamemage.anyos.json" /f
start chrome --disable-default-apps --enable-logging --v=1 --load-extension="%cd%\anyOS" --enable-experimental-web-platform-features --disable-web-security --user-data-dir="%data%" --app="file://%cd%\Loading"
