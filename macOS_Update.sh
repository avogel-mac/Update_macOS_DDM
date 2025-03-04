#!/bin/bash
#############################################################################
# Shellscript			:	Create DDM Softwareupdate Plan
# Author			:	Andreas Vogel, NEXT Enterprise GmbH
# Info				:	Script only works with macOS Sonoma (14) and higher
#############################################################################
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/jamf/bin/

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )
scriptVersion="1.0.3.b"
debugMode="${6:-"verbose"}"                                                  # Debug Mode [ verbose (default) | true | false ]

# # # # # # # # # # # # # # # # # # # # # # # # # Plist location  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
BundleIDPlist="it.next.macOS.update"
Deferral_Value_Custom=$(/usr/libexec/PlistBuddy -c "Print :Deferral_and_scriptLog:DeferralValueCustom" "/Library/Managed Preferences/${BundleIDPlist}.plist")
DeferralValueCustomCritical=$(/usr/libexec/PlistBuddy -c "Print :Deferral_and_scriptLog:DeferralValueCustomCritical" "/Library/Managed Preferences/${BundleIDPlist}.plist")
Manage_macOSspecificVersion=$(/usr/libexec/PlistBuddy -c "Print :Updates:macOSspecificVersion" "/Library/Managed Preferences/${BundleIDPlist}.plist")
Manage_macOSupdateSelection=$(/usr/libexec/PlistBuddy -c "Print :Updates:macOSupdateSelection" "/Library/Managed Preferences/${BundleIDPlist}.plist")
DontRunMonday=$(/usr/libexec/PlistBuddy -c "Print :Updates:dontRunUpdatesOnDays:Monday" "/Library/Managed Preferences/${BundleIDPlist}.plist" 2>/dev/null) || DontRunMonday="false"
DontRunTuesday=$(/usr/libexec/PlistBuddy -c "Print :Updates:dontRunUpdatesOnDays:Tuesday" "/Library/Managed Preferences/${BundleIDPlist}.plist" 2>/dev/null) || DontRunTuesday="false"
DontRunWednesday=$(/usr/libexec/PlistBuddy -c "Print :Updates:dontRunUpdatesOnDays:Wednesday" "/Library/Managed Preferences/${BundleIDPlist}.plist" 2>/dev/null) || DontRunWednesday="false"
DontRunThursday=$(/usr/libexec/PlistBuddy -c "Print :Updates:dontRunUpdatesOnDays:Thursday" "/Library/Managed Preferences/${BundleIDPlist}.plist" 2>/dev/null) || DontRunThursday="false"
DontRunFriday=$(/usr/libexec/PlistBuddy -c "Print :Updates:dontRunUpdatesOnDays:Friday" "/Library/Managed Preferences/${BundleIDPlist}.plist" 2>/dev/null) || DontRunFriday="false"
DontRunSaturday=$(/usr/libexec/PlistBuddy -c "Print :Updates:dontRunUpdatesOnDays:Saturday" "/Library/Managed Preferences/${BundleIDPlist}.plist" 2>/dev/null) || DontRunSaturday="false"
DontRunSunday=$(/usr/libexec/PlistBuddy -c "Print :Updates:dontRunUpdatesOnDays:Sunday" "/Library/Managed Preferences/${BundleIDPlist}.plist" 2>/dev/null) || DontRunSunday="false"
UpdateHour=$(/usr/libexec/PlistBuddy -c "Print :Updates:runUpdatesOnTime:hour" "/Library/Managed Preferences/${BundleIDPlist}.plist" 2>/dev/null)
UpdateMinute=$(/usr/libexec/PlistBuddy -c "Print :Updates:runUpdatesOnTime:minute" "/Library/Managed Preferences/${BundleIDPlist}.plist" 2>/dev/null)

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # Testing | Script  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
function killProcess() {
	process="$1"
	if process_pid=$( pgrep -a "${process}" 2>/dev/null ) ; then
		echo "Attempting to terminate the '$process' process …"
		echo "(Termination message indicates success.)"
		kill "$process_pid" 2> /dev/null
		if pgrep -a "$process" >/dev/null ; then
			error "'$process' could not be terminated."
		fi
	else
		echo "The '$process' process isn't running."
	fi
}

# Check whether a user is at the computer and the device is not locked by the screensaver. 
# A maximum of 10 times a sleep of 30 seconds is entered before the script continues so that 
# the Jamf process is not held up too long (thanks, @mrmte)
function waitForActiveUser() {
	local KEEP_LOOPING="true"
	local SLEEP_TIME=30
	local IDLE_TIME=0
	local CONSOLE_USER=""
	local SLEEP_COUNT=0
	
	while [ "$KEEP_LOOPING" = "true" ]; do
		if [ "$SLEEP_COUNT" -ge 10 ]; then
			ScriptLogUpdate "Maximum of 10 sleep iterations reached. Exiting waitForActiveUser."
			break
		fi
		
		CONSOLE_USER=`ls -l /dev/console | cut -d " " -f4 | grep -v "^_" | grep -iwv "daemon" | grep -iwv "^nobody" | grep -iwv "^root" | grep -iwv "mbsetup"`
		LOGINWINDOW_PROC=`ps aux | grep -v grep | grep -ci loginwindow`
		
		if [ "$CONSOLE_USER" ] && [ $LOGINWINDOW_PROC -gt 0 ]
			then
				ScriptLogUpdate "$CONSOLE_USER is logged in and loginwindow process is running."
				ps aux | grep [S]creenSaverEngine > /dev/null
				if [ "$?" = "0" ]
					then
						ScriptLogUpdate "Screen Saver is active, waiting $SLEEP_TIME seconds"
						sleep $SLEEP_TIME
						SLEEP_COUNT=$((SLEEP_COUNT + 1))
					else
						IDLE_TIME=`ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print int($NF/1000000000)}'`
						ScriptLogUpdate "Looks like the Mac is active, idle time is: $IDLE_TIME"
						KEEP_LOOPING="false"
				fi
			else
				ScriptLogUpdate "No logged in user, waiting $SLEEP_TIME seconds"
				sleep $SLEEP_TIME
				SLEEP_COUNT=$((SLEEP_COUNT + 1))
		fi
	done
	return 0
}


scriptLog=$(/usr/libexec/PlistBuddy -c "Print :Deferral_and_scriptLog:scriptLog" "/Library/Managed Preferences/${BundleIDPlist}.plist" 2>"/dev/null")
if [[ -z "$scriptLog" ]]; then 
	scriptLog="/var/log/it.next.macOS.Update.log"
fi

if [[ ! -f "${scriptLog}" ]]
	then
		touch "${scriptLog}"
	else
		if [[ $(stat -f%z "${scriptLog}") -gt 10000000 ]]; then
			zipFile="${scriptLog%.log}_$(date +'%Y-%m-%d %H:%M:%S').zip"
			zip -j "${zipFile}" "${scriptLog}"
			
			rm "${scriptLog}"
			
			touch "${scriptLog}"
			echo "$(date +'%Y-%m-%d %H:%M:%S') - log file too large, has been zipped to ${zipFile}" >> "${scriptLog}"
		fi
fi

function ScriptLogUpdate() {
	if [[ "${debugMode}" == "verbose" ]]
		then
			echo -e "$( date +%Y-%m-%d\ %H:%M:%S ) - Line No. ${BASH_LINENO[0]} - ${1}" | tee -a "${scriptLog}"
		else
			echo -e "$( date +%Y-%m-%d\ %H:%M:%S ) - ${1}" | tee -a "${scriptLog}"
	fi
}

ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * START LOG * * * * * * * * * * * * * * * * * * * * * * *"

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # Pre-flight Check  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Confirm script is running as root
if [[ $(id -u) -ne 0 ]]; then
	ScriptLogUpdate "This script must be run as root; exiting."
	killProcess "caffeinate"
	exit 1
fi

# Validate Setup Assistant has completed
while pgrep -q -x "Setup Assistant"; do
	ScriptLogUpdate "Setup Assistant is still running; pausing for 2 seconds"
	sleep 2
done

ScriptLogUpdate "Setup Assistant is no longer running; proceeding …"

# Confirm Dock is running / user is at Desktop
until pgrep -q -x "Finder" && pgrep -q -x "Dock"; do
	ScriptLogUpdate "Finder & Dock are NOT running; pausing for 1 second"
	sleep 1
done

ScriptLogUpdate "Finder & Dock are running; proceeding …"

# Validate Logged-in System Accounts
ScriptLogUpdate "Check for Logged-in System Accounts …"

counter="1"

until { [[ "${currentUser}" != "_mbsetupuser" ]] || [[ "${counter}" -gt "180" ]]; } && { [[ "${currentUser}" != "loginwindow" ]] || [[ "${counter}" -gt "30" ]]; } ; do
	
	ScriptLogUpdate "Logged-in User Counter: ${counter}"
	currentcurrentUser
	sleep 2
	((counter++))
	
done

# Make sure that the computer does not go into sleep mode while the script is running
symPID="$$"
caffeinate -dimsu -w "$symPID" &>/dev/null &

realname=$(dscl . read /Users/$currentUser RealName | tail -n1 | awk '{print $1}')
udid=$(/usr/sbin/ioreg -rd1 -c IOPlatformExpertDevice | /usr/bin/grep -i "UUID" | /usr/bin/cut -c27-62)

current_macOS=$(/usr/bin/sw_vers -productVersion)
macOSMAJOR=$(sw_vers -productVersion | cut -d'.' -f1)
macOSMINOR=$(sw_vers -productVersion | cut -d'.' -f2)

model=$(/usr/sbin/sysctl -n hw.model)

if [[ "$model" == VirtualMac* ]]; then
	ScriptLogUpdate "[ Function-Check Model ]: recognised model $model Virtual devices, are not recognised in the sofa feed"
	model="MacBookPro18,3"
	ScriptLogUpdate "[ Function-Check Model ]: Change this to $model so that the script is not terminated."
fi

case "$macOSMAJOR" in
	15*)
		macOS_Name="Sequoia $macOSMAJOR"      # Sequoia 15
		URL="https://sofa.macadmins.io/macOS_Sequoia.html"
	;;
	14*)
		macOS_Name="Sonoma $macOSMAJOR"       # Sonoma 14
		URL="https://sofa.macadmins.io/macOS_Sonoma.html"
	;;
esac

PLIST="/Library/Preferences/com.apple.SoftwareUpdate.plist"
profilesSTATUS=$(profiles status -type enrollment 2>&1)

Jamf_Pro_URL="https://$(echo "$profilesSTATUS" | grep 'MDM server' | awk -F '/' '{print $3}')"
if [[ -z "$Jamf_Pro_URL" ]]; then
	echo "Jamf Pro URL Fehlt."
	killProcess "caffeinate"
	exit 1
fi

Language=$(/usr/libexec/PlistBuddy -c 'print AppleLanguages:0' "/Users/${currentUser}/Library/Preferences/.GlobalPreferences.plist")
if [[ $Language = de* ]]
	then
		UserLanguage="de"
	else
		UserLanguage="en"
fi


case "${debugMode}" in
	"true")
		ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *"
		ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * Running Skript in debugMode * * * * * * * * * * * *"
		ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *"
	;;
	
	"verbose")
		ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *"
		ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * Running Skript in verbose debugMode * * * * * * * * * *"
		ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *"
	;;
	
	"false")
		ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *"
		ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * Running Skript  * * * * * * * * * * * * * * * * * *"
		ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *"
	;;
esac

jamf_api_client="$4"
if [[ -z "$jamf_api_client" ]]; then
	if [[ "${debugMode}" == "true" ]] || [[ "${debugMode}" == "verbose" ]]
	then
		ScriptLogUpdate "[ Function-Check Jamf API debugMode ]: Jamf Pro Client Secret is missing"
		ScriptLogUpdate "[ Function-Check Jamf API debugMode ]: Skript running in Debug Mode Testing of API Calls not possible"
	else
		ScriptLogUpdate "[ Function-Check Jamf API ]: Jamf Pro Client Secret is missing"
		ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * * #"
		killProcess "caffeinate"
		exit 1
	fi
fi

jamf_api_secret="$5"
if [[ -z "$jamf_api_secret" ]]; then
	if [[ "${debugMode}" == "true" ]] || [[ "${debugMode}" == "verbose" ]]
	then
		ScriptLogUpdate "[ Function-Check Jamf API debugMode ]: Jamf Pro Client Secret is missing"
		ScriptLogUpdate "[ Function-Check Jamf API debugMode ]: Skript running in Debug Mode Testing of API Calls not possible"
		
	else
		ScriptLogUpdate "[ Function-Check Jamf API ]: Jamf Pro Client Secret is missing"
		ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * * #"
		killProcess "caffeinate"
		exit 1
	fi
fi

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # make sure SwiftDialog is installed  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
swiftDialogMinimumRequiredVersion="2.5.0.4768" 
dialog_bin="/usr/local/bin/dialog"
dialog_log="/var/tmp/dialog.log"

function dialogInstall() {
	dialogURL=$(curl -L --silent --fail "https://api.github.com/repos/swiftDialog/swiftDialog/releases/latest" | awk -F '"' "/browser_download_url/ && /pkg\"/ { print \$4; exit }")
	expectedDialogTeamID="PWA5E9TQ59"
	
	ScriptLogUpdate "[ Function-Check SwiftDialog ]: Installing swiftDialog..."
	
	workDirectory=$( /usr/bin/basename "$0" )
	tempDirectory=$( /usr/bin/mktemp -d "/private/tmp/$workDirectory.XXXXXX" )
	
	/usr/bin/curl --location --silent "$dialogURL" -o "$tempDirectory/Dialog.pkg"
	
	teamID=$(/usr/sbin/spctl -a -vv -t install "$tempDirectory/Dialog.pkg" 2>&1 | awk '/origin=/ {print $NF }' | tr -d '()')
	
	if [[ "$expectedDialogTeamID" == "$teamID" ]]
		then			/usr/sbin/installer -pkg "$tempDirectory/Dialog.pkg" -target /
			sleep 2
			dialogVersion=$( /usr/local/bin/dialog --version )
			ScriptLogUpdate "[ Function-Check SwiftDialog ]: swiftDialog version ${dialogVersion} installed; proceeding..."
			
		else
			ScriptLogUpdate "[ Function-Check SwiftDialog ]: swiftDialog could not be installed"
			/bin/rm -Rf "$tempDirectory"
			killProcess "caffeinate"
			exit 1
	fi
	/bin/rm -Rf "$tempDirectory"
}

function dialogCheck() {
	if [ ! -e "/Library/Application Support/Dialog/Dialog.app" ]
		then
			ScriptLogUpdate "[ Function-Check SwiftDialog ]: swiftDialog not found. Installing..."
			dialogInstall
		else
			dialogVersion=$(/usr/local/bin/dialog --version)
			if [[ "${dialogVersion}" < "${swiftDialogMinimumRequiredVersion}" ]]
				then
					ScriptLogUpdate "[ Function-Check SwiftDialog ]: swiftDialog version ${dialogVersion} found but swiftDialog ${swiftDialogMinimumRequiredVersion} or newer is required; updating..."
					dialogInstall
				else
					ScriptLogUpdate "[ Function-Check SwiftDialog ]: swiftDialog version ${dialogVersion} found; proceeding..."
			fi
	fi
} 

dialogCheck

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # Enable BootstrapToken with currentUser  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
function Enable_BootstrapToken_with_currentUser() {
	BootstrapToken_iconPath="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/FileVaultIcon.icns"
	BootstrapToken_title_de="Fehlernder Bootstrap-Token"
	secondTitlePassword_de="Gebe dein aktuelles macOS-Kennwort ein, mit dem Du dich auf deinem Gerät anmeldest."
	Passcode_Field_de="Leider fehlt das Bootstrap-Token auf Deinem System. Wir werden es reaktivieren. Hierfür benötigen wir das Passwort. Bitte gebe Dein macOS-Passwort in das Feld ein."
	mainButtonLabelPassword_de="Weiter"
	passwordRegexErrorMessage_de="Das angegebene Passwort entspricht nicht den Anforderungen."
	placeholderPassword_de="Passwort hier eingeben"
	
	BootstrapToken_title_en="Missing bootstrap token"
	secondTitlePassword_en="Enter your current macOS password that you use to log in to your device."
	Passcode_Field_en="Unfortunately, the bootstrap token is missing on your system. We will reactivate it. For this we need the password. Please enter your macOS password in the field."
	mainButtonLabelPassword_en="Continue"
	passwordRegexErrorMessage_en="The provided password does not meet the requirements."
	placeholderPassword_en="Enter password here"
	
	BootstrapToken_title=BootstrapToken_title_${UserLanguage}
	secondTitlePassword=secondTitlePassword_${UserLanguage}
	Passcode_Field=Passcode_Field_${UserLanguage}
	mainButtonLabelPassword=mainButtonLabelPassword_${UserLanguage}
	passwordRegexErrorMessage=passwordRegexErrorMessage_${UserLanguage}
	placeholderPassword=placeholderPassword_${UserLanguage}
	
	passwordRegex="^[^\s]{4,}$"
	
	maxAttempts=3
	attempt=1
	
	while [ $attempt -le $maxAttempts ]; do
		dialog=$("$dialog_bin" --title "${!BootstrapToken_title}" --message "${!Passcode_Field}" --button1text "${!mainButtonLabelPassword}" --icon "$BootstrapToken_iconPath" --textfield "${!secondTitlePassword}",prompt="${!placeholderPassword}",regex="$passwordRegex",regexerror="${!passwordRegexErrorMessage}",secure=true,required=yes)
		
		userPass=$(echo "$dialog" | grep "${!secondTitlePassword}" | awk -F " : " '{print $NF}' &)
		
		/usr/bin/dscl /Search -authonly "$currentUser" "$userPass"
		
		if [ $? -eq 0 ]
			then
				ScriptLogUpdate "[ Function-activate the bootstrap token ]: User has entered the valid password"
				break
			else
				echo "Authentication failed (attempt $attempt of $maxAttempts)"
				((attempt++))
		fi
	done
	
	if [ $attempt -gt $maxAttempts ]; then
		ScriptLogUpdate "[ Function-activate the bootstrap token ]: Maximum attempts reached. Exiting."
		ScriptLogUpdate "[ Function-activate the bootstrap token ]: User has repeatedly entered the wrong password. "
		ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * *"
		killProcess "caffeinate"
		exit 1
	fi
	
	removeAdmin="false"
	if groups $currentUser | grep -q -w admin
		then
			ScriptLogUpdate "[ Function-activate the bootstrap token ]: Current user: $currentUser is already an administrator"
		else
			ScriptLogUpdate "[ Function-activate the bootstrap token ]: The current user: $currentUser is standard and will added to the Admin-Group"
			/usr/sbin/dseditgroup -o edit -a $currentUser -t user admin
			removeAdmin="true"
	fi
	
	result=$(/usr/bin/profiles install -type bootstraptoken -user "${currentUser}" -password "${userPass}" 2>&1)
	
	if [[ $result == *"Unable to authenticate user information"* ]]
		then
			ScriptLogUpdate "[ Function-activate the bootstrap token ]: Error. Token could not be activated "
			
			if [[ $removeAdmin == "true" ]]; then
				dseditgroup -o edit -d $currentUser -t user admin
				ScriptLogUpdate "[ Function-activate the bootstrap token ]: The current user: $currentUser, is removed from the admin group and demoted to standard user."
			fi
			ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * *"
			killProcess "caffeinate"
			exit 1
			
		else
			if [[ $removeAdmin == "true" ]]; then
				dseditgroup -o edit -d $currentUser -t user admin
				ScriptLogUpdate "[ Function-activate the bootstrap token ]: The current user: $currentUser, is removed from the admin group and demoted to standard user."
			fi
			
			/usr/local/bin/jamf recon
			
			ScriptLogUpdate "[ Function-activate the bootstrap token ]: Bootstrap token was successfully activated and transferred to Jamf Pro."
			Bootstrap_Token="true"
	fi
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # Teste vorraussetzungen  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
DDM_Supportet_macOS="false"
if [[ $macOSMAJOR -ge 14 ]]; then
DDM_Supportet_macOS="true"
fi

function checkMDMService() {
	
	mdmENROLLED="false"	
	
	if [[ $(echo "$profilesSTATUS" | grep -c 'MDM server') -gt 0 ]]; then
			mdmENROLLED="true"
			if [[ $(echo "$profilesSTATUS" | grep 'Enrolled via DEP:' | grep -c 'Yes') -gt 0 ]]
				then
					ScriptLogUpdate "[ Function-Check MDM Service ]: Device is ADE enrolled."
				else
					ScriptLogUpdate "[ Function-Check MDM Service ]: Device is UIE enrolled, try it."
			fi
			
			curlRESULT=$(curl -Is "$Jamf_Pro_URL" | head -n 1)
			Jamf_Pro_URL_available="false"
			if [[ $(echo "$curlRESULT" | grep -c 'HTTP') -gt 0 ]] && [[ $(echo "$curlRESULT" | grep -c -e '400' -e '40[4-9]' -e '4[1-9][0-9]' -e '5[0-9][0-9]') -eq 0 ]]
				then
					Jamf_Pro_URL_available="true"
				else
					ScriptLogUpdate "URL: $Jamf_Pro_URL could not be reached via CURL."
					ScriptLogUpdate "Attempting to reach the server using the Jamf binary and verify the URL."
					
					jss_output=$(/usr/local/bin/jamf checkJSSConnection 2>&1)
					if echo "$jss_output" | grep -q "The JSS is available."
						then
							jss_new_url=$(echo "$jss_output" | grep -m1 "Checking availability of" | grep -oE 'https://[a-zA-Z0-9\.-]+')
							ScriptLogUpdate "Old URL could not be reached. URL validated via JSS check. Setting new URL: $jss_new_url"
							Jamf_Pro_URL="$jss_new_url"
							Jamf_Pro_URL_available="true"
						else
							ScriptLogUpdate "JSS check failed, no valid URL determined."
					fi
			fi
	fi
}

function check_Bootstrap_Token_local_on_Device() {
	
	checkMDMService
	Bootstrap_Token="false"
	# ScriptLogUpdate "[ Function-Check Bootstrap Token ]: Checking the bootstrap token status local on the macOS"
	if [[ $(profiles status -type bootstraptoken | grep -ic 'YES') -eq 2 ]]
		then
			Bootstrap_Token="true"
		else
			ScriptLogUpdate "[ Function-Check Bootstrap Token ]: Warning Bootstrap token is not escrowed to MDM Server"
			Enable_BootstrapToken_with_currentUser
	fi
}

check_Bootstrap_Token_local_on_Device


if [[ $mdmENROLLED == "true" ]]
then
	ScriptLogUpdate "[ Function-Check MDM Service ]: Jamf Pro URL could be extracted on the device."
	ScriptLogUpdate "[ Function-Check MDM Service ]: Check if Jamf Pro is accessible."
	
	if [[ $Jamf_Pro_URL_available == "true" ]]
	then
		ScriptLogUpdate "[ Function-Check MDM Service ]: Test Successful. Server $Jamf_Pro_URL available."
		
		if [[ $Bootstrap_Token == "true" ]]
		then
			ScriptLogUpdate "[ Function-Check Bootstrap Token ]: Bootstrap token is set and escrowed to MDM Server."
			
			if [[ $DDM_Supportet_macOS == "true" ]]
			then
				ScriptLogUpdate "[ Function-Check macOS prerequisites ]: macOS requirements are fulfilled"
				ScriptLogUpdate "[ Function-Check macOS prerequisites ]: macOS $current_macOS is installed"
			else
				ScriptLogUpdate "[ Function-Check macOS prerequisites ]: The installed macOS: $current_macOS does not support DDM."
				"# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * *"
				killProcess "caffeinate"
			exit 1
			fi
			
		else
			ScriptLogUpdate "[ Function-Check Bootstrap Token ]: Is not set and could not be transferred successfully"
			killProcess "caffeinate"
			exit 1
		fi
		
	else
		ScriptLogUpdate "[ Function-Check MDM Service ]: ERROR Server at $Jamf_Pro_URL is unavailable, status code: $curlRESULT"
		ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * *"
		killProcess "caffeinate"
		exit 1
	fi
	
else
	ScriptLogUpdate "[ Function-Check MDM Service ]: Warning Device is not enrolled with a MDM service or URL cold not be extracted."
	ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * *"
	killProcess "caffeinate"
	exit 1
fi


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # Get Sofa Feed # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
function get_macos_data_Sofa_feed() {
	
	macos_data_feed="$(curl -s --compressed https://sofafeed.macadmins.io/v1/macos_data_feed.json)"
	if ! grep -q "\"$model\"" <<< "$macos_data_feed"; then
		ScriptLogUpdate "[ Sofa Data Feed ]: Could not find your model ($model) in the JSON feed"
		killProcess "caffeinate"
		exit 1
	fi
	
	supported_os=$(echo "$macos_data_feed" | plutil -extract "Models.$model.SupportedOS.0" raw -expect string -o - - 2>/dev/null)
	if [[ -z "$supported_os" ]]; then
		ScriptLogUpdate "[ Sofa Data Feed ]: Could not find SupportedOS for $model"
		killProcess "caffeinate"
		exit 1
	fi
	
	ScriptLogUpdate "[ Sofa Data Feed ]: Latest Supported OS for $model: $supported_os"
	
	index=""
	length=$(echo "$macos_data_feed" | plutil -extract "OSVersions" xml1 -o - - 2>/dev/null | xmllint --xpath 'count(//array/dict)' - 2>/dev/null)
	if [[ -z "$length" ]]; then
		length=10
		echo "fallback length=10"
	fi
	
	i=0
	while [[ $i -lt $length ]]; do
		this_os=$(echo "$macos_data_feed" | plutil -extract "OSVersions.$i.OSVersion" raw -expect string -o - - 2>/dev/null)
		if [[ "$this_os" == "$macOS_Name" ]]; then
			index=$i
			break
		fi
		((i++))
	done
	
	if [[ -z "$index" ]]; then
		ScriptLogUpdate "[ Sofa Data Feed ]: Could not find OSVersion \"$macOS_Name\" in the feed"
		killProcess "caffeinate"
		exit 1
	fi
	
	latest_product_version=$(echo "$macos_data_feed" | plutil -extract "OSVersions.$index.Latest.ProductVersion" raw -o - - 2>/dev/null)
	latest_cves=$(echo "$macos_data_feed" | plutil -extract "OSVersions.$index.Latest.UniqueCVEsCount" raw -expect integer -o - - 2>/dev/null)
	
	latest_exploits=$(echo "$macos_data_feed" | plutil -extract "OSVersions.$index.Latest.ActivelyExploitedCVEs" xml1 -o - - 2>/dev/null | xmllint --xpath 'count(//array/string)' - 2>/dev/null)
	latest_exploits=$(printf "%.0f" "$latest_exploits")
	
	if [[ -z "$latest_product_version" ]]; then
		latest_product_version="Unknown"
	fi
	
	if [[ -z "$latest_cves" ]]; then
		latest_cves="0"
	fi
	
	if [[ -z "$latest_exploits" ]]; then
		latest_exploits="0"
	fi
	
	critical_Update="false"
	critical_Update_text=""
	if [[ $latest_exploits -gt 0 ]]; then
		critical_Update="true"
		critical_Update_text="Critical Update"
	fi
	
	Sofa_Infobox="CVEs: $latest_cves \n\nActiveExploits: $latest_exploits \n\n$critical_Update_text"
	
	unset macos_data_feed
}

function get_local_SoftwareUpdate_plist_data() {
	
	/usr/sbin/softwareupdate -l 2>&1 >/dev/null
		
	latest_upgradeAvailable_local_plist="false"
	latest_upgradeVersion_local_plist=""
	
	latest_updateAvailable_local_plist="false"
	latest_updateVersion_local_plist=""
	
	recommendedUpdates=$(defaults read "$PLIST" RecommendedUpdates 2>/dev/null)
	while IFS= read -r line; do
		
		if [[ "$line" =~ \"Product[[:space:]]Key\" ]]; then
			productKey=$(echo "$line" | sed -n 's/.*= "\(.*\)";/\1/p')
			
			if [[ "$productKey" == *"major"* ]]; then
				latest_upgradeAvailable_local_plist="true"
				latest_upgradeVersion_local_plist=$(echo "$productKey" | sed -E 's/.*patch_(([0-9]+\.)+[0-9]+).*/\1/')
				
			elif [[ "$productKey" == *"minor"* ]]; then
				latest_updateAvailable_local_plist="true"
				latest_updateVersion_local_plist=$(echo "$productKey" | sed -E 's/.*patch_(([0-9]+\.)+[0-9]+).*/\1/')
			fi
		fi
	done <<< "$recommendedUpdates"
	
	if [[ "$latest_upgradeAvailable_local_plist" == "true" ]]; then
		ScriptLogUpdate "[ Function-Check macOS ]: Upgrade available: Version $latest_upgradeVersion_local_plist"
	fi
	
	if [[ "$latest_updateAvailable_local_plist" == "true" ]]; then
		ScriptLogUpdate "[ Function-Check macOS ]: Update available: Version $latest_updateVersion_local_plist"
	fi
}



get_macos_data_Sofa_feed
get_local_SoftwareUpdate_plist_data

# Check whether both values are either empty or explicitly ‘false’
if { [ -z "$UpdateHour" ] || [ "$UpdateHour" = "false" ]; } && { [ -z "$UpdateMinute" ] || [ "$UpdateMinute" = "false" ]; }; then
	ScriptLogUpdate "Both UpdateHour and UpdateMinute are not set or marked as 'false'."
	ScriptLogUpdate "-> Using the current system time for both values."
	UpdateHour="false"
	UpdateMinute="false"
	ScriptLogUpdate "Current system time: UpdateHour = $UpdateHour, UpdateMinute = $UpdateMinute"
else
	# Check whether both values are either empty or explicitly ‘false “If only UpdateHour is missing or ”false’, the current hour value is adopted.
	if [ -z "$UpdateHour" ] || [ "$UpdateHour" = "false" ]; then
		ScriptLogUpdate "UpdateHour is not set or marked as 'false'."
		ScriptLogUpdate "-> Using the current system hour."
		UpdateHour=$(date +%H)
		ScriptLogUpdate "New UpdateHour: $UpdateHour"
	fi
	# If only UpdateMinute is missing or ‘false’, the current minute value is adopted.
	if [ -z "$UpdateMinute" ] || [ "$UpdateMinute" = "false" ]; then
		ScriptLogUpdate "UpdateMinute is not set or marked as 'false'."
		ScriptLogUpdate "-> Using the current system minute."
		UpdateMinute=$(date +%M)
		ScriptLogUpdate "New UpdateMinute: $UpdateMinute"
	fi
	ScriptLogUpdate "Time set by the administrator (or partially overridden)."
	ScriptLogUpdate "-> Updates will be executed at: ${UpdateHour}:${UpdateMinute}"
fi


currentUnixTime=$(date +%s)

# 1. Calculate the base deferral days (as provided by the administrator)
if [ "$critical_Update" == "true" ]
then
	deferral_days=$DeferralValueCustomCritical
else
	deferral_days=$Deferral_Value_Custom
fi


if [ "$UpdateHour" != "false" ] && [ -n "$UpdateHour" ] && [ "$UpdateMinute" != "false" ] && [ -n "$UpdateMinute" ]
then
	base_date=$(date -j -v+${deferral_days}d "+%Y-%m-%d")
	target_datetime_str="${base_date}T$(printf "%02d" $UpdateHour):$(printf "%02d" $UpdateMinute):00"
	targetUnixTime=$(date -j -f "%Y-%m-%dT%H:%M:%S" "$target_datetime_str" "+%s")
else
	targetUnixTime=$(( currentUnixTime + deferral_days * 86400 ))
fi

# 3. Determine the day of the week of the base timestamp (1 = Monday, ... , 7 = Sunday)
target_day=$(date -j -f "%s" "$targetUnixTime" "+%u")

# Function: Checks if updates are allowed on a given day (number 1 to 7)
is_day_allowed() {
	daynum=$1
	case $daynum in
		1) flag=$DontRunMonday ;;
		2) flag=$DontRunTuesday ;;
		3) flag=$DontRunWednesday ;;
		4) flag=$DontRunThursday ;;
		5) flag=$DontRunFriday ;;
		6) flag=$DontRunSaturday ;;
		7) flag=$DontRunSunday ;;
		*) flag="false" ;;
	esac
	if [ "$flag" = "true" ]; then
		return 1   # Day NOT allowed
	else
		return 0   # Day allowed
	fi
}

# 4. Check if the base timestamp is allowed.
if is_day_allowed "$target_day"
then
	finalUnixTime=$targetUnixTime
else
	initialDayName=$(/bin/date -j -f "%s" "$targetUnixTime" "+%A")
	ScriptLogUpdate "Determined day of the week is ${initialDayName}. Updates are not allowed on this day. Finding the next available day."
	
	# Option A: Forward adjustment (search for the next allowed day in the future)
	ScriptLogUpdate "Determining forward option..."
	forwardUnixTime=$targetUnixTime
	while true; do
		forwardUnixTime=$(( forwardUnixTime + 86400 ))
		forward_day=$(date -j -f "%s" "$forwardUnixTime" "+%u")
		if is_day_allowed "$forward_day"; then
			break
		fi
	done
	forwardDayName=$(/bin/date -j -f "%s" "$forwardUnixTime" "+%A")
	ScriptLogUpdate "Forward option: Next allowed day is ${forwardDayName} on $(/bin/date -j -f "%s" "$forwardUnixTime" "+%Y-%m-%dT%H:%M:%S")"
	
	# Option B: Backward adjustment (search for the next allowed day in the past)
	ScriptLogUpdate "Determining backward option..."
	backwardUnixTime=$targetUnixTime
	while true; do
		candidate=$(( backwardUnixTime - 86400 ))
		if [ $candidate -le $currentUnixTime ]; then
			backwardUnixTime=0
			break
		fi
		backwardUnixTime=$candidate
		backward_day=$(date -j -f "%s" "$backwardUnixTime" "+%u")
		if is_day_allowed "$backward_day"; then
			break
		fi
	done
	
	if [ $backwardUnixTime -gt 0 ]
	then
		backwardDayName=$(/bin/date -j -f "%s" "$backwardUnixTime" "+%A")
		ScriptLogUpdate "Backward option: Next allowed day is ${backwardDayName} on $(/bin/date -j -f "%s" "$backwardUnixTime" "+%Y-%m-%dT%H:%M:%S")"
	else
		ScriptLogUpdate "No valid backward option found."
	fi
	
	# 5. Compare both options:
	forward_diff=$(( forwardUnixTime - currentUnixTime ))
	backward_diff=$(( backwardUnixTime - currentUnixTime ))
	
	# Minimum allowed time according to the granted deferrals (in seconds)
	minAllowed=$(( deferral_days * 86400 ))
	
	# If the backward candidate does not reach the minimum deferral:
	if [ $backward_diff -lt $minAllowed ]
	then
		diff_undershoot=$(( (minAllowed - backward_diff) / 86400 ))
		diff_overshoot=$(( (forward_diff - minAllowed) / 86400 ))
		ScriptLogUpdate "In the backward option check, the granted deferral period ($deferral_days) is undershot by ${diff_undershoot} day(s)."
		ScriptLogUpdate "Therefore, the next available day is chosen. This exceeds the granted deferral period by ${diff_overshoot} day(s)."
		finalUnixTime=$forwardUnixTime
	else
		# Otherwise, choose the option that is closer to the current time.
		if [ $backward_diff -le $forward_diff ]
		then
			finalUnixTime=$backwardUnixTime
		else
			finalUnixTime=$forwardUnixTime
		fi
	fi
fi

futureUnixTimeDateTime=$(/bin/date -j -f "%s" "$finalUnixTime" "+%Y-%m-%dT%H:%M:%S")
ScriptLogUpdate "Scheduled update time: $futureUnixTimeDateTime"

case "$Manage_macOSupdateSelection" in
	"SPECIFIC_VERSION")
		planversionType="SPECIFIC_VERSION"
		planspecificVersion="$Manage_macOSspecificVersion"
		latest_updateVersion="$Manage_macOSspecificVersion"
	;;
	
	"LATEST_ANY")
		if [[ "$latest_upgradeAvailable_local_plist" == "true" || "$latest_updateAvailable_local_plist" == "true" ]]; then
			ScriptLogUpdate "[ Function-Check macOS ]: Update available."
			
			planversionType="LATEST_ANY"
			planspecificVersion="NO_SPECIFIC_VERSION"
			latest_updateVersion="$latest_upgradeVersion_local_plist"
			latest_updateVersion="$latest_updateVersion_local_plist"
		else
			ScriptLogUpdate "[ Function-Check macOS ]: No updates available."
			case "$debugMode" in
				true|verbose)
					ScriptLogUpdate "[ Function-Check macOS ]: Debug mode active, continuing script without exit."
					latest_updateVersion="Debug"
				;;
				false|*)
					killProcess "caffeinate"
					exit 0
				;;
			esac
		fi
	;;
	
	"LATEST_MAJOR")
		if [[ "$latest_upgradeAvailable_local_plist" == "true" ]]; then
			ScriptLogUpdate "[ Function-Check macOS ]: Upgrade available."
			
			planversionType="LATEST_MAJOR"
			planspecificVersion="NO_SPECIFIC_VERSION"
			latest_updateVersion="$latest_upgradeVersion_local_plist"
		else
			echo "Kein Upgrade für das Gerät verfügbar."
			case "$debugMode" in
				true|verbose)
					ScriptLogUpdate "[ Function-Check macOS ]: Debug mode active, continuing script without exit."
					latest_updateVersion="Debug"
				;;
				false|*)
					killProcess "caffeinate"
					exit 0
				;;
			esac
		fi
	;;
	
	"LATEST_MINOR")
		if [[ "$latest_updateAvailable_local_plist" == "true" ]]; then
			ScriptLogUpdate "[ Function-Check macOS ]: Update available."
			
			planversionType="LATEST_MINOR"
			planspecificVersion="NO_SPECIFIC_VERSION"
			latest_updateVersion="$latest_updateVersion_local_plist"
		else
			ScriptLogUpdate "[ Function-Check macOS ]: No update available for the device."
			case "$debugMode" in
				true|verbose)
					ScriptLogUpdate "[ Function-Check macOS ]: Debug mode active, continuing script without exit."
					latest_updateVersion="Debug"
				;;
				false|*)
					killProcess "caffeinate"
					exit 0
				;;
			esac
		fi
	;;
	
	*)
		ScriptLogUpdate "[ Function-Check macOS ]: Invalid value for Manage_macOSupdateSelection: $Manage_macOSupdateSelection"
		killProcess "caffeinate"
		exit 1
	;;
esac


case ${debugMode} in
	"true"      ) scriptVersion="DEBUG MODE | Dialog: v${dialogVersion} • DDM macOS Updates: v${scriptVersion}" ;;
	"verbose"   ) scriptVersion="DEBUG MODE | Dialog: v${dialogVersion} • DDM macOS Updates: v${scriptVersion}" ;;
	"false"     ) scriptVersion="DDM macOS Updates: v.${scriptVersion}" ;;
esac

function get_status_description() {
	plan_is_active="false"
	
	local state="$1"
	case "$state" in
		Unknown)
			status_description="The plan was either just created and could not be fully initialized yet, or the database is corrupted."
		;;
		Init)
			status_description="The plan has been created and is waiting for queue assignment so processing can start."
			plan_is_active="true"
		;;
		PendingPlanValidation)
			status_description="The plan is currently processing validation logic for the selected options, inventory data, and remote operating system data."
			plan_is_active="true"
		;;
		AcceptingPlan)
			status_description="The plan has passed all validation checks and has been added to the planning queue."
			plan_is_active="true"
		;;
		ProcessingPlanType)
			status_description="The plan is determining which update action path should be chosen."
			plan_is_active="true"
		;;
		RejectingPlan)
			status_description="The validation of the plan has failed, and it will be removed from the planning queue."
		;;
		StartingPlan)
			status_description="The plan is being moved out of the planning queue so the software update can start."
			plan_is_active="true"
		;;
		PlanFailed)
			status_description="Either the validation of the plan failed, or a service returned a condition indicating the plan should not proceed due to an unforeseen error condition."
		;;
		SchedulingScanForOSUpdates)
			status_description="A ScheduleOSUpdateScan command has been queued for the computer. This command prompts the computers to update their list of available updates."
			plan_is_active="true"
		;;
		ProcessingScheduleOSUpdatesScanResponse)
			status_description="A ScheduleOSUpdateScan command was returned by the computer, and the plan is determining the next step."
			plan_is_active="true"
		;;
		WaitingForScheduleOSUpdateScanToComplete)
			status_description="The planning logic is waiting for a timeout before processing the next step."
			plan_is_active="true"
		;;
		CollectingAvailableOSUpdates)
			status_description="An AvailableOSUpdates command has been queued for the computer. This command requests all updates available for installation from computers and mobile devices."
			plan_is_active="true"
		;;
		ProcessingAvailableOSUpdatesResponse)
			status_description="An AvailableOSUpdates command was returned by the computer, and the plan is determining the next step."
			plan_is_active="true"
		;;
		ProcessingSchedulingType)
			status_description="The plan intends to execute either an MDM installation or a declarative device management installation."
			plan_is_active="true"
		;;
		SchedulingDDM)
			status_description="The plan intends to perform a declarative device management installation: Declarations are created on Jamf's declarative storage service, and a DeclarativeManagement command is queued for the computer."
			plan_is_active="true"
		;;
		SchedulingMDM)
			status_description="The plan proceeds with an MDM installation."
		;;
		WaitingToStartDDMUpdate)
			status_description="The plan is waiting for the first status update from declarative device management on the computer, indicating that the software update has started."
			plan_is_active="true"
		;;
		ProcessingDDMStatusResponse)
			status_description="The plan determines the next step based on the latest status update from the computer."
			plan_is_active="true"
		;;
		CollectingDDMStatus)
			status_description="The latest status update indicated that the software update is still in progress, and the plan will continue to monitor the update."
			plan_is_active="true"
		;;
		SchedulingOSUpdate)
			status_description="A ScheduleOSUpdate command has been queued for the computer."
			plan_is_active="true"
		;;
		ProcessingScheduleOSUpdateResponse)
			status_description="A ScheduleOSUpdate command was returned by the computer, and the plan is determining the next step."
			plan_is_active="true"
		;;
		CollectingOSUpdateStatus)
			status_description="An OSUpdateStatus command has been queued for the computer. This command informs about the progress of downloading and installing the software update."
			plan_is_active="true"
		;;
		ProcessingOSUpdateStatusResponse)
			status_description="An OSUpdateStatus command was returned by the computer, and the plan is determining the next step."
			plan_is_active="true"
		;;
		WaitingToCollectOSUpdateStatus)
			status_description="The plan has paused processing to give the computer time to continue the software update process before requesting another OSUpdateStatus command."
			plan_is_active="true"
		;;
		PlanCompleted)
			status_description="The plan has been successfully completed. The software update is installed on the computer."
		;;
		PlanCanceled)
			status_description="The plan was canceled because an MDM command in the queue was manually canceled by a Jamf Pro user."
		;;
		PlanException)
			status_description="The plan encountered an exception condition that was not accounted for. The plan will stop permanently."
		;;
		ProcessingPlanTypeMdm)
			status_description="The plan is determining which MDM command to queue first for the installation action."
			plan_is_active="true"
		;;
		*)
			status_description="Unknown status: $state"
			plan_is_active="true"
		;;
	esac
}


function get_error_description() {
	local error="$1"
	case "$error" in
		APPLE_SILICON_NO_ESCROW_KEY)
			echo "The computer has an M-series chip and requires the escrow of the bootstrap token for fully autonomous software updates."
		;;
		NOT_SUPERVISED)
			echo "The device is currently not supervised, so MDM commands fail."
		;;
		NOT_MANAGED)
			echo "The device is currently not managed, so MDM commands fail."
		;;
		NO_DISK_SPACE)
			echo "The latest inventory data indicates the computer's storage is full."
		;;
		NO_UPDATES_AVAILABLE)
			echo "Remote operating system data indicates there are currently no updates available for the computer's current operating system."
		;;
		SPECIFIC_VERSION_UNAVAILABLE)
			echo "The requested version is not available on Apple's servers."
		;;
		ACTION_NOT_SUPPORTED_FOR_DEVICE_TYPE)
			echo "The requested action is not supported for the device type."
		;;
		PLAN_NOT_FOUND)
			echo "The plan could not proceed because it was manually removed from the database."
		;;
		APPLE_SOFTWARE_LOOKUP_SERVICE_ERROR)
			echo "Apple's update servers are offline, and the last response is not currently cached on the Jamf Pro server (e.g., server restart)."
		;;
		EXISTING_PLAN_FOR_DEVICE_IN_PROGRESS)
			echo "A plan has been sent to a computer or mobile device that already has a plan in progress."
		;;
		DECLARATIVE_DEVICE_MANAGEMENT_SOFTWARE_UPDATES_NOT_SUPPORTED_FOR_DEVICE_OS_VERSION)
			echo "Download, install, and scheduling actions are only supported for macOS 14 or later, iOS 17 or later, iPadOS 17 or later, and tvOS 17 or later."
		;;
		DOWNGRADE_NOT_SUPPORTED)
			echo "Apple does not support operating system downgrades via MDM or declarative device management, and the selected specific version indicates an attempt to downgrade the OS version."
		;;
		DECLARATIVE_SERVICE_ERROR)
			echo "An error occurred in communication with the server, and the declarative device management update will not be scheduled."
		;;
		UNABLE_TO_FIND_UPDATES_AND_OUT_OF_RETRIES)
			echo "If a computer does not return available updates, Jamf Pro retries the request to collect these updates up to four times."
		;;
		DATA_INTEGRITY_VIOLATION_EXCEPTION)
			echo "A database integrity violation was detected and prevented to avoid database corruption."
		;;
		ILLEGAL_ARGUMENT_EXCEPTION)
			echo "An illegal argument was detected in an update status received from a device during a software update."
		;;
		MDM_EXCEPTION)
			echo "An unexpected error occurred while queuing MDM commands for a plan."
		;;
		ACCEPT_PLAN_FAILURE)
			echo "An unexpected error occurred while accepting a plan."
		;;
		SCHEDULE_PLAN_FAILURE)
			echo "An unexpected error occurred while scheduling a plan."
		;;
		REJECT_PLAN_FAILURE)
			echo "An unexpected error occurred while rejecting a plan."
		;;
		START_PLAN_FAILURE)
			echo "An unexpected error occurred while starting a plan."
		;;
		QUEUE_SCHEDULED_OS_UPDATE_SCAN_FAILURE)
			echo "An unexpected error occurred while queuing the 'ScheduleOsUpdateScan' command."
		;;
		SCAN_WAIT_FINISHED_FAILURE)
			echo "An unexpected error occurred while updating a plan to indicate the 'ScheduleOsUpdateScan' command has completed."
		;;
		QUEUE_AVAILABLE_OS_UPDATE_COMMAND_FAILURE)
			echo "An unexpected error occurred while queuing the 'AvailableOsUpdates' command."
		;;
		MDM_CLIENT_EXCEPTION)
			echo "An MDM client exception occurred while queuing the 'ScheduleOsUpdate' command."
		;;
		QUEUE_SCHEDULE_OS_UPDATE_FAILURE)
			echo "An unexpected error occurred while queuing the 'ScheduleOsUpdate' command."
		;;
		QUEUE_OS_UPDATE_STATUS_COMMAND_FAILURE)
			echo "An unexpected error occurred while queuing the 'OsUpdateStatus' command."
		;;
		STILL_IN_PROGRESS_FAILURE)
			echo "An unexpected error occurred while checking if the 'OsUpdateStatusResponse' command is still in progress."
		;;
		WAIT_TO_COLLECT_OS_UPDATE_STATUS_FAILURE)
			echo "An unexpected error occurred while waiting to collect the operating system update status for an ongoing device update."
		;;
		IS_DOWNLOADED_AND_NEEDS_INSTALL_FAILURE)
			echo "An unexpected error occurred while checking if the download is complete and the update needs to be installed."
		;;
		IS_INSTALLED_FAILURE)
			echo "An unexpected error occurred while checking if an update was successfully installed."
		;;
		IS_DOWNLOAD_ONLY_AND_DOWNLOADED_FAILURE)
			echo "An unexpected error occurred while checking if an update with the 'Download only' command was completed."
		;;
		VERIFY_INSTALLATION_FAILURE)
			echo "An unexpected error occurred while verifying the installation of an update."
		;;
		IS_MAC_OS_UPDATE_FAILURE)
			echo "An unexpected error occurred while determining if a plan is intended for a macOS update."
		;;
		IS_LATEST_FAILURE)
			echo "An unexpected error occurred while starting a plan with version type LATEST_MAJOR, LATEST_MINOR, or LATEST_ANY."
		;;
		IS_SPECIFIC_VERSION_FAILURE)
			echo "An unexpected error occurred while starting a plan with a specific version type."
		;;
		HANDLE_COMMAND_QUEUE_FAILURE)
			echo -e "An unexpected error occurred while attempting to queue one of the following commands:\nAvailableOsUpdates\nOsUpdateStatus\nScheduleOsUpdate\nScheduleOsUpdateScan"
		;;
		SPECIFIC_VERSION_UNAVAILABLE_FOR_DEVICE_MODEL)
			echo "The specific version is listed as available for the device's OS type but is not compatible with the device model number."
		;;
		INVALID_CONFIGURATION_DECLARATION)
			echo "The device responded with an invalid configuration declaration, causing the plan to fail."
		;;
		UNKNOWN)
			echo "The database has been corrupted."
		;;
		*)
			echo "Unknown error: $error"
		;;
	esac
}

function extract_json_value() {
	local json="$1"
	local key="$2"
	echo "$json" | grep -o "\"$key\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | awk -F'"' '{print $4}'
}

function extract_json_value_array() {
	local json="$1"
	local key="$2"
	echo "$json" | grep -o "\"$key\"[[:space:]]*:[[:space:]]*\[[^]]*\]" | \
	sed -E "s/\"$key\"[[:space:]]*:[[:space:]]*\[//;s/\]//" | \
	tr -d '"' | tr ',' '\n' | sed 's/^ *//;s/ *$//'
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # Token Handling  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
function delete_api_token() {
	invalidateTOKEN=$(curl --header "Authorization: Bearer ${api_token}" --write-out "%{http_code}" --silent --output /dev/null --request POST --url "${Jamf_Pro_URL}/api/v1/auth/invalidate-token")
	if [[ $invalidateTOKEN -eq 204 ]]; then
		ScriptLogUpdate "[ Function-Revoke API Token ]: Jamf Pro API token successfully invalidated."
	elif [[ $invalidateTOKEN -eq 401 ]]; then
		ScriptLogUpdate "[ Function-Revoke API Token ]: Jamf Pro API token already invalid."
	else
		ScriptLogUpdate "[ Function-Revoke API Token ]: Invalidating Jamf Pro API token."
	fi
}

function get_api_token() {
	if [[ "${debugMode}" == "true" ]] || [[ "${debugMode}" == "verbose" ]]
	then
		ScriptLogUpdate "[ Function-GET API Token debugMode]: debugMode is activated"
		ScriptLogUpdate "[ Function-GET API Token debugMode]: try to call the API if credentials are available"
		
		if [[ -n "$jamf_api_client" && -n "$jamf_api_secret" ]]
		then
			curl_response=$(curl --silent --location --request POST "${Jamf_Pro_URL}/api/oauth/token" --header "Content-Type: application/x-www-form-urlencoded" --data-urlencode "client_id=${jamf_api_client}" --data-urlencode "grant_type=client_credentials" --data-urlencode "client_secret=${jamf_api_secret}")
			
			if [[ $(echo "${curl_response}" | grep -c 'token') -gt 0 ]]
			then
				if [[ $(sw_vers -productVersion | cut -d'.' -f1) -lt 12 ]]
					then
						api_token=$(echo "${curl_response}" | plutil -extract access_token raw -)
					else 
						api_token=$(echo "${curl_response}" | awk -F '"' '{print $4;}' | xargs)
				fi
				ScriptLogUpdate "[ Function-GET API Token ]: Token was successfully generated"
				
			else
				ScriptLogUpdate "[ Function-GET API Token ]: Token could not be generated"
				ScriptLogUpdate "[ Function-GET API Token ]: Verify the --auth-jamf-client=ClientID and --auth-jamf-secret=ClientSecret are values."
				
				ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * * #"
				killProcess "caffeinate"
				exit 1
			fi
		else
			ScriptLogUpdate "[ Function-GET API Token debugMode]: no credentials available."
			ScriptLogUpdate "[ Function-GET API Token debugMode]: Continue with the test to display the dialogues."
		fi
		
	else
		
		curl_response=$(curl --silent --location --request POST "${Jamf_Pro_URL}/api/oauth/token" --header "Content-Type: application/x-www-form-urlencoded" --data-urlencode "client_id=${jamf_api_client}" --data-urlencode "grant_type=client_credentials" --data-urlencode "client_secret=${jamf_api_secret}")
		
		if [[ $(echo "${curl_response}" | grep -c 'token') -gt 0 ]]
		then
			if [[ $(sw_vers -productVersion | cut -d'.' -f1) -lt 12 ]]
			then
				api_token=$(echo "${curl_response}" | plutil -extract access_token raw -)
			else 
				api_token=$(echo "${curl_response}" | awk -F '"' '{print $4;}' | xargs)
			fi
			ScriptLogUpdate "[ Function-GET API Token ]: Token was successfully generated"
		else
			ScriptLogUpdate "[ Function-GET API Token ]: Token could not be generated"
			ScriptLogUpdate "[ Function-GET API Token ]: Verify the --auth-jamf-client=ClientID and --auth-jamf-secret=ClientSecret are values."
			ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * * #"
			killProcess "caffeinate"
			exit 1
		fi
	fi
}

function refresh_api_token() {
	delete_api_token
	get_api_token
}

function updateCLI() {
	open "x-apple.systempreferences:com.apple.preferences.softwareupdate"
}

function check_DDM_Status_Jamf() {
	DDM_API_READY="false"
	if [[ "${debugMode}" == "true" ]] || [[ "${debugMode}" == "verbose" ]]
	then
		ScriptLogUpdate "[ Function-Find Correct API debugMode]: debugMode is activated"
		ScriptLogUpdate "[ Function-Find Correct API debugMode]: try to call the API if credentials are available"
		
		if [[ -n "$jamf_api_client" && -n "$jamf_api_secret" ]]
		then
			refresh_api_token
			ScriptLogUpdate "[ Function-Find Correct API debugMode]: Credentials are available"
			curl_response=$(curl --silent --write-out "%{http_code}" --location --request GET "${Jamf_Pro_URL}/api/v1/managed-software-updates/plans/feature-toggle" --header "Authorization: Bearer ${api_token}" --header "Content-Type: application/json")
			
			if [[ $(echo "${curl_response}" | grep -c '200') -gt 0 ]]
			then
				if [[ $(echo "${curl_response}" | grep -e 'toggle' | grep -c 'true') -gt 0 ]]
				then
					ScriptLogUpdate "[ Function-Find Correct API ]: Send the command to update the device via the new API"
					DDM_API_READY="true"
					ScriptLogUpdate "[ Function-Find Correct API ]: Current MajorOS $macOSMAJOR supports DDM"
				else
					ScriptLogUpdate "[ Function-Find Correct API ]: Send the command via the old API. Please switch to the new API soon"
					ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * *"
					delete_api_token
					killProcess "caffeinate"
					exit 1
				fi
			else
				ScriptLogUpdate "[ Function-Find Correct API ]: ERROR"
				ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * *"
				delete_api_token
				killProcess "caffeinate"
				exit 1
			fi
		else
			ScriptLogUpdate "[ Function-Find Correct API debugMode]: No credentials. API command cannot be sent."
			ScriptLogUpdate "[ Function-Find Correct API debugMode]: The theoretical API is being determined."
			
			DDM_API_READY="true"
			ScriptLogUpdate "[ Function-Find Correct API debugMode ]: Current MajorOS $macOSMAJOR supports DDM"
		fi
	else
		curl_response=$(curl --silent --write-out "%{http_code}" --location --request GET "${Jamf_Pro_URL}/api/v1/managed-software-updates/plans/feature-toggle" --header "Authorization: Bearer ${api_token}" --header "Content-Type: application/json")
		
		if [[ $(echo "${curl_response}" | grep -c '200') -gt 0 ]]
		then
			if [[ $(echo "${curl_response}" | grep -e 'toggle' | grep -c 'true') -gt 0 ]]
			then
				ScriptLogUpdate "[ Function-Find Correct API ]: Send the command to update the device via the new API"
				DDM_API_READY="true"
			else
				ScriptLogUpdate "[ Function-Find Correct API ]: Send the command via the old API. Please switch to the new API soon"
				ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * *"
				delete_api_token
				killProcess "caffeinate"
				exit 1
				
			fi
		else
			ScriptLogUpdate "[ Function-Find Correct API ]: ERROR"
			ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * *"
			delete_api_token
			killProcess "caffeinate"
			exit 1
		fi
	fi
}

function get_Device_Informations_from_Jamf() {
	refresh_api_token
	deviceID=""
	bootstrap_status=""
	DDM_Status_on_Server="false"
	
	deviceID_response=$(curl --silent --write-out "%{http_code}" --location --request GET "$Jamf_Pro_URL/JSSResource/computers/udid/$udid" --header "Authorization: Bearer ${api_token}" -H "accept: application/xml")
	
	if [[ $(echo "${deviceID_response}" | grep -c '200') -gt 0 ]]
	then
		deviceID=$(echo $deviceID_response | /usr/bin/awk -F'<id>|</id>' '{print $2}')
		
		if [[ -n "$deviceID" ]];
		then
			security_inventory_response=$(curl --silent --write-out "%{http_code}" --location --request GET "${Jamf_Pro_URL}/api/v1/computers-inventory/${deviceID}?section=SECURITY" --header "Accept: application/json" --header "Authorization: Bearer ${api_token}")
			
			if [[ $(echo "${security_inventory_response}" | grep -c '200') -gt 0 ]]
			then
				bootstrap_status=$(echo "$security_inventory_response" | grep -o '"bootstrapTokenEscrowedStatus"\s*:\s*"[^"]*"' | awk -F':' '{gsub(/"/, "", $2); print $2}')
				
				if [[ -n "$bootstrap_status" ]]
				then
					if [[ "$bootstrap_status" != " ESCROWED" ]]; then
						ScriptLogUpdate "[ Function-Get Device Informations ]: bootstrapTokenEscrowedStatus is not ESCROWED. Execute Enable_BootstrapToken_with_currentUser."
						Enable_BootstrapToken_with_currentUser
					fi
				else
					ScriptLogUpdate "[ Function-Get Device Informations ]: Error: Could not extract bootstrapTokenEscrowedStatus."
					delete_api_token
					killProcess "caffeinate"
			exit 1
				fi
			else
				delete_api_token
				killProcess "caffeinate"
				exit 1
			fi
		else
			ScriptLogUpdate "[ Function-Get Device Informations ]: Error: Could not extract device ID."
			delete_api_token
			killProcess "caffeinate"
			exit 1
		fi
	else
		delete_api_token
		killProcess "caffeinate"
		exit 1
	fi
	
	DDM_response=$(curl -s --request GET "${Jamf_Pro_URL}/api/v1/computers-inventory/${deviceID}?section=GENERAL" -H "accept: application/json" -H "Authorization: Bearer ${api_token}" )
	DDM_Status_in_Jamf=$(echo "$DDM_response" | tr -d '\r' | grep -m1 'declarativeDeviceManagementEnabled' | grep -oE 'true|false')
	
	if [[ -n "$DDM_Status_in_Jamf" ]]
	then
		if [[ "$DDM_Status_in_Jamf" != "true" ]]
		then
			ScriptLogUpdate "[ Function-Get Device Informations ]: declarativeDeviceManagementEnabled is not true please check device"
			killProcess "caffeinate"
			exit 1
		else
			DDM_Status_on_Server="true"
		fi
	else
		ScriptLogUpdate "[ Function-Get Device Informations ]: Error: Could not extract bootstrapTokenEscrowedStatus."
		delete_api_token
		killProcess "caffeinate"
		exit 1
	fi
}

function create_DDM_Update_Plan() {
	refresh_api_token 
	
	jamfJSON='{
				"devices": [
					{
						"objectType": "COMPUTER",
						"deviceId": "'${deviceID}'"
					}
				],
				"config": {
					"updateAction": "DOWNLOAD_INSTALL_SCHEDULE",
					"versionType": "'${planversionType}'",
					"specificVersion": "'${planspecificVersion}'",
					"forceInstallLocalDateTime": "'${futureUnixTimeDateTime}'"
				}
			}'
	
	if [[ "${debugMode}" == "true" ]] || [[ "${debugMode}" == "verbose" ]]; then
		ScriptLogUpdate "[ Function- create_DDM_Update_Plan debugMode ]: The following update plan is created with the following settings"
		
		echo "$jamfJSON"
	fi
	
	
	create_new_Update_Plan=$(curl --header "Authorization: Bearer ${api_token}" --header "Content-Type: application/json" --write-out "%{http_code}" --silent --show-error --request POST --url "${Jamf_Pro_URL}/api/v1/managed-software-updates/plans" --data "${jamfJSON}")
	
	if [[ $(echo "$create_new_Update_Plan" | grep -c '200') -gt 0 ]] || [[ $(echo "$create_new_Update_Plan" | grep -c '201') -gt 0 ]]
	then
		ScriptLogUpdate "[ Function-Create Plan ]: Successful MDM command for update/upgrade was sent successfully."
		planID=$(echo "$create_new_Update_Plan" | grep -o '"planId" : "[^"]*' | awk -F'"' '{print $4}')
		
		if [[ ! -z "$planID" ]]
		then
			ScriptLogUpdate "[ Function-Create Plan ]: Plan ID: $planID"
			ScriptLogUpdate "[ Function-Create Plan ]: wait until the plan has had time to arrive on the computer and has been processed."
			
			ScriptLogUpdate "Wait for 300 seconds (5 minutes) and then check the status of the plan"
			
			sleep 300
			
			refresh_api_token
			
			new_planDetails=$(curl -s -H "Authorization: Bearer $api_token" "$Jamf_Pro_URL/api/v1/managed-software-updates/plans/$planID")
			
			updateAction=$(extract_json_value "$new_planDetails" "updateAction")
			versionType=$(extract_json_value "$new_planDetails" "versionType")
			specificVersion=$(extract_json_value "$new_planDetails" "specificVersion")
			buildVersion=$(extract_json_value "$new_planDetails" "buildVersion")
			maxDeferrals=$(extract_json_value "$new_planDetails" "maxDeferrals")
			forceInstallLocalDateTime=$(extract_json_value "$new_planDetails" "forceInstallLocalDateTime")
			state=$(extract_json_value "$new_planDetails" "state")
			errorReasons=$(extract_json_value_array "$new_planDetails" "errorReasons")
			
			if [[ -n "$forceInstallLocalDateTime" ]]
			then
				Human_read_forceInstallLocalDateTime=$(date -j -f "%Y-%m-%dT%H:%M:%S" "$forceInstallLocalDateTime" +"%d-%m-%Y %H:%M" 2>/dev/null)
				if [[ -n "$Human_read_forceInstallLocalDateTime" ]]
				then
					ScriptLogUpdate "Umgewandelte Zeit: $Human_read_forceInstallLocalDateTime"
					existing_active_plan="true"
				else
					ScriptLogUpdate "Error during the conversion of forceInstallLocalDateTime: $forceInstallLocalDateTime"
					killProcess "caffeinate"
			exit 1
				fi
			else
				ScriptLogUpdate "forceInstallLocalDateTime not found or empty."
				killProcess "caffeinate"
				exit 1
			fi
			
			
		else
			ScriptLogUpdate "[ Function-Create Plan ]: Error when extracting the plan ID."
			killProcess "caffeinate"
			exit 1
		fi
	else
		ScriptLogUpdate ""$create_new_Update_Plan""
		ScriptLogUpdate "[ Function-Create Plan ]: Command could not be sent."
		delete_api_token
		ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * *"
		
		killProcess "caffeinate"
		exit 1
	fi
}

function get_all_Plans_information_for_Device() {
	refresh_api_token
	existing_active_plan="false"
	existingPlansResponse=$(curl -s -H "Authorization: Bearer $api_token" "$Jamf_Pro_URL/api/v1/managed-software-updates/plans?filter=device.deviceId==$deviceID")
	
	if [ $? -ne 0 ]; then
		ScriptLogUpdate "Error sending the API request."
		killProcess "caffeinate"
		exit 1
	fi
	
	if [[ ! "$existingPlansResponse" =~ ^\{.*\}$ ]]; then
		ScriptLogUpdate "Invalid JSON response received."
		killProcess "caffeinate"
		exit 1
	fi
	
	planCount=$(echo "$existingPlansResponse" | grep -o '"planUuid"[[:space:]]*:[[:space:]]*"[a-f0-9\-]*"' | wc -l)
	
	if [ "$planCount" -eq 0 ]
	then
		ScriptLogUpdate "No update plans found for deviceId $deviceID."
		if [[ "$debugMode" == "true" || "$debugMode" == "verbose" ]]
		then
			case "$Manage_macOSupdateSelection" in
				"LATEST_ANY")
					if [[ "$latest_updateAvailable_local_plist" == "true" || "$latest_upgradeAvailable_local_plist" == "true" ]]
					then
						ScriptLogUpdate "creating plan in debug mode"
						create_DDM_Update_Plan
					else
						ScriptLogUpdate "no updates or upgrades available, skipping plan creation. Continue with dialog display"
					fi
				;;
				"LATEST_MAJOR")
					if [[ "$latest_upgradeAvailable_local_plist" == "true" ]]
					then
						ScriptLogUpdate "creating plan in debug mode"
						create_DDM_Update_Plan
					else
						ScriptLogUpdate "no upgrades available, skipping plan creation. Continue with dialog display"
					fi
				;;
				"LATEST_MINOR")
					if [[ "$latest_updateAvailable_local_plist" == "true" ]]
					then
						ScriptLogUpdate "creating plan in debug mode"
						create_DDM_Update_Plan
					else
						ScriptLogUpdate "no updates available, skipping plan creation. Continue with dialog display"
					fi
				;;
				*)
					ScriptLogUpdate "Unknown macOS update selection: $Manage_macOSupdateSelection"
				;;
			esac
		else
			ScriptLogUpdate "creating plan"
			create_DDM_Update_Plan
		fi
	else
		planUUIDs=$(echo "$existingPlansResponse" | grep -o '"planUuid"[[:space:]]*:[[:space:]]*"[a-f0-9\-]*"' | awk -F'"' '{print $4}')
		
		active_plans=""
		for uuid in $planUUIDs; do
			planDetails=$(curl -s -H "Authorization: Bearer $api_token" "$Jamf_Pro_URL/api/v1/managed-software-updates/plans/$uuid")
			
			updateAction=$(extract_json_value "$planDetails" "updateAction")
			versionType=$(extract_json_value "$planDetails" "versionType")
			specificVersion=$(extract_json_value "$planDetails" "specificVersion")
			buildVersion=$(extract_json_value "$planDetails" "buildVersion")
			maxDeferrals=$(extract_json_value "$planDetails" "maxDeferrals")
			forceInstallLocalDateTime=$(extract_json_value "$planDetails" "forceInstallLocalDateTime")
			state=$(extract_json_value "$planDetails" "state")
			errorReasons=$(extract_json_value_array "$planDetails" "errorReasons")
			
			get_status_description "$state"
			
			if [[ "$plan_is_active" == "true" ]]; then
				active_plans="$active_plans $uuid"
			fi
			
		done
		
		active_plans=$(echo "$active_plans" | sed 's/^ *//;s/ *$//')
		
		if [[ -n "$active_plans" ]]
		then
			plan_count=$(echo "$active_plans" | wc -w | xargs)
			
			if [[ $plan_count -gt 1 ]]
			then
				ScriptLogUpdate "The following plans are active:"
				for active_uuid in $active_plans; do
					echo "  - $active_uuid"
				done
				ScriptLogUpdate "There can only be one active plan."
				ScriptLogUpdate "Please check the get_status_description function."
				killProcess "caffeinate"
				exit 1
				
			else
				for active_uuid in $active_plans; do
					ScriptLogUpdate "The following plan is active: $active_uuid"
				done
				
				ScriptLogUpdate "Check details for the active plan"
				active_planDetails=$(curl -s -H "Authorization: Bearer $api_token" "$Jamf_Pro_URL/api/v1/managed-software-updates/plans/$active_uuid")
				active_forceInstallLocalDateTime=$(extract_json_value "$active_planDetails" "forceInstallLocalDateTime")
				
				if [[ -n "$active_forceInstallLocalDateTime" ]]
				then
					Human_read_forceInstallLocalDateTime=$(date -j -f "%Y-%m-%dT%H:%M:%S" "$active_forceInstallLocalDateTime" +"%d-%m-%Y %H:%M" 2>/dev/null)
					if [[ -n "$Human_read_forceInstallLocalDateTime" ]]
					then
						updateAction=$(extract_json_value "$active_planDetails" "updateAction")
						versionType=$(extract_json_value "$active_planDetails" "versionType")
						specificVersion=$(extract_json_value "$active_planDetails" "specificVersion")
						buildVersion=$(extract_json_value "$active_planDetails" "buildVersion")
						maxDeferrals=$(extract_json_value "$active_planDetails" "maxDeferrals")
						state=$(extract_json_value "$active_planDetails" "state")
						errorReasons=$(extract_json_value_array "$active_planDetails" "errorReasons")
						
						
						echo "----------------------------------------"
						echo "updateAction: $updateAction"
						echo "versionType: $versionType"
						echo "specificVersion: $specificVersion"
						echo "forceInstallLocalDateTime: $forceInstallLocalDateTime"
						echo "Transformed time: $Human_read_forceInstallLocalDateTime"
						echo "state: $state"
						echo "Status description: $status_description"
						echo "----------------------------------------"
						
						if [[ -n "$errorReasons" ]]; then
							for error in $errorReasons; do
								echo "  - EROR: $error"
								echo "    Beschreibung: $(get_error_description "$error")"
							done
							echo
						fi
						
						existing_active_plan="true"
					else
						echo "Error during the conversion of forceInstallLocalDateTime: $active_forceInstallLocalDateTime"
						killProcess "caffeinate"
						exit 1
					fi
				else
					echo "forceInstallLocalDateTime not found or empty."
					killProcess "caffeinate"
					exit 1
				fi
			fi
		else
			ScriptLogUpdate "[ Function-Check macOS ]: No active plan found."
			if [[ "$debugMode" == "true" || "$debugMode" == "verbose" ]]
			then
				case "$Manage_macOSupdateSelection" in
					"LATEST_ANY")
						if [[ "$latest_updateAvailable_local_plist" == "true" || "$latest_upgradeAvailable_local_plist" == "true" ]]
						then
							ScriptLogUpdate "creating plan in debug mode"
							create_DDM_Update_Plan
						else
							ScriptLogUpdate "no updates or upgrades available, skipping plan creation. Continue with dialog display"
						fi
					;;
					"LATEST_MAJOR")
						if [[ "$latest_upgradeAvailable_local_plist" == "true" ]]
						then
							ScriptLogUpdate "creating plan in debug mode"
							create_DDM_Update_Plan
						else
							ScriptLogUpdate "no upgrades available, skipping plan creation. Continue with dialog display"
						fi
					;;
					"LATEST_MINOR")
						if [[ "$latest_updateAvailable_local_plist" == "true" ]]
						then
							ScriptLogUpdate "creating plan in debug mode"
							create_DDM_Update_Plan
						else
							ScriptLogUpdate "no updates available, skipping plan creation. Continue with dialog display"
						fi
					;;
					*)
						ScriptLogUpdate "Unknown macOS update selection: $Manage_macOSupdateSelection"
					;;
				esac
			else
				ScriptLogUpdate "creating plan"
				create_DDM_Update_Plan
			fi
		fi
	fi
}
if [[ "${debugMode}" == "true" ]] || [[ "${debugMode}" == "verbose" ]] 
	then
		if [[ -n "$jamf_api_client" && -n "$jamf_api_secret" ]]
			then
				
				ScriptLogUpdate "[ Function-Check macOS debugMode ]: Credentials available."
				get_Device_Informations_from_Jamf
				get_all_Plans_information_for_Device
				
			else
				
				ScriptLogUpdate "[ Function-Check macOS debugMode ]: No credentials available."
				critical_Update="false"
				
			# Check whether both values are either empty or explicitly ‘false’
			if { [ -z "$UpdateHour" ] || [ "$UpdateHour" = "false" ]; } && { [ -z "$UpdateMinute" ] || [ "$UpdateMinute" = "false" ]; }; then
				ScriptLogUpdate "Both UpdateHour and UpdateMinute are not set or marked as 'false'."
				ScriptLogUpdate "-> Using the current system time for both values."
				UpdateHour="false"
				UpdateMinute="false"
				ScriptLogUpdate "Current system time: UpdateHour = $UpdateHour, UpdateMinute = $UpdateMinute"
			else
				# Check whether both values are either empty or explicitly ‘false “If only UpdateHour is missing or ”false’, the current hour value is adopted.
				if [ -z "$UpdateHour" ] || [ "$UpdateHour" = "false" ]; then
					ScriptLogUpdate "UpdateHour is not set or marked as 'false'."
					ScriptLogUpdate "-> Using the current system hour."
					UpdateHour=$(date +%H)
					ScriptLogUpdate "New UpdateHour: $UpdateHour"
				fi
				# If only UpdateMinute is missing or ‘false’, the current minute value is adopted.
				if [ -z "$UpdateMinute" ] || [ "$UpdateMinute" = "false" ]; then
					ScriptLogUpdate "UpdateMinute is not set or marked as 'false'."
					ScriptLogUpdate "-> Using the current system minute."
					UpdateMinute=$(date +%M)
					ScriptLogUpdate "New UpdateMinute: $UpdateMinute"
				fi
				ScriptLogUpdate "Time set by the administrator (or partially overridden)."
				ScriptLogUpdate "-> Updates will be executed at: ${UpdateHour}:${UpdateMinute}"
			fi
			
			
			currentUnixTime=$(date +%s)
			
			# 1. Calculate the base deferral days (as provided by the administrator)
			if [ "$critical_Update" == "true" ]
			then
				deferral_days=$DeferralValueCustomCritical
			else
				deferral_days=$Deferral_Value_Custom
			fi
			
			
			if [ "$UpdateHour" != "false" ] && [ -n "$UpdateHour" ] && [ "$UpdateMinute" != "false" ] && [ -n "$UpdateMinute" ]
			then
				base_date=$(date -j -v+${deferral_days}d "+%Y-%m-%d")
				target_datetime_str="${base_date}T$(printf "%02d" $UpdateHour):$(printf "%02d" $UpdateMinute):00"
				targetUnixTime=$(date -j -f "%Y-%m-%dT%H:%M:%S" "$target_datetime_str" "+%s")
			else
				targetUnixTime=$(( currentUnixTime + deferral_days * 86400 ))
			fi
			
			# 3. Determine the day of the week of the base timestamp (1 = Monday, ... , 7 = Sunday)
			target_day=$(date -j -f "%s" "$targetUnixTime" "+%u")
			
			# Function: Checks if updates are allowed on a given day (number 1 to 7)
			is_day_allowed() {
				daynum=$1
				case $daynum in
					1) flag=$DontRunMonday ;;
					2) flag=$DontRunTuesday ;;
					3) flag=$DontRunWednesday ;;
					4) flag=$DontRunThursday ;;
					5) flag=$DontRunFriday ;;
					6) flag=$DontRunSaturday ;;
					7) flag=$DontRunSunday ;;
					*) flag="false" ;;
				esac
				if [ "$flag" = "true" ]; then
					return 1   # Day NOT allowed
				else
					return 0   # Day allowed
				fi
			}
			
			# 4. Check if the base timestamp is allowed.
			if is_day_allowed "$target_day"
			then
				finalUnixTime=$targetUnixTime
			else
				initialDayName=$(/bin/date -j -f "%s" "$targetUnixTime" "+%A")
				ScriptLogUpdate "Determined day of the week is ${initialDayName}. Updates are not allowed on this day. Finding the next available day."
				
				# Option A: Forward adjustment (search for the next allowed day in the future)
				ScriptLogUpdate "Determining forward option..."
				forwardUnixTime=$targetUnixTime
				while true; do
					forwardUnixTime=$(( forwardUnixTime + 86400 ))
					forward_day=$(date -j -f "%s" "$forwardUnixTime" "+%u")
					if is_day_allowed "$forward_day"; then
						break
					fi
				done
				forwardDayName=$(/bin/date -j -f "%s" "$forwardUnixTime" "+%A")
				ScriptLogUpdate "Forward option: Next allowed day is ${forwardDayName} on $(/bin/date -j -f "%s" "$forwardUnixTime" "+%Y-%m-%dT%H:%M:%S")"
				
				# Option B: Backward adjustment (search for the next allowed day in the past)
				ScriptLogUpdate "Determining backward option..."
				backwardUnixTime=$targetUnixTime
				while true; do
					candidate=$(( backwardUnixTime - 86400 ))
					if [ $candidate -le $currentUnixTime ]; then
						backwardUnixTime=0
						break
					fi
					backwardUnixTime=$candidate
					backward_day=$(date -j -f "%s" "$backwardUnixTime" "+%u")
					if is_day_allowed "$backward_day"; then
						break
					fi
				done
				
				if [ $backwardUnixTime -gt 0 ]
				then
					backwardDayName=$(/bin/date -j -f "%s" "$backwardUnixTime" "+%A")
					ScriptLogUpdate "Backward option: Next allowed day is ${backwardDayName} on $(/bin/date -j -f "%s" "$backwardUnixTime" "+%Y-%m-%dT%H:%M:%S")"
				else
					ScriptLogUpdate "No valid backward option found."
				fi
				
				# 5. Compare both options:
				forward_diff=$(( forwardUnixTime - currentUnixTime ))
				backward_diff=$(( backwardUnixTime - currentUnixTime ))
				
				# Minimum allowed time according to the granted deferrals (in seconds)
				minAllowed=$(( deferral_days * 86400 ))
				
				# If the backward candidate does not reach the minimum deferral:
				if [ $backward_diff -lt $minAllowed ]
				then
					diff_undershoot=$(( (minAllowed - backward_diff) / 86400 ))
					diff_overshoot=$(( (forward_diff - minAllowed) / 86400 ))
					ScriptLogUpdate "In the backward option check, the granted deferral period ($deferral_days) is undershot by ${diff_undershoot} day(s)."
					ScriptLogUpdate "Therefore, the next available day is chosen. This exceeds the granted deferral period by ${diff_overshoot} day(s)."
					finalUnixTime=$forwardUnixTime
				else
					# Otherwise, choose the option that is closer to the current time.
					if [ $backward_diff -le $forward_diff ]
					then
						finalUnixTime=$backwardUnixTime
					else
						finalUnixTime=$forwardUnixTime
					fi
				fi
			fi
			
			futureUnixTimeDateTime=$(/bin/date -j -f "%s" "$finalUnixTime" "+%Y-%m-%dT%H:%M:%S")
			ScriptLogUpdate "Scheduled update time: $futureUnixTimeDateTime"
			
				Human_read_forceInstallLocalDateTime=$(date -j -f "%Y-%m-%dT%H:%M:%S" "$futureUnixTimeDateTime" +"%d-%m-%Y %H:%M" 2>/dev/null)
		fi
	else
		
		get_Device_Informations_from_Jamf
		get_all_Plans_information_for_Device
fi

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # Read Plist Variablen  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# * * * * * * * * * * * * * * * * * * * * * * * * Timers and values * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #
ScriptLogUpdate=$(/usr/libexec/PlistBuddy -c "Print :Messanges:MaxMessageTime" "/Library/Managed Preferences/${BundleIDPlist}.plist" 2>/dev/null) || ScriptLogUpdate="300"
buttontimer_Final_Message_Custom=$(/usr/libexec/PlistBuddy -c "Print :Buttontimer:buttontimer_Final_Message" "/Library/Managed Preferences/${BundleIDPlist}.plist" 2>/dev/null) || buttontimer_Final_Message_Custom="15"

# * * * * * * * * * * * * * * * * * * * * * * * * Test and Messages * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #
Install_Button_Custom=$(/usr/libexec/PlistBuddy -c "Print :Messanges:InstallButtonLabel" "/Library/Managed Preferences/${BundleIDPlist}.plist" 2>/dev/null) || Install_Button_Custom="NOW"
Defer_Button_Custom=$(/usr/libexec/PlistBuddy -c "Print :Messanges:DeferButtonLabel" "/Library/Managed Preferences/${BundleIDPlist}.plist" 2>/dev/null) || Defer_Button_Custom="LATER"
Defer_Button_Custom=$(echo -e "$Defer_Button_Custom")

# * * * * * * * * * * * * * * * * * * * * * * * * SwiftDialog Window  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #
Dialog_update_width=$(/usr/libexec/PlistBuddy -c "Print :Dialog_Settings:Dialog_update_width" "/Library/Managed Preferences/${BundleIDPlist}.plist" 2>/dev/null) || Dialog_update_width="740"
Dialog_update_height=$(/usr/libexec/PlistBuddy -c "Print :Dialog_Settings:Dialog_update_height" "/Library/Managed Preferences/${BundleIDPlist}.plist" 2>/dev/null) || Dialog_update_height="540"
Dialog_update_titlefont=$(/usr/libexec/PlistBuddy -c "Print :Dialog_Settings:Dialog_update_titlefont" "/Library/Managed Preferences/${BundleIDPlist}.plist" 2>/dev/null) || Dialog_update_titlefont="20"
Dialog_update_messagefont=$(/usr/libexec/PlistBuddy -c "Print :Dialog_Settings:Dialog_update_messagefont" "/Library/Managed Preferences/${BundleIDPlist}.plist" 2>/dev/null) || Dialog_update_messagefont="14"

Standard_Update_Prompt=`/usr/libexec/PlistBuddy -c "Print :Messanges:StandardUpdatePrompt" /Library/Managed\ Preferences/${BundleIDPlist}.plist`
Standard_Update_Prompt="$(echo -e "$Standard_Update_Prompt" | /usr/bin/sed "s/%REAL_NAME%/${realname}/" | /usr/bin/sed "s/%CURRENT_DEFERRAL_VALUE%/${CurrentDeferralValue}/" | /usr/bin/sed "s/%Install_Button_Custom%/${Install_Button_Custom}/" | /usr/bin/sed "s/%forceInstallLocalDateTime%/${Human_read_forceInstallLocalDateTime}/")"


Banner_dialog="false"
BannerImage=$(/usr/libexec/PlistBuddy -c "Print :Dialog_Settings:BannerImage" "/Library/Managed Preferences/${BundleIDPlist}.plist" 2>/dev/null) || BannerImage=""
if [[ -n "$BannerImage" ]]; then
	Banner_dialog="true"
fi


Script_default_icon=$(/usr/libexec/PlistBuddy -c "Print :Dialog_Settings:Default_Icon:Script_default" "/Library/Managed Preferences/${BundleIDPlist}.plist" 2>/dev/null) || Script_default_icon="false"
if [[ "$Script_default_icon" == "true" ]]
	then
		Custem_icon=$(/usr/libexec/PlistBuddy -c "Print :Dialog_Settings:Default_Icon:Custem_icon" "/Library/Managed Preferences/${BundleIDPlist}.plist" 2>/dev/null) || Custem_icon=""
		if [[ -n "$Custem_icon" ]]
			then
				Icon="$Custem_icon"
				ScriptLogUpdate "Using the managed value: $Icon"
			else
				ScriptLogUpdate "Value is set to managed, but no path is specified"
				Icon="SF=gear.badge"
		fi
	else
		Icon="SF=gear.badge"
fi

Dialog_overlayicon="false"
Overlayicon_Self_Service_default=$(/usr/libexec/PlistBuddy -c "Print :Dialog_Settings:Dialog_overlayicon:Self_Service_default" "/Library/Managed Preferences/${BundleIDPlist}.plist" 2>/dev/null) || Overlayicon_Self_Service_default="false"
if [[ "$Overlayicon_Self_Service_default" == "true" ]]; then
	Custem_overlay_icon=$(/usr/libexec/PlistBuddy -c "Print :Dialog_Settings:Dialog_overlayicon:Custem_overlay_icon" "/Library/Managed Preferences/${BundleIDPlist}.plist" 2>/dev/null) || Custem_overlay_icon=""
	if [[ -n "$Custem_overlay_icon" ]]
		then
			overlayicon="$Custem_overlay_icon"
			ScriptLogUpdate "Using the profile-defined setting: $Custem_overlay_icon"
			Dialog_overlayicon="true"
		else
			ScriptLogUpdate "No custom overlay icon specified Use the Self Service default"
			overlayicon="/Users/$currentUser/Library/Application Support/com.jamfsoftware.selfservice.mac/Documents/Images/brandingimage.png"
			Dialog_overlayicon="true"
	fi
fi

Device_Info_de="Geräteinformationen"
Device_Info_en="Device information"

Current_OS_de="Instal. macOS"
Current_OS_en="Installed macOS"

available_OS_de="neues Update"
available_OS_en="new Update"

CurrentDeferralValue_Text_de="Verschieb. übrig"
CurrentDeferralValue_Text_en="Deferrals remaining"

remainingDaysTitel_de="verbleibende Tage"
remainingDaysTitel_en="remaining Days"

remainingHourseTitel_de="verbleibende Stunden"
remainingHourseTitel_en="remaining Hours"

Device_Info=Device_Info_${UserLanguage}
Current_OS=Current_OS_${UserLanguage}
available_OS=available_OS_${UserLanguage}
CurrentDeferralValue_Text=CurrentDeferralValue_Text_${UserLanguage}
remainingDaysTitel=remainingDaysTitel_${UserLanguage}
remainingHourseTitel=remainingHourseTitel_${UserLanguage}
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # Create default Dialog Arguments # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
waitForActiveUser

buttontimer=$buttontimer_Final_Message_Custom
case ${debugMode} in
	"false"     ) dialog_bin="${dialog_bin}" ;;
	"true"      ) dialog_bin="${dialog_bin} --verbose" ;;
	"verbose"   ) dialog_bin="${dialog_bin} --verbose --resizable --debug red" ;;
esac

[ "${Banner_dialog}" = "true" ] && dialog_bin="${dialog_bin} --bannerimage \"${BannerImage}\""
[ "${Dialog_overlayicon}" = "true" ] && dialog_bin="${dialog_bin} --overlayicon \"${overlayicon}\""

Promt_Dialog_to_User="$dialog_bin \
--moveable \
--ontop \
--quitkey f \
--position centre \
--alignment left \
--titlefont 'size=$Dialog_update_titlefont' \
--messagefont 'size=$Dialog_update_messagefont' \
--width $Dialog_update_width \
--height $Dialog_update_height \
--title \"macOS Softwareupdate\" \
--message \"$Standard_Update_Prompt\" \
--icon \"$Icon\" \
--iconsize 128 \
--button1text \"$Install_Button_Custom in $buttontimer\" \
--button1disabled \
--button2text \"$Defer_Button_Custom in $buttontimer\" \
--button2disabled \
--timer \"$ScriptLogUpdate\" \
--infobox \"_________________\n\n"${!Device_Info}"\n\n${!Current_OS}: $current_macOS \n\n${!available_OS}: $latest_updateVersion \n_________________\nUpdate Details \n\n$Sofa_Infobox\" \
--commandfile \"$dialog_log\" \
--infotext \"$scriptVersion\" \ "

eval "${Promt_Dialog_to_User}" & sleep 0.1

pid=$!

while [ $buttontimer -gt 0 ];
do
	/bin/echo "button1text: $Install_Button_Custom in $buttontimer" >> $dialog_log
	/bin/echo "button2text: $Defer_Button_Custom in $buttontimer" >> $dialog_log
	let buttontimer=$buttontimer-1
	sleep 1
done

/bin/echo "button1text: $Install_Button_Custom" >> $dialog_log
/bin/echo "button1: enable" >> $dialog_log
/bin/echo "button2text: $Defer_Button_Custom" >> $dialog_log
/bin/echo "button2: enable" >> $dialog_log

wait $pid 2>/dev/null && result=$? || result=2

rm $dialog_log

if [ $result -eq 2 ]
	then
		ScriptLogUpdate "Updates ${latest_updateVersion} available."
		ScriptLogUpdate "User has moved the update."
		killProcess "caffeinate"
		exit 0
		
	else
		ScriptLogUpdate "User has clicked on install."
		updateCLI
		killProcess "caffeinate"
		exit 0
fi
