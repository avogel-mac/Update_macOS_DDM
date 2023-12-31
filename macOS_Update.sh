#!/bin/bash
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Shellscript		:	macOS Update with deferral
# Author			:	Andreas Vogel, NEXT Enterprise GmbH
#
# 						Script only works with macOS Big Sur (11) and higher
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
ScriptVersion="1.0"
export PATH=/usr/bin:/bin:/usr/sbin:/sbin

# # # # # # # # # # # # # # # # # # # # # # # # # Plist location  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
BundleIDPlist="it.next.macOS.update"
DeferralPlist=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" DeferralPlist 2>"/dev/null")

if [[ -z "$DeferralPlist" ]]; then
	DeferralPlist="/Library/Application Support/JAMF/com.custom.deferrals.plist"
fi
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # Testing | Script # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
scriptLog=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" scriptLog 2>"/dev/null")

if [[ -z "$scriptLog" ]]; then
	scriptLog="${4:-"/var/log/de.next.macOS.Update.log"}"
fi

if [[ ! -f "${scriptLog}" ]]; then
	touch "${scriptLog}"
fi

function ScriptLogUpdate() {
	echo -e "$( date +%Y-%m-%d\ %H:%M:%S ) - ${1}" | tee -a "${scriptLog}"
}
ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * START LOG * * * * * * * * * * * * * * * * * * * * * * * #"

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # Ende Testing  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # To-Do's # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# 1. Vieleicht einen Testmode/Debugmode einfügen. prüfen, ob das erforderlich ist.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # Ende To-Do's  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #
# * * * * * * * * * * * * * * * * * * * * * * * * Start PreflyCheck * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # make sure SwiftDialog is installed  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

dialog_app="/Library/Application Support/Dialog/Dialog.app"
dialog_bin="/usr/local/bin/dialog"
dialog_log="/var/tmp/dialog.log"
dialog_download_url="https://github.com/swiftDialog/swiftDialog/releases/download/v2.2.1/dialog-2.2.1-4591.pkg"
workdir="/Library/Scripts/"

# check if swiftDialog is installed
if [[ -d "$dialog_app" && -f "$dialog_bin" ]]; then
	
	ScriptLogUpdate "[ Funktion-Check SwiftDialog ]: swiftDialog is installed ($dialog_app)"
else
	# downloading and installing swiftDialog
	
	ScriptLogUpdate "Funktion-Check SwiftDialog: Downloading swiftDialog.app..."
	if /usr/bin/curl -L "$dialog_download_url" -o "$workdir/dialog.pkg" ; then
		if ! installer -pkg "$workdir/dialog.pkg" -target / ; then
			
			ScriptLogUpdate "[ Funktion-Check SwiftDialog ]: swiftDialog installation failed."
		fi
	else
		ScriptLogUpdate "[ Funktion-Check SwiftDialog ]: swiftDialog download failed."
	fi
	# check if swiftDialog was successfully installed
	if [[ -d "$dialog_app" && -f "$dialog_bin" ]]; then
		
		ScriptLogUpdate  "[ Funktion-Check SwiftDialog ]: swiftDialog is installed."
	else
		
		ScriptLogUpdate "[ Funktion-Check SwiftDialog ]: Could not download dialog."
		ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * * #"
		exit 1
	fi
fi

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # Validate  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

macOSMAJOR=$(sw_vers -productVersion | cut -d'.' -f1) # Expected output: 10, 11, 12
macOSMINOR=$(sw_vers -productVersion | cut -d'.' -f2) # Expected output: 14, 15, 06, 01
macOSVERSION=${macOSMAJOR}$(printf "%02d" "$macOSMINOR") # Expected output: 1014, 1015, 1106, 1203

checkMDMService() {
	mdmENROLLED="FALSE"
	mdmDEP="FALSE"
	mdmSERVICE="FALSE"
	
	profilesSTATUS=$(profiles status -type enrollment 2>&1)
	
	if [[ $(echo "$profilesSTATUS" | grep -c 'MDM server') -gt 0 ]]; then
		mdmENROLLED="TRUE"
		if [[ $(echo "$profilesSTATUS" | grep 'Enrolled via DEP:' | grep -c 'Yes') -gt 0 ]]; then
			
			ScriptLogUpdate "[ Funktion-Check MDM Service ]: ADE enrolled."
		else
			
			ScriptLogUpdate "[ Funktion-Check MDM Service ]: UIE enrolled, try it."
		fi
		mdmSERVICE="https://$(echo "$profilesSTATUS" | grep 'MDM server' | awk -F '/' '{print $3}')"
		curlRESULT=$(curl -Is "$mdmSERVICE" | head -n 1)
		if [[ $(echo "$curlRESULT" | grep -c 'HTTP') -gt 0 ]] && [[ $(echo "$curlRESULT" | grep -c -e '400' -e '40[4-9]' -e '4[1-9][0-9]' -e '5[0-9][0-9]') -eq 0 ]]; then
			
			ScriptLogUpdate "[ Funktion-Check MDM Service ]: Test Successful. Server $mdmSERVICE available."
		else
			
			ScriptLogUpdate "[ Funktion-Check MDM Service ]: ERROR Server at $mdmSERVICE is unavailable, status code: $curlRESULT"
			ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * * #"
			exit 1
			
		fi
	else
		
		ScriptLogUpdate "[ Funktion-Check MDM Service ]: Warning Device is not enrolled with a MDM service."
		ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * * #"
		exit 1
	fi
}

checkBootstrapToken() {
	
	checkMDMService
	
	ScriptLogUpdate "[ Funktion-Check Bootstrap Token ]: Checking the bootstrap token status on the macOS"
	
	profilesSTATUS=$(profiles status -type bootstraptoken 2>&1)
	if [[ $(echo "$profilesSTATUS" | grep -c 'YES') -eq 2 ]]
		then
			
			ScriptLogUpdate "[ Funktion-Check Bootstrap Token ]: Status Bootstrap token is set and escrowed to MDM Server."
		else
			
			ScriptLogUpdate "[ Funktion-Check Bootstrap Token ]: Warning Bootstrap token is not escrowed to MDM Server"
			ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * * #"
			exit 1
	fi
}

checkBootstrapToken

# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #
# * * * * * * * * * * * * * * * * * * * * * * * * End of PreflyCheck  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # Variablen User/ Icons / Binarys # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

jamf="/usr/local/bin/jamf"

welcomeIcon="SF=gear.badge,weight=medium,palette=red,auto"
powerIcon="SF=bolt.trianglebadge.exclamationmark.fill,weight=medium,palette=yellow,auto"
updateDownloadIcon="SF=hourglass,weight=medium,palette=white,indigo,indigo"
warningIcon="SF=exclamationmark.triangle.fill,weight=medium,palette=white,white,yellow"
errorIcon="SF=exclamationmark.octagon.fill,weight=medium,palette=white,white,red"

CURRENT_USER="$(stat -f%Su /dev/console)"
realname=$(dscl . read /Users/$CURRENT_USER RealName | tail -n1 | awk '{print $1}')
udid=$(/usr/sbin/ioreg -rd1 -c IOPlatformExpertDevice | /usr/bin/grep -i "UUID" | /usr/bin/cut -c27-62)
LoggedInUser="$(/usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | /usr/bin/awk '/Name :/ && ! /loginwindow/ { print $3 }')"

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # Start create plist for Deferral # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

Deferral_Value_Custom=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" DeferralValueCustom 2>"/dev/null")

if [[ -z "$Deferral_Value_Custom" ]]; then
	Deferral_Value_Custom=3
fi

setDeferral (){
	BundleID="${1}"
	DeferralType="${2}"
	Deferral_Value_Custom="${3}"
	DeferralPlist="${4}"
	
	if [[ "$DeferralType" == "date" ]]
		then
			DeferralDate="$(/usr/libexec/PlistBuddy -c "print :$BundleID:date" "$DeferralPlist" 2>/dev/null)"
			# Set deferral date
			if [[ -n "$DeferralDate" ]] && [[ ! "$DeferralDate" =~ "File Doesn't Exist" ]]
				then
					# /usr/libexec/PlistBuddy -c "set :$BundleID:date '07/04/2019 11:21:51 +0000'" "$DeferralPlist"
					/usr/libexec/PlistBuddy -c "set :$BundleID:date $Deferral_Value_Custom" "$DeferralPlist" 2>/dev/null
				else
					# /usr/libexec/PlistBuddy -c "add :$BundleID:date date '07/04/2019 11:21:51 +0000'" "$DeferralPlist"
					/usr/libexec/PlistBuddy -c "add :$BundleID:date date $Deferral_Value_Custom" "$DeferralPlist" 2>/dev/null
			fi
		elif [[ "$DeferralType" == "count" ]]; then
			DeferralCount="$(/usr/libexec/PlistBuddy -c "print :$BundleID:count" "$DeferralPlist" 2>/dev/null)"
			# Set deferral count
			if [[ -n "$DeferralCount" ]] && [[ ! "$DeferralCount" =~ "File Doesn't Exist" ]]
				then
					/usr/libexec/PlistBuddy -c "set :$BundleID:count $Deferral_Value_Custom" "$DeferralPlist" 2>/dev/null
				else
					/usr/libexec/PlistBuddy -c "add :$BundleID:count integer $Deferral_Value_Custom" "$DeferralPlist" 2>/dev/null
			fi
		else
			
			ScriptLogUpdate "Incorrect deferral type used."
			exit 14
	fi
}

BundleID="com.apple.SoftwareUpdate"
DeferralType="count"

CurrentDeferralValue="$(/usr/libexec/PlistBuddy -c "print :$BundleID:count" "$DeferralPlist" 2>/dev/null)"
# Set up the deferral value if it does not already exist
if [[ -z "$CurrentDeferralValue" ]] || [[ "$CurrentDeferralValue" =~ "File Doesn't Exist" ]]; then
	setDeferral "$BundleID" "$DeferralType" "$Deferral_Value_Custom" "$DeferralPlist"
	CurrentDeferralValue="$(/usr/libexec/PlistBuddy -c "print :$BundleID:count" "$DeferralPlist" 2>/dev/null)"
fi
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # Ende create plist for Deferral  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # Read Plist Variablen  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# * * * * * * * * * * * * * * * * * * * * * * * * macOS Updates * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #

Major_Update_apply=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" MajorUpdateapply 2>"/dev/null")

# Not yet defined in the script
Major_Update_apply_Version=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" MajorUpdateapplyVersion 2>"/dev/null")

# * * * * * * * * * * * * * * * * * * * * * * * * Timers and values * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #

Max_Message_Time_Custom=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" MaxMessageTime 2>"/dev/null")
Power_Wait_Timer=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" PowerWaitTimer 2>"/dev/null")

buttontimer_Final_Message_Custom=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" buttontimer_Final_Message 2>"/dev/null")
buttontimer_pleaseWait_new_Custom=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" buttontimer_pleaseWait_new 2>"/dev/null")
buttontimer_pleaseWait_alt_Custom=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" buttontimer_pleaseWait_alt 2>"/dev/null")
buttontimer_ErrorMessage_Custom=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" buttontimer_ErrorMessage 2>"/dev/null")

# * * * * * * * * * * * * * * * * * * * * * * * * Test and Messages * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #

Install_Button_Custom=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" InstallButtonLabel 2>"/dev/null")
Defer_Button_Custom=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" DeferButtonLabel 2>"/dev/null")
Defer_Button_Custom=$(echo -e "$Defer_Button_Custom")
Support_Contact_Custom=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" SupportContact 2>"/dev/null")

Please_Wait_Title=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" PleaseWaitTitle 2>"/dev/null")
Power_Title=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" PowerTitle 2>"/dev/null")
Error_Title=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" ErrorTitle 2>"/dev/null")

Forced_Update_Prompt=`/usr/libexec/PlistBuddy -c "Print :ForcedUpdatePrompt:" /Library/Managed\ Preferences/${BundleIDPlist}.plist`
Forced_Update_Prompt="$(echo -e "$Forced_Update_Prompt" | /usr/bin/sed "s/%REAL_NAME%/${realname}/" | /usr/bin/sed "s/%CurrentDeferralValue%/${CurrentDeferralValue}/")"

Please_Wait_Description=`/usr/libexec/PlistBuddy -c "Print :PleaseWaitDescription:" /Library/Managed\ Preferences/${BundleIDPlist}.plist`
Please_Wait_Description="$(echo -e "$Please_Wait_Description" | /usr/bin/sed "s/%REAL_NAME%/${realname}/" | /usr/bin/sed "s/%CURRENT_DEFERRAL_VALUE%/${CurrentDeferralValue}/" | /usr/bin/sed "s/%forceInstallLocalDateTime%/${forceInstallLocalDateTime}/")"

Power_Description=`/usr/libexec/PlistBuddy -c "Print :PowerDescription:" /Library/Managed\ Preferences/${BundleIDPlist}.plist`
Power_Description="$(echo -e "$Power_Description" | /usr/bin/sed "s/%REAL_NAME%/${realname}/" | /usr/bin/sed "s/%CURRENT_DEFERRAL_VALUE%/${CurrentDeferralValue}/")"

No_Power_Description=`/usr/libexec/PlistBuddy -c "Print :NoPowerDescription:" /Library/Managed\ Preferences/${BundleIDPlist}.plist`
No_Power_Description="$(echo -e "$No_Power_Description" | /usr/bin/sed "s/%REAL_NAME%/${realname}/" | /usr/bin/sed "s/%CURRENT_DEFERRAL_VALUE%/${CurrentDeferralValue}/")"

Error_Description=`/usr/libexec/PlistBuddy -c "Print :ErrorDescription:" /Library/Managed\ Preferences/${BundleIDPlist}.plist`
Error_Description="$(echo -e "$Error_Description" | /usr/bin/sed "s/%REAL_NAME%/${realname}/" | /usr/bin/sed "s/%CURRENT_DEFERRAL_VALUE%/${CurrentDeferralValue}/")"

# * * * * * * * * * * * * * * * * * * * * * * * * SwiftDialog Window  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #

Dialog_update_width=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" Dialog_update_width 2>"/dev/null")
Dialog_update_height=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" Dialog_update_height 2>"/dev/null")
Dialog_update_titlefont=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" Dialog_update_titlefont 2>"/dev/null")
Dialog_update_messagefont=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" Dialog_update_messagefont 2>"/dev/null")

Dialog_power_width=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" Dialog_power_width 2>"/dev/null")
Dialog_power_height=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" Dialog_power_height 2>"/dev/null")
Dialog_power_titlefont=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" Dialog_power_titlefont 2>"/dev/null")
Dialog_power_messagefont=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" Dialog_power_messagefont 2>"/dev/null")

Dialog_wait_width=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" Dialog_wait_width 2>"/dev/null")
Dialog_wait_height=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" Dialog_wait_height 2>"/dev/null")
Dialog_wait_titlefont=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" Dialog_wait_titlefont 2>"/dev/null")
Dialog_wait_messagefont=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" Dialog_wait_messagefont 2>"/dev/null")

Dialog_error_width=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" Dialog_error_width 2>"/dev/null")
Dialog_error_height=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" Dialog_error_height 2>"/dev/null")
Dialog_error_titlefont=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" Dialog_error_titlefont 2>"/dev/null")
Dialog_error_messagefont=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" Dialog_error_messagefont 2>"/dev/null")

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # Start Jamf Pro Variablen  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

profilesSTATUS=$(profiles status -type enrollment 2>&1)
Jamf_Pro_URL="https://$(echo "$profilesSTATUS" | grep 'MDM server' | awk -F '/' '{print $3}')"

if [[ -z "$Jamf_Pro_URL" ]]; then
	
	ScriptLogUpdate "Jamf Pro URL could not be determined. Without URL, no plan can be created"
	ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * * #"
	exit 1
fi

Jamf_Pro_Credentials="$4"
if [[ -z "$Jamf_Pro_Credentials" ]]; then
	
	ScriptLogUpdate "Jamf Pro Variablen Credentials missing"
	ScriptLogUpdate "Check Credentials in Profile"
	ScriptLogUpdate "Please user Credentials in Jamf Pro variablen"
	Jamf_Pro_Credentials=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" JamfProCredentials 2>"/dev/null")
	
	if [[ -z "$Jamf_Pro_Credentials" ]]; then
		
		ScriptLogUpdate "Credentials missing"
		ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * * #"
		exit 1
	fi
fi

# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #
# * * * * * * * * * * * * * * * * * * * * * * * * Default values  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #

# Default values if none have been set in the configuration profile 

if [[ -z "$Max_Message_Time_Custom" ]]; then
	Max_Message_Time_Custom="300"
fi

if [[ -z "$Support_Contact_Custom" ]]; then
	Support_Contact_Custom="IT"
fi

if [[ -z "$Major_Update_apply" ]]; then
	Major_Update_apply="false"
fi

if [[ -z "$buttontimer_Final_Message_Custom" ]]; then
	buttontimer_Final_Message_Custom="15"
fi

if [[ -z "$buttontimer_pleaseWait_new_Custom" ]]; then
	buttontimer_pleaseWait_new_Custom="15"
fi

if [[ -z "$buttontimer_pleaseWait_alt_Custom" ]]; then
	buttontimer_pleaseWait_alt_Custom="15"
fi

if [[ -z "$buttontimer_ErrorMessage_Custom" ]]; then
	buttontimer_ErrorMessage_Custom="15"
fi


# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #
# * * * * * * * * * * * * * * * * * * * * * * * * Update Windows  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #

if [[ -z "$Dialog_update_width" ]]; then
	Dialog_update_width="740"
fi

if [[ -z "$Dialog_update_height" ]]; then
	Dialog_update_height="540"
fi

if [[ -z "$Dialog_update_titlefont" ]]; then
	Dialog_update_titlefont="20"
fi

if [[ -z "$Dialog_update_messagefont" ]]; then
	Dialog_update_messagefont="14"
fi

# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #
# * * * * * * * * * * * * * * * * * * * * * * * * Power Windows * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #

if [[ -z "$Dialog_power_width" ]]; then
	Dialog_power_width="600"
fi

if [[ -z "$Dialog_power_height" ]]; then
	Dialog_power_height="240"
fi

if [[ -z "$Dialog_power_titlefont" ]]; then
	Dialog_power_titlefont="20"
fi

if [[ -z "$Dialog_power_messagefont" ]]; then
	Dialog_power_messagefont="12"
fi

# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #
# * * * * * * * * * * * * * * * * * * * * * * * * Wait Windows  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #

if [[ -z "$Dialog_wait_width" ]]; then
	Dialog_wait_width="600"
fi

if [[ -z "$Dialog_wait_height" ]]; then
	Dialog_wait_height="320"
fi

if [[ -z "$Dialog_wait_titlefont" ]]; then
	Dialog_wait_titlefont="20"
fi

if [[ -z "$Dialog_wait_messagefont" ]]; then
	Dialog_wait_messagefont="12"
fi

# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #
# * * * * * * * * * * * * * * * * * * * * * * * * Error Windows * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #

if [[ -z "$Dialog_error_width" ]]; then
	Dialog_error_width="600"
fi

if [[ -z "$Dialog_error_height" ]]; then
	Dialog_error_height="200"
fi

if [[ -z "$Dialog_error_titlefont" ]]; then
	Dialog_error_titlefont="20"
fi

if [[ -z "$Dialog_error_messagefont" ]]; then
	Dialog_error_messagefont="12"
fi

# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #
# * * * * * * * * * * * * * * * * * * * * * * * * Languages * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #

Language=$(/usr/libexec/PlistBuddy -c 'print AppleLanguages:0' "/Users/${CURRENT_USER}/Library/Preferences/.GlobalPreferences.plist")
if [[ $Language = de* ]]; then
	UserLanguage="de"
else
	UserLanguage="en"
fi

Device_Info_de="Geräteinformationen"
Device_Info_en="Device information"

Current_OS_de="Instal. macOS"
Current_OS_en="Installed macOS"

available_OS_de="neues Update"
available_OS_en="neu Update"

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
# # # # # # # # # # # # # # # # # # # # # # # # # Ende Variablen  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # Create default Dialog Arguments # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

get_default_dialog_args() {
	# set the dialog command arguments
	# $1 = window type
	default_dialog_args=(
		"--ontop"
		"--json"
		"--ignorednd"
		"--position"
		"centre"
		"--quitkey"
		"f"
	)
	if [[ "$1" == "update" ]]; then
		default_dialog_args+=(
			"--moveable"
			"--width"
			"$Dialog_update_width"
			"--height"
			"$Dialog_update_height"
			"--titlefont"
			"size=$Dialog_update_titlefont"
			"--messagefont"
			"size=$Dialog_update_messagefont"
			"--alignment"
			"left"
		)
	elif [[ "$1" == "power" ]]; then
		default_dialog_args+=(
			"--moveable"
			"--width"
			"$Dialog_power_width"
			"--height"
			"$Dialog_power_height"
			"--titlefont"
			"size=$Dialog_power_titlefont"
			"--messagefont"
			"size=$Dialog_power_messagefont"
			"--alignment"
			"left"
		)
	elif [[ "$1" == "wait" ]]; then
		default_dialog_args+=(
			"--moveable"
			"--width"
			"$Dialog_wait_width"
			"--height"
			"$Dialog_wait_height"
			"--titlefont"
			"size=$Dialog_wait_titlefont"
			"--messagefont"
			"size=$Dialog_wait_messagefont"
			"--alignment"
			"left"
		)
		elif [[ "$1" == "error" ]]; then
		default_dialog_args+=(
			"--moveable"
			"--width"
			"$Dialog_error_width"
			"--height"
			"$Dialog_error_height"
			"--titlefont"
			"size=$Dialog_error_titlefont"
			"--messagefont"
			"size=$Dialog_error_messagefont"
			"--alignment"
			"left"
		)
	fi
	
}


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # Funktionen  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
kill_process() {
	process="$1"
	echo
	if process_pid=$(/usr/bin/pgrep -a "$process" 2>/dev/null) ; then 
		
		ScriptLogUpdate "[ Funktion-Kill Process ]: attempting to terminate the '$process' process - Termination message indicates success"
		
		kill "$process_pid" 2> /dev/null
		if /usr/bin/pgrep -a "$process" >/dev/null ; then 
			
			ScriptLogUpdate "[ Funktion-Kill Process ]: ERROR '$process' could not be killed"
		fi
		echo
	fi
}

check_power_status() {
	# default Power_Wait_Timer to 60 seconds
	if [[ ! $Power_Wait_Timer ]]; then 
		Power_Wait_Timer=60
	fi
	
	if /usr/bin/pmset -g ps | /usr/bin/grep "AC Power" > /dev/null 
	then
		
		ScriptLogUpdate "[ Funktion-Check Power Status ]: OK - AC power detected"
	else
		
		ScriptLogUpdate "[ Funktion-Check Power Status ]: WARNING - No AC power detected"
		
		
		ScriptLogUpdate "[ Funktion-Check Power Status ]: INFO - Check if the current battery status is enough."
		
		currentBatteryLEVEL=$(pmset -g ps | grep '%' | awk '{print $3}' | sed -e 's/%;//g')
		
		if [[ $currentBatteryLEVEL -gt "50" ]]
		then 
			
			ScriptLogUpdate "[ Funktion-Check Power Status ]: INFO - Current bateriestaus is is enough."
			
		else
			
			ScriptLogUpdate "[ Funktion-Check Power Status ]: INFO - Promt user to connect AC-Power."
			
		get_default_dialog_args "power"
		dialog_args=("${default_dialog_args[@]}")
		dialog_args+=(
			"--title"
			"$Power_Title"
			"--icon"
			"${powerIcon}"
			"--iconsize"
			"128"
			"--message"
			"$Power_Description"
			"--timer"
			"${Power_Wait_Timer}"
		)

		"$dialog_bin" "${dialog_args[@]}" & sleep 0.1
		
		# now count down while checking for power
		while [[ "$Power_Wait_Timer" -gt 0 ]]; do
			if /usr/bin/pmset -g ps | /usr/bin/grep "AC Power" > /dev/null ; then
				
				ScriptLogUpdate "[ Funktion-Check Power Status ]: OK - AC power detected"
				
				# quit dialog
				
				ScriptLogUpdate "[ Funktion-Check Power Status ]: Sending to dialog: quit:"
				
				/bin/echo "quit:" >> "$dialog_log"
				return
			fi
			sleep 1
			((Power_Wait_Timer--))
		done
		
		# quit dialog
		
		ScriptLogUpdate "[ Funktion-Check Power Status ]: Sending to dialog: quit:"
		
		/bin/echo "quit:" >> "$dialog_log"
		
		# set the dialog command arguments
		get_default_dialog_args "power"
		dialog_args=("${default_dialog_args[@]}")
		dialog_args+=(
			"--title"
			"$Power_Title"
			"--icon"
			"${powerIcon}"
			"--iconsize"
			"128"
			"--message"
			"$No_Power_Description"
		)
		# run the dialog command
		"$dialog_bin" "${dialog_args[@]}"
		
		
		ScriptLogUpdate "[ Funktion-Check Power Status ]: ERROR - No AC power detected after waiting for ${Power_Wait_Timer}, cannot continue."
		ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * * #"
		exit 1
		fi
	fi
}

delete_api_token() {
	
	invalidateTOKEN=$(curl --header "Authorization: Bearer ${api_token}" --write-out "%{http_code}" --silent --output /dev/null --request POST --url "${Jamf_Pro_URL}/api/v1/auth/invalidate-token")
	if [[ $invalidateTOKEN -eq 204 ]]; then
		
		ScriptLogUpdate "[ Funktion-Revoke API Token ]: Jamf Pro API token successfully invalidated."
		ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END successfully * * * * * * * * * * * * * * * * * * * * * * * #"
		
	elif [[ $invalidateTOKEN -eq 401 ]]; then
		
		ScriptLogUpdate "[ Funktion-Revoke API Token ]: Jamf Pro API token already invalid."
		ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END successfully * * * * * * * * * * * * * * * * * * * * * * * #"
	else
		
		ScriptLogUpdate "[ Funktion-Revoke API Token ]: Invalidating Jamf Pro API token."
		ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * * #"
	fi
}

get_api_token() {
	authToken=$(/usr/bin/curl "${Jamf_Pro_URL}/api/v1/auth/token" --silent --request POST --header "Authorization: Basic ${Jamf_Pro_Credentials}")
	if [[ $(/usr/bin/sw_vers -productVersion | awk -F . '{print $1}') -lt 12 ]]
	then
		api_token=$(/usr/bin/awk -F \" 'NR==2{print $4}' <<< "$authToken" | /usr/bin/xargs)
		
	else
		api_token=$(/usr/bin/plutil -extract token raw -o - - <<< "$authToken")
	fi
	
	tokenCHECK=$(curl --header "Authorization: Bearer ${api_token}" --write-out "%{http_code}" --silent --output /dev/null --request GET --url "${Jamf_Pro_URL}/api/v1/auth")
	
	if [[ $tokenCHECK -eq 200 ]]
	then
		
		ScriptLogUpdate "[ Funktion-GET API Token ]: Token was successfully generated"
		
	else
		
		ScriptLogUpdate "[ Funktion-GET API Token ]: Token could not be generated"
		ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * * #"
		ErrorMessage
		exit 1
	fi
}


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # Ednde des Tokens  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

get_Install_forceDateTime() {
	
	# Prüfe ob bereits ein Datum festgelegt worden ist.
	
	ForceInstallDateTime=$(/usr/libexec/PlistBuddy -c "print :$BundleID:forceInstallLocalDateTime" "$DeferralPlist" 2>/dev/null)
	
	if [[ -n "$ForceInstallDateTime" && ! "$ForceInstallDateTime" =~ "Does Not Exist" ]]
		then
			# Datum wurde bereits festgelegt. 
			
			ScriptLogUpdate "[ Funktion-GET Force Date Time ]: ForceInstallDateTime already exists"
			
			ScriptLogUpdate "[ Funktion-GET Force Date Time ]: Update is planned for the $ForceInstallDateTime"
			
			if [[ $Language = de* ]]; then
				
				HymanReadTime=$(date -jf "%Y-%m-%dT%H:%M:%S" "$ForceInstallDateTime" "+%A dem %d.%m.%Y um %H:%M Uhr")
				forceInstallLocalDateTime="$HymanReadTime"
				
			else
				HymanReadTime=$(date -jf "%Y-%m-%dT%H:%M:%S" "$ForceInstallDateTime" "+%A on %d.%m.%Y at %H:%M Uhr")
				forceInstallLocalDateTime="$HymanReadTime"
			fi
		
			
	
			currentDateTime=$(date "+%Y-%m-%dT%H:%M:%S")
			
			# Convert dates to Unix timestamps
			currentUnixTime=$(date -jf "%Y-%m-%dT%H:%M:%S" "$currentDateTime" "+%s")
			forceInstallUnixTime=$(date -jf "%Y-%m-%dT%H:%M:%S" "$ForceInstallDateTime" "+%s")
			
			# Calculating the remaining time
			remainingTimeDayorHours=$((forceInstallUnixTime - currentUnixTime))
			
			# Check if it's the same day
			if [ $remainingTimeDayorHours -lt 86400 ]
				then
					# Calculate remaining hours
					remainingTime=$((remainingTimeDayorHours / 3600))
					ScriptLogUpdate "[ Funktion-GET Force Date Time ]: Verbleibende Stunden bis zum Installationszeitpunkt: $remainingTime Stunden"
					remainingTime_Message=${!remainingHourseTitel}
				else
					# Calculate remaining days
					remainingTime=$((remainingTimeDayorHours / 86400))
					
					ScriptLogUpdate "[ Funktion-GET Force Date Time ]: Verbleibende Tage bis zum Installationszeitpunkt: $remainingTime Tage"
					
					remainingTime_Message=${!remainingDaysTitel}
			fi
			
			# Prüfe, ob der aktuelle Plan noch bestand hat.
			# Lese die PlanID aus der Plist
			planIDFromPlist=$(/usr/libexec/PlistBuddy -c "print :$BundleID:PlanID" "$DeferralPlist")
			
			# Überprüfe, ob ein Wert vorhanden ist
			
				if [[ -z "$planIDFromPlist" ]]
					then
						
						ScriptLogUpdate "[ Funktion-GET Force Date Time ]: Error PlanID is not available in the plist."
					else
						
						ScriptLogUpdate "[ Funktion-GET Force Date Time ]: PlanID: $planIDFromPlist"
						
						validate_Plan_ID
					
				fi
			
		else
			# Datum und Schlüssel existiert nicht, lege ein Datum fest
			
			ScriptLogUpdate "[ Funktion-GET Force Date Time ]: No time has been set yet"
			
			ScriptLogUpdate "[ Funktion-GET Force Date Time ]: new time is being determined"
			currentUnixTime=$(date +%s)
			futureUnixTime=$((currentUnixTime + (Deferral_Value_Custom * 86400)))  		# 86400 Sekunden pro Tag
			futureUnixTimeDateTime=$(/bin/date -j -f "%s" "$futureUnixTime" "+%Y-%m-%dT%H:%M:%S")
			
			
			ScriptLogUpdate "[ Funktion-GET Force Date Time ]: new force date is planned for the $futureUnixTimeDateTime"
			
			ScriptLogUpdate "[ Funktion-GET Force Date Time ]: new plan with the date is sent"
			
			create_Update_Plan
	fi
	
	Standard_Update_Prompt=`/usr/libexec/PlistBuddy -c "Print :StandardUpdatePrompt:" /Library/Managed\ Preferences/${BundleIDPlist}.plist`
	Standard_Update_Prompt="$(echo -e "$Standard_Update_Prompt" | /usr/bin/sed "s/%REAL_NAME%/${realname}/" | /usr/bin/sed "s/%CURRENT_DEFERRAL_VALUE%/${CurrentDeferralValue}/" | /usr/bin/sed "s/%Install_Button_Custom%/${Install_Button_Custom}/" | /usr/bin/sed "s/%forceInstallLocalDateTime%/${forceInstallLocalDateTime}/")"
}


validate_Plan_ID() {
	
	response=$(curl -X GET "$Jamf_Pro_URL/api/v1/managed-software-updates/plans/$planIDFromPlist" -H "accept: application/json" -H "Authorization: Bearer ${api_token}")
	state=$(echo "$response" | awk -F'"' '/state/{print $4}')
	
	if [[ ! -z "$state" ]]
	then
		ScriptLogUpdate "Plan Status: $state"
		
		case $state in
						
			PlanFailed)
				
				ScriptLogUpdate "[ Funktion-Validate Plan ID ]: Creation of the plan has failed."
				
				errorReasons=$(echo "$response" | awk -F'"' '/errorReasons/{gsub(/[\[\],]/,""); print $4}')
				
				if [[ ! -z "$errorReasons" ]]
				then
					
					ScriptLogUpdate "[ Funktion-Validate Plan ID ]: Error reason: $errorReasons"
					
					if [[ "$errorReasons" == *"APPLE_SILICON_NO_ESCROW_KEY"* ]]
					then
						
						ScriptLogUpdate "[ Funktion-Validate Plan ID ]: Bootstrap token is not stored in MDM"
												
					elif [[ "$errorReasons" == *"EXISTING_PLAN_FOR_DEVICE_IN_PROGRESS"* ]]
					then
						
						ScriptLogUpdate "[ Funktion-Validate Plan ID ]: Another plan is already in progress for the device."
												
					fi
				else
					
					ScriptLogUpdate "[ Funktion-Validate Plan ID ]: It was terminated without an error code."
					
				fi
				
			;;
			
			*)
				
				ScriptLogUpdate "[ Funktion-Validate Plan ID ]: Status: $state"
			;;
		esac
		
	else
		
		ScriptLogUpdate "[ Funktion-Validate Plan ID ]: Error when extracting the plan status."
		
	fi
}

create_Update_Plan() {
	
	Standard_Update_Prompt=`/usr/libexec/PlistBuddy -c "Print :StandardUpdatePrompt:" /Library/Managed\ Preferences/${BundleIDPlist}.plist`
	Standard_Update_Prompt="$(echo -e "$Standard_Update_Prompt" | /usr/bin/sed "s/%REAL_NAME%/${realname}/" | /usr/bin/sed "s/%CURRENT_DEFERRAL_VALUE%/${CurrentDeferralValue}/" | /usr/bin/sed "s/%Install_Button_Custom%/${Install_Button_Custom}/" | /usr/bin/sed "s/%forceInstallLocalDateTime%/${forceInstallLocalDateTime}/")"
	
	jamfAPIURL="${Jamf_Pro_URL}/api/v1/managed-software-updates/plans"
	
	response=$(curl -X GET "$Jamf_Pro_URL/JSSResource/computers/udid/$udid" -H "accept: application/xml" -H "Authorization: Bearer ${api_token}")
	deviceID=$(echo $response | /usr/bin/awk -F'<id>|</id>' '{print $2}')
	
	# deviceID="42"
	
	if [[ $Major_Update_apply == "true" ]]
	then
		jamfJSON='{
"devices": [
{
"objectType": "COMPUTER",
"deviceId": "'${deviceID}'"
}
],
"config": {
"updateAction": "DOWNLOAD_INSTALL_SCHEDULE",
"versionType": "LATEST_MAJOR",
"specificVersion": "NO_SPECIFIC_VERSION",
"forceInstallLocalDateTime": "'${futureUnixTimeDateTime}'"
}
}'
	else
		jamfJSON='{
"devices": [
{
"objectType": "COMPUTER",
"deviceId": "'${deviceID}'"
}
],
"config": {
"updateAction": "DOWNLOAD_INSTALL_SCHEDULE",
"versionType": "LATEST_MINOR",
"specificVersion": "NO_SPECIFIC_VERSION",
"forceInstallLocalDateTime": "'${futureUnixTimeDateTime}'"
}
}'
	fi
	
	commandRESULT=$(curl --header "Authorization: Bearer ${api_token}" --header "Content-Type: application/json" --write-out "%{http_code}" --silent --show-error --request POST --url "${jamfAPIURL}" --data "${jamfJSON}")
	
	if [[ $(echo "$commandRESULT" | grep -c '200') -gt 0 ]] || [[ $(echo "$commandRESULT" | grep -c '201') -gt 0 ]]
	then
		
		ScriptLogUpdate "[ Funktion-Create Plan ]: Successful MDM command for update/upgrade was sent successfully."
		
		ScriptLogUpdate "[ Funktion-Create Plan ]: plan was set successfully"
		
		# Extrahiere die Plan-ID aus der Antwort
		planID=$(echo "$commandRESULT" | grep -o '"planId" : "[^"]*' | awk -F'"' '{print $4}')
		
		# Überprüfe, ob die Extrahierung erfolgreich war
		if [[ ! -z "$planID" ]]; then
			
			ScriptLogUpdate "[ Funktion-Create Plan ]: Plan ID: $planID"
			
			sleep 300
			
			# Wait until the plan has been implemented before checking the result
			get_Plan_Status
			
		else
			
			ScriptLogUpdate "[ Funktion-Create Plan ]: Error when extracting the plan ID."
		fi
		
	else
		
		ScriptLogUpdate ""$commandRESULT""
		
		ScriptLogUpdate "[ Funktion-Create Plan ]: MDM command could not be sent."
		delete_api_token
		ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * * #"
		
		exit 1
	fi
}


get_Plan_Status() {
	
	response=$(curl -X GET "$Jamf_Pro_URL/api/v1/managed-software-updates/plans/$planID" -H "accept: application/json" -H "Authorization: Bearer ${api_token}")
	state=$(echo "$response" | awk -F'"' '/state/{print $4}')
	
	if [[ ! -z "$state" ]]
	then
		
		ScriptLogUpdate "Plan Status: $state"
		
		case $state in
			Init|PendingPlanValidation|AcceptingPlan|RejectingPlan|ProcessingPlanType|StartingPlan)
				
				ScriptLogUpdate "[ Funktion-Plan Status ]: Status $state"
				
			;;
			
			PlanFailed)
				
				ScriptLogUpdate "[ Funktion-Plan Status ]: Creation of the plan has failed."
				errorReasons=$(echo "$response" | awk -F'"' '/errorReasons/{gsub(/[\[\],]/,""); print $4}')
				
				if [[ ! -z "$errorReasons" ]]
				then
					
					ScriptLogUpdate "[ Funktion-Plan Status ]: Error reason: $errorReasons"
					
					if [[ "$errorReasons" == *"APPLE_SILICON_NO_ESCROW_KEY"* ]]
					then
						
						ScriptLogUpdate "[ Funktion-Plan Status ]: Bootstrap token is not stored in MDM"
						ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * * #"
						exit 1
						
					elif [[ "$errorReasons" == *"EXISTING_PLAN_FOR_DEVICE_IN_PROGRESS"* ]]
					then
						
						ScriptLogUpdate "[ Funktion-Plan Status ]: Another plan is already in progress for the device."
						ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END * * * * * * * * * * * * * * * * * * * * * * * #"
						exit 0
						
					fi
				else
					
					ScriptLogUpdate "[ Funktion-Plan Status ]: It was terminated without an error code."
				fi
				ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * * #"
				exit 1
			;;
			
			PlanCanceled)
				
				ScriptLogUpdate "[ Funktion-Plan Status ]: Plan was canceled"
				exit 0
			;;
			
			SchedulingScanForOSUpdates|CollectingDDMStatus)
				
				ScriptLogUpdate "[ Funktion-Plan Status ]: plan wurde angenommen"
				
				ScriptLogUpdate "[ Funktion-Plan Status ]: Schreibe das Datum in die plist ein"
				
				/usr/libexec/PlistBuddy -c "add :$BundleID:forceInstallLocalDateTime string $futureUnixTimeDateTime" "$DeferralPlist"
				/usr/libexec/PlistBuddy -c "add :$BundleID:PlanID string $planID" "$DeferralPlist"
				
				ForceInstallDateTime=$(/usr/libexec/PlistBuddy -c "print :$BundleID:forceInstallLocalDateTime" "$DeferralPlist" 2>/dev/null)
				
				currentDateTime=$(date "+%Y-%m-%dT%H:%M:%S")
				
				# Convert dates to Unix timestamps
				currentUnixTime=$(date -jf "%Y-%m-%dT%H:%M:%S" "$currentDateTime" "+%s")
				forceInstallUnixTime=$(date -jf "%Y-%m-%dT%H:%M:%S" "$ForceInstallDateTime" "+%s")
				
				# Calculating the remaining time
				remainingTimeDayorHours=$((forceInstallUnixTime - currentUnixTime))
				
				# Check if it's the same day
				if [ $remainingTimeDayorHours -lt 86400 ]
				then
					# Calculate remaining hours
					remainingTime=$((remainingTimeDayorHours / 3600))
					
					ScriptLogUpdate "[ Funktion-Plan Status ]: Verbleibende Stunden bis zum Installationszeitpunkt: $remainingTime Stunden"
					remainingTime_Message=${!remainingHourseTitel}
				else
					# Calculate remaining days
					remainingTime=$((remainingTimeDayorHours / 86400))
					
					ScriptLogUpdate "[ Funktion-Plan Status ]: Verbleibende Tage bis zum Installationszeitpunkt: $remainingTime Tage"
					
					remainingTime_Message=${!remainingDaysTitel}
				fi
			
				
				if [[ $Language = de* ]]; then
					
					HymanReadTime=$(date -jf "%Y-%m-%dT%H:%M:%S" "$ForceInstallDateTime" "+%A dem %d.%m.%Y um %H:%M Uhr")
					forceInstallLocalDateTime="$HymanReadTime"
					
				else
					HymanReadTime=$(date -jf "%Y-%m-%dT%H:%M:%S" "$ForceInstallDateTime" "+%A on %d.%m.%Y at %H:%M Uhr")
					forceInstallLocalDateTime="$HymanReadTime"
				fi

				
				Standard_Update_Prompt=`/usr/libexec/PlistBuddy -c "Print :StandardUpdatePrompt:" /Library/Managed\ Preferences/${BundleIDPlist}.plist`
				Standard_Update_Prompt="$(echo -e "$Standard_Update_Prompt" | /usr/bin/sed "s/%REAL_NAME%/${realname}/" | /usr/bin/sed "s/%CURRENT_DEFERRAL_VALUE%/${CurrentDeferralValue}/" | /usr/bin/sed "s/%Install_Button_Custom%/${Install_Button_Custom}/" | /usr/bin/sed "s/%forceInstallLocalDateTime%/${forceInstallLocalDateTime}/")"
				
			;;
			
			SchedulingMDM|MDMPlanScheduled)
				
				ScriptLogUpdate "[ Funktion-Plan Status ]: Status: $state"
			;;
			
			*)
				
				
				ScriptLogUpdate "[ Funktion-Plan Status ]: Status: $state"
			;;
		esac
		
	else
		
		ScriptLogUpdate "[ Funktion-Plan Status ]: Error when extracting the plan status."
		
	fi
}
	

updateCLI_old() {
	jamfAPIURL="${Jamf_Pro_URL}/api/v1/macos-managed-software-updates/send-updates"
	
	response=$(curl -X GET "$Jamf_Pro_URL/JSSResource/computers/udid/$udid" -H "accept: application/xml" -H "Authorization: Bearer ${api_token}")
	deviceID=$(echo $response | /usr/bin/awk -F'<id>|</id>' '{print $2}')
	
	
	jamfJSON='{ "deviceIds": ["'${deviceID}'"], "applyMajorUpdate": false, "version": "'${macOSSoftwareUpdateVERSION}'", "updateAction": "DOWNLOAD_AND_INSTALL", "forceRestart": true }'
	
	
	commandRESULT=$(curl --header "Authorization: Bearer ${api_token}" --header "Content-Type: application/json" --write-out "%{http_code}" --silent --show-error --request POST --url "${jamfAPIURL}" --data "${jamfJSON}")
	
	if [[ $(echo "$commandRESULT" | grep -c '200') -gt 0 ]] || [[ $(echo "$commandRESULT" | grep -c '201') -gt 0 ]]; then
		
		ScriptLogUpdate "[ Funktion-Update macOS OLD API ]: Successful MDM command for update/upgrade was sent successfully."
		
		
		ScriptLogUpdate "[ Funktion-Update macOS OLD API ]: API token is rejected"
		
		delete_api_token
		pleaseWait_alt
		
	else
		
		ScriptLogUpdate ""$commandRESULT""
		
		ScriptLogUpdate "[ Funktion-Update macOS OLD API ]: MDM command could not be sent."
		
		ErrorMessage
	fi
}
				

updateCLI() {
	
	open "x-apple.systempreferences:com.apple.preferences.softwareupdate"

# Rausgenommen, da der gesetzte Plan nich edetiert werden kann.
# Erneut prüfen, wenn jamf pro api aus der Beta ist.
	
#	jamfAPIURL="${Jamf_Pro_URL}/api/v1/managed-software-updates/plans"
#	
#	response=$(curl -X GET "$Jamf_Pro_URL/JSSResource/computers/udid/$udid" -H "accept: application/xml" -H "Authorization: Bearer ${api_token}")
#	deviceID=$(echo $response | /usr/bin/awk -F'<id>|</id>' '{print $2}')
#	
#	
#	if [[ $Major_Update_apply == "true" ]]
#		then
#			jamfJSON='{
#			"devices": [
#				{
#					"objectType": "COMPUTER",
#					"deviceId": "'${deviceID}'"
#				}
#			],
#			"config": {
#				"updateAction": "DOWNLOAD_INSTALL",
#				"versionType": "LATEST_MAJOR",
#				"specificVersion": "NO_SPECIFIC_VERSION"
#			}
#		}'
#		else
#			jamfJSON='{
#			"devices": [
#				{
#					"objectType": "COMPUTER",
#					"deviceId": "'${deviceID}'"
#				}
#			],
#			"config": {
#				"updateAction": "DOWNLOAD_INSTALL_RESTART",
#				"versionType": "LATEST_MINOR",
#				"specificVersion": "NO_SPECIFIC_VERSION"
#			}
#		}'
#	fi
#	
#	commandRESULT=$(curl --header "Authorization: Bearer ${api_token}" --header "Content-Type: application/json" --write-out "%{http_code}" --silent --show-error --request POST --url "${jamfAPIURL}" --data "${jamfJSON}")
#	
#	if [[ $(echo "$commandRESULT" | grep -c '200') -gt 0 ]] || [[ $(echo "$commandRESULT" | grep -c '201') -gt 0 ]]
#	then
#		echo "Successful: MDM-Befehl zum Update/Upgrade wurde erfolgreich gesendet."
#		echo "API-Token wird verworfen"
#		# delete_api_token
#		pleaseWait_new
#		
#	else
#		echo ""$commandRESULT""
#		echo "MDM-Command konnte nicht gesendet werden."
#		ErrorMessage
#	fi
	
}

get_Update_Status() {
	response=$(curl -X GET "$Jamf_Pro_URL/JSSResource/computers/udid/$udid" -H "accept: application/xml" -H "Authorization: Bearer ${api_token}")
	
	deviceID=$(echo $response | /usr/bin/awk -F'<id>|</id>' '{print $2}')
		
	jamfAPIURL_Status="${Jamf_Pro_URL}/api/v1/managed-software-updates/update-statuses/computers"
	
	commandRESULT=$(curl --header "Authorization: Bearer ${api_token}" --header "Content-Type: application/json" --write-out "%{http_code}" --silent --show-error --request GET --url "${jamfAPIURL_Status}/$deviceID")
	
	statusValue=$(echo "$commandRESULT" | grep -o '"status" *: *"[^"]*"' | awk -F'"' '{print $4}')
	
	
	ScriptLogUpdate "[ Funktion-GET Update Status ]:The status is: $statusValue"
	
}

pleaseWait_new(){
	
	# Aktuell nicht benötigt, da kein Please wait Fenster mehr dargestellt wird.
	
	Please_Wait_Description=`/usr/libexec/PlistBuddy -c "Print :PleaseWaitDescription:" /Library/Managed\ Preferences/${BundleIDPlist}.plist`
	Please_Wait_Description="$(echo -e "$Please_Wait_Description" | /usr/bin/sed "s/%REAL_NAME%/${realname}/" | /usr/bin/sed "s/%CURRENT_DEFERRAL_VALUE%/${CurrentDeferralValue}/" | /usr/bin/sed "s/%statusValue%/${statusValue}/")"
	
	buttontimer=$buttontimer_pleaseWait_new_Custom
	
	get_default_dialog_args "wait"
	dialog_args=("${default_dialog_args[@]}")
	dialog_args+=(
		"--title"
		"$Please_Wait_Title"
		"--icon"
		"${updateDownloadIcon}"
		"--iconsize"
		"128"
		"--message"
		"$Please_Wait_Description"
		--button1disabled 
		--button1text 
		"OK in $buttontimer" 
		--commandfile 
		$dialog_log
	)
	
	"$dialog_bin" "${dialog_args[@]}" & sleep 0.1
	
	while [ $buttontimer -gt 0 ];
	do
		/bin/echo "button1text: OK in $buttontimer" >> $dialog_log
		let "buttontimer=buttontimer-1"
		sleep 1
	done
	
	/bin/echo "button1text: OK" >> $dialog_log
	/bin/echo "button1: enable" >> $dialog_log
	
	# Hintergrundschleife, die alle 30 Sekunden get_Update_Status aufruft
	while true; do
		get_Update_Status
		sleep 40
		
		Please_Wait_Description="$(echo -e "$Please_Wait_Description" | /usr/bin/sed "s/%REAL_NAME%/${realname}/" | /usr/bin/sed "s/%CURRENT_DEFERRAL_VALUE%/${CurrentDeferralValue}/" | /usr/bin/sed "s/%statusValue%/${statusValue}/")"
		
		/bin/echo "message: $Please_Wait_Description" >> $dialog_log
	done &
	
	wait $!
	
}

pleaseWait_alt(){
	
	Please_Wait_Description=`/usr/libexec/PlistBuddy -c "Print :PleaseWaitDescription:" /Library/Managed\ Preferences/${BundleIDPlist}.plist`
	Please_Wait_Description="$(echo -e "$Please_Wait_Description" | /usr/bin/sed "s/%REAL_NAME%/${realname}/" | /usr/bin/sed "s/%CURRENT_DEFERRAL_VALUE%/${CurrentDeferralValue}/")"

	buttontimer=$buttontimer_pleaseWait_alt_Custom

	get_default_dialog_args "wait"
	dialog_args=("${default_dialog_args[@]}")
	dialog_args+=(
		"--title"
		"$Please_Wait_Title"
		"--icon"
		"${updateDownloadIcon}"
		"--iconsize"
		"128"
		"--message"
		"$Please_Wait_Description"
		--button1disabled 
		--button1text 
		"OK in $buttontimer" 
		--commandfile 
		$dialog_log
	)

	"$dialog_bin" "${dialog_args[@]}" & sleep 0.1

	while [ $buttontimer -gt 0 ];
		do
			/bin/echo "button1text: OK in $buttontimer" >> $dialog_log
			let "buttontimer=buttontimer-1"
			sleep 1
		done

	/bin/echo "button1text: OK" >> $dialog_log
	/bin/echo "button1: enable" >> $dialog_log
	
	wait $!

}
				

find_correct_API() {
	curl_response=$(curl --silent --write-out "%{http_code}" --location --request GET "${Jamf_Pro_URL}/api/v1/managed-software-updates/plans/feature-toggle" --header "Authorization: Bearer ${api_token}" --header "Content-Type: application/json")
	
	if [[ $(echo "${curl_response}" | grep -c '200') -gt 0 ]]; then
		if [[ $(echo "${curl_response}" | grep -e 'toggle' | grep -c 'true') -gt 0 ]]; then
			
			ScriptLogUpdate "[ Funktion-Find Correct API ]: Send the command to update the device via the new API"
			
			NEW_API="TRUE"
			
		else
			
			ScriptLogUpdate "[ Funktion-Find Correct API ]: Send the command via the old API. Please switch to the new API soon"
			
			NEW_API="FALSE"
			
		fi
	else
		
		ScriptLogUpdate "[ Funktion-Find Correct API ]: ERROR"
		ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * * #"
		delete_api_token
		exit 1
	fi
}


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # Zeit und API wurde ermittelt  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
				
ErrorMessage(){

	buttontimer=$buttontimer_ErrorMessage_Custom

	get_default_dialog_args "error"
	dialog_args=("${default_dialog_args[@]}")
	dialog_args+=(
		"--title"
		"${Error_Title}"
		"--icon"
		"${errorIcon}"
		"--iconsize"
		"128"
		"--message"
		"$Error_Description"
		--button1disabled 
		--button1text 
		"OK in $buttontimer" 
		--commandfile 
		$dialog_log
	)

	"$dialog_bin" "${dialog_args[@]}" & sleep 0.1

	while [ $buttontimer -gt 0 ];
		do
			/bin/echo "button1text: OK in $buttontimer" >> $dialog_log
			let "buttontimer=buttontimer-1"
			sleep 1
		done

	/bin/echo "button1text: OK" >> $dialog_log
	/bin/echo "button1: enable" >> $dialog_log
	
	wait $!

}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # Check for Softwareupdates # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

## Auslesen des aktuellen macOS
Current_macOS=$(/usr/bin/sw_vers -productVersion)
macOSMAJOR=$(sw_vers -productVersion | cut -d'.' -f1) # Erwartete Ausgabe: 10, 11, 12
macOSMINOR=$(sw_vers -productVersion | cut -d'.' -f2) # Erwartete Ausgabe: 14, 15, 06, 01
macOSVERSION=${macOSMAJOR}$(printf "%02d" "$macOSMINOR") # Erwartete Ausgabe: 1014, 1015, 1106, 1203
softwareUpdateLIST="$(/usr/sbin/softwareupdate --list 2>&1)"


if [[ $(echo "$softwareUpdateLIST" | grep -c 'Software Update found') -gt 0 ]]; then
	
	ScriptLogUpdate "New software updates found"
	ScriptLogUpdate "Check if this is for the macOS in question"
	
	if [[ $macOSMAJOR -ge 12 ]]; then # Für macOS 12 können mehrere macOS-Updates/Upgrades aufgelistet werden.
		allSoftwareUpdateLABELS=($(echo "$softwareUpdateLIST" | awk -F ': ' '/Label:/{print $2}'))
		allSoftwareUpdateTITLES=($(echo "$softwareUpdateLIST" | awk -F ',' '/Title:/ {print $1}' | cut -d ' ' -f 2-))
		macOSSoftwareUpdateLABELS=($(echo "$softwareUpdateLIST" | grep 'Label: macOS' | sed -e 's/* Label: //' | sort -k3 -r -V))
		macOSSoftwareUpdateTITLES=($(echo "$softwareUpdateLIST" | grep 'Title: macOS' | sed -e 's/,/:/g' | awk -F ': ' '{print $2}' | sort -k3 -r -V))
		macOSSoftwareUpdateVERSIONS=($(echo "$softwareUpdateLIST" | grep 'Title: macOS' | sed -e 's/,/:/g' | awk -F ': ' '{print $4}' | sort -r -V))
		macOSSoftwareUpdateGBS=($(echo "$softwareUpdateLIST" | grep 'Title: macOS' | awk -F ': ' '{print $4}' | grep -o -E '[0-9]+' | awk '{print $1"/1000000 +1"}' | bc))
		macOSSoftwareUpdateLABEL=$(echo "${macOSSoftwareUpdateLABELS[*]}" | grep "$macOSMAJOR.\d")
		macOSSoftwareUpdateTITLE=$(echo "${macOSSoftwareUpdateTITLES[*]}" | grep "$macOSMAJOR.\d")
		macOSSoftwareUpdateVERSION=$(echo "${macOSSoftwareUpdateVERSIONS[*]}" | grep -o -E '(\d+\.)+\d+' | grep "$macOSMAJOR.")
		macOSSoftwareUpdateGB=$(echo "$softwareUpdateLIST" | grep 'Title: macOS' | grep " $macOSMAJOR.\d" | awk -F ': ' '{print $4}' | grep -o -E '[0-9]+' | awk '{print $1"/1000000 +1"}' | bc)
		
	elif [[ $macOSMAJOR -ge 11 ]] || [[ $macOSVERSION -ge 1015 ]]; then
		allSoftwareUpdateLABELS=($(echo "$softwareUpdateLIST" | awk -F ': ' '/Label:/{print $2}'))
		allSoftwareUpdateTITLES=($(echo "$softwareUpdateLIST" | awk -F ',' '/Title:/ {print $1}' | cut -d ' ' -f 2-))
		macOSSoftwareUpdateLABEL=$(echo "$softwareUpdateLIST" | grep 'Label: macOS' | sed -e 's/* Label: //')
		macOSSoftwareUpdateTITLE=$(echo "$softwareUpdateLIST" | grep 'Title: macOS' | sed -e 's/,/:/g' | awk -F ': ' '{print $2}')
		macOSSoftwareUpdateGB=$(echo "$softwareUpdateLIST" | grep 'Title: macOS' | awk -F ': ' '{print $4}' | grep -o -E '[0-9]+' | awk '{print $1"/1000000 +1"}' | bc)
		
		if [[ $macOSMAJOR -eq 11 ]]
			then
				macOSSoftwareUpdateVERSION=$(echo "$macOSSoftwareUpdateLABEL" | grep -o '11.[0-9].[0-9]')
			else
				macOSSoftwareUpdateVERSION=$(echo "$macOSSoftwareUpdateLABEL" | grep -o '10.[0-9][0-9].[0-9]' | grep "$macOSMAJOR.")
		fi
	fi
	
	recommendedSoftwareUpdateLABELS=($(echo "$softwareUpdateLIST" | awk -F ': ' '/Label:/{print $2}' | grep -v -e 'macOS'))
	recommendedSoftwareUpdateTITLES=($(echo "$softwareUpdateLIST" | awk -F ',' '/Title:/ {print $1}' | cut -d ' ' -f 2- | grep -v -e 'macOS'))
	
	if [[ $(echo "${macOSSoftwareUpdateVERSION}" | cut -d '.' -f1) -gt $macOSMAJOR ]]; then
			
			ScriptLogUpdate "Upgrades verfügbar."
	fi
	
elif [[ $(echo "$softwareUpdateLIST" | grep -c 'No new software available.') -gt 0 ]]; then
	
	ScriptLogUpdate "No new software available."
	
	setDeferral "$BundleID" "$DeferralType" "$Deferral_Value_Custom" "$DeferralPlist"
	
	if /usr/libexec/PlistBuddy -c "print :$BundleID:forceInstallLocalDateTime" "$DeferralPlist" >/dev/null 2>&1; then
		/usr/libexec/PlistBuddy -c "delete :$BundleID:forceInstallLocalDateTime" "$DeferralPlist"
	fi
	
	if /usr/libexec/PlistBuddy -c "print :$BundleID:PlanID" "$DeferralPlist" >/dev/null 2>&1; then
		/usr/libexec/PlistBuddy -c "delete :$BundleID:PlanID" "$DeferralPlist"
	fi

	
	exit 0
fi

if [[ -n ${recommendedSoftwareUpdateLABELS[*]} ]]; then
				
		ScriptLogUpdate "Updates for '${recommendedSoftwareUpdateLABELS[@]}' were found."
		ScriptLogUpdate "Updates are now installed via softwareupdate --install --safari-only"
		
		softwareupdate --install --safari-only
fi

if [[ -n ${macOSSoftwareUpdateVERSION} ]]
	then
		get_api_token
		find_correct_API
		
		
		ScriptLogUpdate "macOS Update '${macOSSoftwareUpdateVERSION}' wurde gefunden."
		
		if [[ "$NEW_API" == "TRUE" ]]
		then
			
			ScriptLogUpdate "Prüfen, des aktuellen Updates-Plans"
			
			get_Install_forceDateTime
			
		else
						
			ScriptLogUpdate "old API still activated."
			ScriptLogUpdate "Plan cannot be set or tested"
			ScriptLogUpdate "PLEASE switch to the new API"
			
		fi
	else
		
		ScriptLogUpdate "no updates found"
		
		setDeferral "$BundleID" "$DeferralType" "$Deferral_Value_Custom" "$DeferralPlist"
		
		
		if /usr/libexec/PlistBuddy -c "print :$BundleID:forceInstallLocalDateTime" "$DeferralPlist" >/dev/null 2>&1; then
			/usr/libexec/PlistBuddy -c "delete :$BundleID:forceInstallLocalDateTime" "$DeferralPlist"
		fi
		
		
		if /usr/libexec/PlistBuddy -c "print :$BundleID:PlanID" "$DeferralPlist" >/dev/null 2>&1; then
			/usr/libexec/PlistBuddy -c "delete :$BundleID:PlanID" "$DeferralPlist"
		fi
	
		delete_api_token
		exit 0
fi



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # RUN Update # # # # # # # # # # # # # # # # # # # # # # # # ## # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

if [[ "$LoggedInUser" == "" ]]
	then
		
		ScriptLogUpdate "NO one is logged in"
		exit 0
	else
		
		if [[ "$NEW_API" == "TRUE" ]]
		then
			buttontimer=$buttontimer_Final_Message_Custom
			
			get_default_dialog_args "update"
			dialog_args=("${default_dialog_args[@]}")
			dialog_args+=(
				"--infobox"
				"### _________________ ###\n\n### "${!Device_Info}" ###\n\n${!Current_OS}: $Current_macOS \n\n${!available_OS}: $macOSSoftwareUpdateVERSION \n\n$remainingTime_Message:\n$remainingTime"
				"--icon"
				"${welcomeIcon}"
				"--iconsize"
				"128"
				"--title"
				"macOS Softwareupdate"
				"--message"
				"$Standard_Update_Prompt"
				"-button1"
				"--button1text"
				"$Install_Button_Custom in $buttontimer"
				"--button1disabled"
				"--button2text"
				"$Defer_Button_Custom in $buttontimer"
				"--button2disabled"
				"--timer"
				"$Max_Message_Time_Custom"
				"--commandfile"
				$dialog_log
			)
			
			"$dialog_bin" "${dialog_args[@]}" & sleep 0.1
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
								
				ScriptLogUpdate "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
				ScriptLogUpdate ""
				ScriptLogUpdate "Updates ${macOSSoftwareUpdateVERSION} available."
				ScriptLogUpdate "User has moved the update."
				ScriptLogUpdate "Remaining number of days to force: $remainingDays"
				ScriptLogUpdate ""
				ScriptLogUpdate "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
				
			else
								
				ScriptLogUpdate "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
				ScriptLogUpdate ""
				ScriptLogUpdate "User has clicked on install."
				ScriptLogUpdate ""
				ScriptLogUpdate "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
				updateCLI
				
			fi
			
		else
			
			ScriptLogUpdate "Send the command to update via the old API"
	
			if [[ "$CurrentDeferralValue" -gt 0 ]]
				then
					
					# Reduce the timer by 1. The script will run again the next run
					let RemainingDeferrals=$CurrentDeferralValue-1
					# Write remaining deferrals to plist to use for next run
					setDeferral "$BundleID" "$DeferralType" "$RemainingDeferrals" "$DeferralPlist"

					buttontimer=$buttontimer_Final_Message_Custom
					
					get_default_dialog_args "update"
					dialog_args=("${default_dialog_args[@]}")
					dialog_args+=(
						"--infobox"
						"### _________________ ###\n\n### "${!Device_Info}" ###\n\n${!Current_OS}: $Current_macOS \n\n${!available_OS}: $macOSSoftwareUpdateVERSION \n\n${!CurrentDeferralValue_Text}: $CurrentDeferralValue"
						"--icon"
						"${welcomeIcon}"
						"--iconsize"
						"128"
						"--title"
						"macOS Softwareupdate"
						"--message"
						"$Standard_Update_Prompt"
						"-button1"
						"--button1text"
						"$Install_Button_Custom in $buttontimer"
						"--button1disabled"
						"--button2text"
						"$Defer_Button_Custom in $buttontimer"
						"--button2disabled"
						"--timer"
						"$Max_Message_Time_Custom"
						"--commandfile"
						$dialog_log
					)

					"$dialog_bin" "${dialog_args[@]}" & sleep 0.1
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
														
							ScriptLogUpdate "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
							ScriptLogUpdate ""
							ScriptLogUpdate "Updates available."
							ScriptLogUpdate "User has moved the update."
							ScriptLogUpdate "Remaining number of displacements: $RemainingDeferrals."
							ScriptLogUpdate ""
							ScriptLogUpdate "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
							ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END * * * * * * * * * * * * * * * * * * * * * * * #"
							
						else
														
							ScriptLogUpdate "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
							ScriptLogUpdate ""
							ScriptLogUpdate "User has clicked on install. Start update."
							ScriptLogUpdate ""
							ScriptLogUpdate "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
							
							check_power_status
							updateCLI_old
							
					fi
					
					exit 0
				else
					
					buttontimer=$buttontimer_Final_Message_Custom

					get_default_dialog_args "update"
					dialog_args=("${default_dialog_args[@]}")
					dialog_args+=(
						"--infobox"
						"### _________________ ###\n\n### "${!Device_Info}" ###\n\n${!Current_OS}: $Current_macOS \n\n${!available_OS}: $macOSSoftwareUpdateVERSION \n\n${!CurrentDeferralValue_Text}: $CurrentDeferralValue"
						"--icon"
						"${welcomeIcon}"
						"--iconsize"
						"128"
						"--title"
						"macOS Softwareupdate"
						"--message"
						"$Forced_Update_Prompt"
						"--button1text"
						"$Install_Button_Custom in $buttontimer"
						"--button1disabled"
						"--timer"
						"$Max_Message_Time_Custom"
						"--commandfile"
						$dialog_log
					)
					
					"$dialog_bin" "${dialog_args[@]}" & sleep 0.1
					pid=$!
					
					while [ $buttontimer -gt 0 ];
					do
						/bin/echo "button1text: $Install_Button_Custom in $buttontimer" >> $dialog_log
						let buttontimer=$buttontimer-1
						sleep 1
					done
				
					/bin/echo "button1text: $Install_Button_Custom" >> $dialog_log
					/bin/echo "button1: enable" >> $dialog_log
					
					wait $pid 2>/dev/null && result=1 || result=2
					
					rm $dialog_log
				
					if [[ $result == 2 ]] || [[ $result == 1 ]]
						then
														
							ScriptLogUpdate "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
							ScriptLogUpdate ""
							ScriptLogUpdate "Exit script automatically | User has clicked on install"
							ScriptLogUpdate ""
							ScriptLogUpdate "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
							
							check_power_status
							updateCLI_old
							
						else
														
							ScriptLogUpdate "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
							ScriptLogUpdate ""
							ScriptLogUpdate "Dialog was ended without a clear result"
							ScriptLogUpdate ""
							ScriptLogUpdate "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
							ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * * #"
							exit 1
					fi
			fi
		fi
fi
		
exit 0
