#!/bin/bash

#############################################################################
# Shellscript		:	macOS Update with deferrals
# Author			:	Andreas Vogel, NEXT Enterprise GmbH
#
# Info				:	Script only works with macOS Big Sur (11) and higher
#
# 					:	BETA
#
#############################################################################
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
# # # # # # # # # # # # # # # # # # # # # # # # # Testing | Script # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #  #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
scriptLog=$(/usr/bin/defaults read "/Library/Managed Preferences/${BundleIDPlist}" scriptLog 2>"/dev/null")

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
	echo -e "$( date +%Y-%m-%d\ %H:%M:%S ) - ${1}" | tee -a "${scriptLog}"
}

ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * START LOG * * * * * * * * * * * * * * * * * * * * * * *"

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # Ende Testing  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # To-Do's # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# 1. macOS Updates
#
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
	
	ScriptLogUpdate "[ Function-Check SwiftDialog ]: swiftDialog is installed ($dialog_app)"
else
	# downloading and installing swiftDialog
	
	ScriptLogUpdate "Function-Check SwiftDialog: Downloading swiftDialog.app..."
	if /usr/bin/curl -L "$dialog_download_url" -o "$workdir/dialog.pkg" ; then
		if ! installer -pkg "$workdir/dialog.pkg" -target / ; then
			
			ScriptLogUpdate "[ Function-Check SwiftDialog ]: swiftDialog installation failed."
		fi
	else
		ScriptLogUpdate "[ Function-Check SwiftDialog ]: swiftDialog download failed."
	fi
	# check if swiftDialog was successfully installed
	if [[ -d "$dialog_app" && -f "$dialog_bin" ]]; then
		
		ScriptLogUpdate  "[ Function-Check SwiftDialog ]: swiftDialog is installed."
	else
		
		ScriptLogUpdate "[ Function-Check SwiftDialog ]: Could not download dialog."
		ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * *"
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
	mdmSERVICE="FALSE"
	
	profilesSTATUS=$(profiles status -type enrollment 2>&1)
	
	if [[ $(echo "$profilesSTATUS" | grep -c 'MDM server') -gt 0 ]]; then
		mdmENROLLED="TRUE"
		if [[ $(echo "$profilesSTATUS" | grep 'Enrolled via DEP:' | grep -c 'Yes') -gt 0 ]]; then
			
			ScriptLogUpdate "[ Function-Check MDM Service ]: ADE enrolled."
		else
			
			ScriptLogUpdate "[ Function-Check MDM Service ]: UIE enrolled, try it."
		fi
		mdmSERVICE="https://$(echo "$profilesSTATUS" | grep 'MDM server' | awk -F '/' '{print $3}')"
		curlRESULT=$(curl -Is "$mdmSERVICE" | head -n 1)
		if [[ $(echo "$curlRESULT" | grep -c 'HTTP') -gt 0 ]] && [[ $(echo "$curlRESULT" | grep -c -e '400' -e '40[4-9]' -e '4[1-9][0-9]' -e '5[0-9][0-9]') -eq 0 ]]; then
			
			ScriptLogUpdate "[ Function-Check MDM Service ]: Test Successful. Server $mdmSERVICE available."
		else
			
			ScriptLogUpdate "[ Function-Check MDM Service ]: ERROR Server at $mdmSERVICE is unavailable, status code: $curlRESULT"
			ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * *"
			exit 1
			
		fi
	else
		
		ScriptLogUpdate "[ Function-Check MDM Service ]: Warning Device is not enrolled with a MDM service."
		ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * *"
		exit 1
	fi
}

checkBootstrapToken() {
	
	checkMDMService
	
	ScriptLogUpdate "[ Function-Check Bootstrap Token ]: Checking the bootstrap token status on the macOS"
	
	profilesSTATUS=$(profiles status -type bootstraptoken 2>&1)
	if [[ $(echo "$profilesSTATUS" | grep -c 'YES') -eq 2 ]]
		then
			
			ScriptLogUpdate "[ Function-Check Bootstrap Token ]: Status Bootstrap token is set and escrowed to MDM Server."
		else
			
			ScriptLogUpdate "[ Function-Check Bootstrap Token ]: Warning Bootstrap token is not escrowed to MDM Server"
			ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * *"
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

currentUser="$(stat -f%Su /dev/console)"
realname=$(dscl . read /Users/$currentUser RealName | tail -n1 | awk '{print $1}')
udid=$(/usr/sbin/ioreg -rd1 -c IOPlatformExpertDevice | /usr/bin/grep -i "UUID" | /usr/bin/cut -c27-62)
loggedInUser="$(/usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | /usr/bin/awk '/Name :/ && ! /loginwindow/ { print $3 }')"

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # Start create plist for Deferral # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

Deferral_Value_Custom=$(/usr/libexec/PlistBuddy -c "Print :Plist_an_Credentials:DeferralValueCustom" "/Library/Managed Preferences/${BundleIDPlist}.plist")

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

Major_Update_apply=$(/usr/libexec/PlistBuddy -c "Print :Updates:MajorUpdateapply" "/Library/Managed Preferences/${BundleIDPlist}.plist")

# * * * * * * * * * * * * * * * * * * * * * * * * Timers and values * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #

Max_Message_Time_Custom=$(/usr/libexec/PlistBuddy -c "Print :Messanges:MaxMessageTime" "/Library/Managed Preferences/${BundleIDPlist}.plist")
Power_Wait_Timer=$(/usr/libexec/PlistBuddy -c "Print :Messanges:PowerWaitTimer" "/Library/Managed Preferences/${BundleIDPlist}.plist")

buttontimer_Final_Message_Custom=$(/usr/libexec/PlistBuddy -c "Print :Buttontimer:buttontimer_Final_Message" "/Library/Managed Preferences/${BundleIDPlist}.plist")
buttontimer_pleaseWait_new_Custom=$(/usr/libexec/PlistBuddy -c "Print :Buttontimer:buttontimer_pleaseWait_new" "/Library/Managed Preferences/${BundleIDPlist}.plist")
buttontimer_pleaseWait_alt_Custom=$(/usr/libexec/PlistBuddy -c "Print :Buttontimer:buttontimer_pleaseWait_alt" "/Library/Managed Preferences/${BundleIDPlist}.plist")
buttontimer_ErrorMessage_Custom=$(/usr/libexec/PlistBuddy -c "Print :Buttontimer:buttontimer_ErrorMessage" "/Library/Managed Preferences/${BundleIDPlist}.plist")

# * * * * * * * * * * * * * * * * * * * * * * * * Test and Messages * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #


Install_Button_Custom=$(/usr/libexec/PlistBuddy -c "Print :Messanges:InstallButtonLabel" "/Library/Managed Preferences/${BundleIDPlist}.plist")
Defer_Button_Custom=$(/usr/libexec/PlistBuddy -c "Print :Messanges:DeferButtonLabel" "/Library/Managed Preferences/${BundleIDPlist}.plist")
Defer_Button_Custom=$(echo -e "$Defer_Button_Custom")
Support_Contact_Custom=$(/usr/libexec/PlistBuddy -c "Print :Messanges:SupportContact" "/Library/Managed Preferences/${BundleIDPlist}.plist")

Please_Wait_Title=$(/usr/libexec/PlistBuddy -c "Print :Messanges:PleaseWaitTitle" "/Library/Managed Preferences/${BundleIDPlist}.plist")
Power_Title=$(/usr/libexec/PlistBuddy -c "Print :Messanges:PowerTitle" "/Library/Managed Preferences/${BundleIDPlist}.plist")
Error_Title=$(/usr/libexec/PlistBuddy -c "Print :Messanges:ErrorTitle" "/Library/Managed Preferences/${BundleIDPlist}.plist")


Forced_Update_Prompt=`/usr/libexec/PlistBuddy -c "Print :Messanges:ForcedUpdatePrompt" /Library/Managed\ Preferences/${BundleIDPlist}.plist`
Forced_Update_Prompt="$(echo -e "$Forced_Update_Prompt" | /usr/bin/sed "s/%REAL_NAME%/${realname}/" | /usr/bin/sed "s/%CurrentDeferralValue%/${CurrentDeferralValue}/")"

Please_Wait_Description=`/usr/libexec/PlistBuddy -c "Print :Messanges:PleaseWaitDescription" /Library/Managed\ Preferences/${BundleIDPlist}.plist`
Please_Wait_Description="$(echo -e "$Please_Wait_Description" | /usr/bin/sed "s/%REAL_NAME%/${realname}/" | /usr/bin/sed "s/%CURRENT_DEFERRAL_VALUE%/${CurrentDeferralValue}/" | /usr/bin/sed "s/%forceInstallLocalDateTime%/${forceInstallLocalDateTime}/")"

Power_Description=`/usr/libexec/PlistBuddy -c "Print :Messanges:PowerDescription" /Library/Managed\ Preferences/${BundleIDPlist}.plist`
Power_Description="$(echo -e "$Power_Description" | /usr/bin/sed "s/%REAL_NAME%/${realname}/" | /usr/bin/sed "s/%CURRENT_DEFERRAL_VALUE%/${CurrentDeferralValue}/")"

No_Power_Description=`/usr/libexec/PlistBuddy -c "Print :Messanges::NoPowerDescription" /Library/Managed\ Preferences/${BundleIDPlist}.plist`
No_Power_Description="$(echo -e "$No_Power_Description" | /usr/bin/sed "s/%REAL_NAME%/${realname}/" | /usr/bin/sed "s/%CURRENT_DEFERRAL_VALUE%/${CurrentDeferralValue}/")"

Error_Description=`/usr/libexec/PlistBuddy -c "Print :Messanges::ErrorDescription" /Library/Managed\ Preferences/${BundleIDPlist}.plist`
Error_Description="$(echo -e "$Error_Description" | /usr/bin/sed "s/%REAL_NAME%/${realname}/" | /usr/bin/sed "s/%CURRENT_DEFERRAL_VALUE%/${CurrentDeferralValue}/")"

# * * * * * * * * * * * * * * * * * * * * * * * * SwiftDialog Window  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #

Dialog_update_width=$(/usr/libexec/PlistBuddy -c "Print :Dialog_Settings:Dialog_update_width" "/Library/Managed Preferences/${BundleIDPlist}.plist")
Dialog_update_height=$(/usr/libexec/PlistBuddy -c "Print :Dialog_Settings:Dialog_update_height" "/Library/Managed Preferences/${BundleIDPlist}.plist")
Dialog_update_titlefont=$(/usr/libexec/PlistBuddy -c "Print :Dialog_Settings:Dialog_update_titlefont" "/Library/Managed Preferences/${BundleIDPlist}.plist")
Dialog_update_messagefont=$(/usr/libexec/PlistBuddy -c "Print :Dialog_Settings:Dialog_update_messagefont" "/Library/Managed Preferences/${BundleIDPlist}.plist")

Dialog_power_width=$(/usr/libexec/PlistBuddy -c "Print :Dialog_Settings:Dialog_power_width" "/Library/Managed Preferences/${BundleIDPlist}.plist")
Dialog_power_height=$(/usr/libexec/PlistBuddy -c "Print :Dialog_Settings:Dialog_power_height" "/Library/Managed Preferences/${BundleIDPlist}.plist")
Dialog_power_titlefont=$(/usr/libexec/PlistBuddy -c "Print :Dialog_Settings:Dialog_power_titlefont" "/Library/Managed Preferences/${BundleIDPlist}.plist")
Dialog_power_messagefont=$(/usr/libexec/PlistBuddy -c "Print :Dialog_Settings:Dialog_power_messagefont" "/Library/Managed Preferences/${BundleIDPlist}.plist")

Dialog_wait_width=$(/usr/libexec/PlistBuddy -c "Print :Dialog_Settings:Dialog_wait_width" "/Library/Managed Preferences/${BundleIDPlist}.plist")
Dialog_wait_height=$(/usr/libexec/PlistBuddy -c "Print :Dialog_Settings:Dialog_wait_height" "/Library/Managed Preferences/${BundleIDPlist}.plist")
Dialog_wait_titlefont=$(/usr/libexec/PlistBuddy -c "Print :Dialog_Settings:Dialog_wait_titlefont" "/Library/Managed Preferences/${BundleIDPlist}.plist")
Dialog_wait_messagefont=$(/usr/libexec/PlistBuddy -c "Print :Dialog_Settings:Dialog_wait_messagefont" "/Library/Managed Preferences/${BundleIDPlist}.plist")

Dialog_error_width=$(/usr/libexec/PlistBuddy -c "Print :Dialog_Settings:Dialog_error_width" "/Library/Managed Preferences/${BundleIDPlist}.plist")
Dialog_error_height=$(/usr/libexec/PlistBuddy -c "Print :Dialog_Settings:Dialog_error_height" "/Library/Managed Preferences/${BundleIDPlist}.plist")
Dialog_error_titlefont=$(/usr/libexec/PlistBuddy -c "Print :Dialog_Settings:Dialog_error_titlefont" "/Library/Managed Preferences/${BundleIDPlist}.plist")
Dialog_error_messagefont=$(/usr/libexec/PlistBuddy -c "Print :Dialog_Settings:Dialog_error_messagefont" "/Library/Managed Preferences/${BundleIDPlist}.plist")

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # Start Jamf Pro Variablen  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

profilesSTATUS=$(profiles status -type enrollment 2>&1)
Jamf_Pro_URL="https://$(echo "$profilesSTATUS" | grep 'MDM server' | awk -F '/' '{print $3}')"

if [[ -z "$Jamf_Pro_URL" ]]; then
	
	ScriptLogUpdate "[ Function-Check Jamf Pro Server ]: Jamf Pro URL could not be determined. Without URL, no plan can be created"
	ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * *"
	exit 1
fi


jamf_api_client="$4"
if [[ -z "$jamf_api_client" ]]; then
	
	ScriptLogUpdate "[ Function-Check Jamf API ]: Jamf Pro Client ID is missing"
	ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * * #"
	exit 1
fi


jamf_api_secret="$5"
if [[ -z "$jamf_api_secret" ]]; then
	
	ScriptLogUpdate "[ Function-Check Jamf API ]: Jamf Pro Client Secret is missing"
	ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * * #"
	exit 1
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

Language=$(/usr/libexec/PlistBuddy -c 'print AppleLanguages:0' "/Users/${currentUser}/Library/Preferences/.GlobalPreferences.plist")
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
		
		ScriptLogUpdate "[ Function-Kill Process ]: attempting to terminate the '$process' process - Termination message indicates success"
		
		kill "$process_pid" 2> /dev/null
		if /usr/bin/pgrep -a "$process" >/dev/null ; then 
			
			ScriptLogUpdate "[ Function-Kill Process ]: ERROR '$process' could not be killed"
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
		
		ScriptLogUpdate "[ Function-Check Power Status ]: OK - AC power detected"
	else
		
		ScriptLogUpdate "[ Function-Check Power Status ]: WARNING - No AC power detected"
		
		
		ScriptLogUpdate "[ Function-Check Power Status ]: INFO - Check if the current battery status is enough."
		
		currentBatteryLEVEL=$(pmset -g ps | grep '%' | awk '{print $3}' | sed -e 's/%;//g')
		
		if [[ $currentBatteryLEVEL -gt "50" ]]
		then 
			
			ScriptLogUpdate "[ Function-Check Power Status ]: INFO - Current Power is sufficent."
			
		else
			
			ScriptLogUpdate "[ Function-Check Power Status ]: INFO - Promt user to connect AC-Power."
			
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
				
				ScriptLogUpdate "[ Function-Check Power Status ]: OK - AC power detected"
				
				# quit dialog
				
				ScriptLogUpdate "[ Function-Check Power Status ]: Sending to dialog: quit:"
				
				/bin/echo "quit:" >> "$dialog_log"
				return
			fi
			sleep 1
			((Power_Wait_Timer--))
		done
		
		# quit dialog
		
		ScriptLogUpdate "[ Function-Check Power Status ]: Sending to dialog: quit:"
		
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
		
		
		ScriptLogUpdate "[ Function-Check Power Status ]: ERROR - No AC power detected after waiting for ${Power_Wait_Timer}, cannot continue."
		ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * *"
		exit 1
		fi
	fi
}

delete_api_token() {
	
	invalidateTOKEN=$(curl --header "Authorization: Bearer ${api_token}" --write-out "%{http_code}" --silent --output /dev/null --request POST --url "${Jamf_Pro_URL}/api/v1/auth/invalidate-token")
	if [[ $invalidateTOKEN -eq 204 ]]; then
		
		ScriptLogUpdate "[ Function-Revoke API Token ]: Jamf Pro API token successfully invalidated."
		ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END successfully * * * * * * * * * * * * * * * * * * * * * * *"
		
	elif [[ $invalidateTOKEN -eq 401 ]]; then
		
		ScriptLogUpdate "[ Function-Revoke API Token ]: Jamf Pro API token already invalid."
		ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END successfully * * * * * * * * * * * * * * * * * * * * * * *"
	else
		
		ScriptLogUpdate "[ Function-Revoke API Token ]: Invalidating Jamf Pro API token."
		ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * *"
	fi
}

get_api_token() {
	
	curl_response=$(curl --silent --location --request POST "${Jamf_Pro_URL}/api/oauth/token" --header "Content-Type: application/x-www-form-urlencoded" --data-urlencode "client_id=${jamf_api_client}" --data-urlencode "grant_type=client_credentials" --data-urlencode "client_secret=${jamf_api_secret}")
	
	
	if [[ $(echo "${curl_response}" | grep -c 'token') -gt 0 ]]
	then
		if [[ $(sw_vers -productVersion | cut -d'.' -f1) -lt 12 ]]
		then
			api_token=$(echo "${curl_response}" | plutil -extract access_token raw -)
		else 
			api_token=$(echo "${curl_response}" | awk -F '"' '{print $4;}' | xargs)
		fi
		ScriptLogUpdate "[ Funktion-GET API Token ]: Token was successfully generated"
		
	else
		ScriptLogUpdate "[ Funktion-GET API Token ]: Token could not be generated"
		ScriptLogUpdate "[ Funktion-GET API Token ]: Verify the --auth-jamf-client=ClientID and --auth-jamf-secret=ClientSecret are values."
		
		ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * * #"
		exit 1
	fi
}

get_api_token_OLD() {
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

get_Install_forceDateTime() {
	
	# Prüfung ob bereits ein Datum festgelegt wurde
	
	ForceInstallDateTime=$(/usr/libexec/PlistBuddy -c "print :$BundleID:forceInstallLocalDateTime" "$DeferralPlist" 2>/dev/null)
	
	if [[ -n "$ForceInstallDateTime" && ! "$ForceInstallDateTime" =~ "Does Not Exist" ]]
		then
			# Datum wurde bereits festgelegt. 
			
			ScriptLogUpdate "[ Function-GET Force Date Time ]: ForceInstallDateTime already exists"
			
			ScriptLogUpdate "[ Function-GET Force Date Time ]: Update is planned for the $ForceInstallDateTime"
			
			if [[ $Language = de* ]]; then
				
				HumanReadableTime=$(date -jf "%Y-%m-%dT%H:%M:%S" "$ForceInstallDateTime" "+%A dem %d.%m.%Y um %H:%M Uhr")
				forceInstallLocalDateTime="$HumanReadableTime"
				
			else
				HumanReadableTime=$(date -jf "%Y-%m-%dT%H:%M:%S" "$ForceInstallDateTime" "+%A on %d.%m.%Y at %H:%M Uhr")
				forceInstallLocalDateTime="$HumanReadableTime"
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
					ScriptLogUpdate "[ Function-GET Force Date Time ]: Verbleibende Stunden bis zum Installationszeitpunkt: $remainingTime Stunden"
					remainingTime_Message=${!remainingHourseTitel}
				else
					# Calculate remaining days
					remainingTime=$((remainingTimeDayorHours / 86400))
					
					ScriptLogUpdate "[ Function-GET Force Date Time ]: Verbleibende Tage bis zum Installationszeitpunkt: $remainingTime Tage"
					
					remainingTime_Message=${!remainingDaysTitel}
			fi
			
			# Prüfung, ob der aktuelle Plan noch Bestand hat.
			# Lese die PlanID aus der Plist
			planIDFromPlist=$(/usr/libexec/PlistBuddy -c "print :$BundleID:PlanID" "$DeferralPlist")
			
			# Prüfung, ob ein Wert vorhanden ist
			
				if [[ -z "$planIDFromPlist" ]]
					then
						
						ScriptLogUpdate "[ Function-GET Force Date Time ]: Error PlanID is not available in the plist."
					else
						
						ScriptLogUpdate "[ Function-GET Force Date Time ]: PlanID: $planIDFromPlist"
						
						validate_Plan_ID
					
				fi
			
		else
			# Datum und Schlüssel existiert nicht, lege ein Datum fest
			
			ScriptLogUpdate "[ Function-GET Force Date Time ]: No time has been set yet"
			
			ScriptLogUpdate "[ Function-GET Force Date Time ]: new time is being determined"
			currentUnixTime=$(date +%s)
			futureUnixTime=$((currentUnixTime + (Deferral_Value_Custom * 86400)))  		# 86400 Sekunden pro Tag
			futureUnixTimeDateTime=$(/bin/date -j -f "%s" "$futureUnixTime" "+%Y-%m-%dT%H:%M:%S")
			
			
			ScriptLogUpdate "[ Function-GET Force Date Time ]: new force date is planned for the $futureUnixTimeDateTime"
			
			ScriptLogUpdate "[ Function-GET Force Date Time ]: new plan with the date is sent"
			
			create_Update_Plan
	fi
	
	Standard_Update_Prompt=`/usr/libexec/PlistBuddy -c "Print :Messanges:StandardUpdatePrompt" /Library/Managed\ Preferences/${BundleIDPlist}.plist`
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
				
				ScriptLogUpdate "[ Function-Validate Plan ID ]: Creation of the plan has failed."
				
				errorReasons=$(echo "$response" | awk -F'"' '/errorReasons/{gsub(/[\[\],]/,""); print $4}')
				
				if [[ ! -z "$errorReasons" ]]
				then
					
					ScriptLogUpdate "[ Function-Validate Plan ID ]: Error reason: $errorReasons"
					
					if [[ "$errorReasons" == *"APPLE_SILICON_NO_ESCROW_KEY"* ]]
					then
						
						ScriptLogUpdate "[ Function-Validate Plan ID ]: Bootstrap token is not stored in MDM"
												
					elif [[ "$errorReasons" == *"EXISTING_PLAN_FOR_DEVICE_IN_PROGRESS"* ]]
					then
						
						ScriptLogUpdate "[ Function-Validate Plan ID ]: Another plan is already in progress for the device."
												
					fi
				else
					
					ScriptLogUpdate "[ Function-Validate Plan ID ]: It was terminated without an error code."
					
					setDeferral "$BundleID" "$DeferralType" "$Deferral_Value_Custom" "$DeferralPlist"
					
					if /usr/libexec/PlistBuddy -c "print :$BundleID:forceInstallLocalDateTime" "$DeferralPlist" >/dev/null 2>&1; then
						/usr/libexec/PlistBuddy -c "delete :$BundleID:forceInstallLocalDateTime" "$DeferralPlist"
					fi
					
					if /usr/libexec/PlistBuddy -c "print :$BundleID:PlanID" "$DeferralPlist" >/dev/null 2>&1; then
						/usr/libexec/PlistBuddy -c "delete :$BundleID:PlanID" "$DeferralPlist"
					fi
					
					ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * *"
					exit 1
					
				fi
				
			;;
			
			*)
				
				ScriptLogUpdate "[ Function-Validate Plan ID ]: Status: $state"
			;;
		esac
		
	else
		
		ScriptLogUpdate "[ Function-Validate Plan ID ]: Error when extracting the plan status."
		
	fi
}

create_Update_Plan() {
	
	Standard_Update_Prompt=`/usr/libexec/PlistBuddy -c "Print :Messanges:StandardUpdatePrompt" /Library/Managed\ Preferences/${BundleIDPlist}.plist`
	Standard_Update_Prompt="$(echo -e "$Standard_Update_Prompt" | /usr/bin/sed "s/%REAL_NAME%/${realname}/" | /usr/bin/sed "s/%CURRENT_DEFERRAL_VALUE%/${CurrentDeferralValue}/" | /usr/bin/sed "s/%Install_Button_Custom%/${Install_Button_Custom}/" | /usr/bin/sed "s/%forceInstallLocalDateTime%/${forceInstallLocalDateTime}/")"
	
	
	jamfAPIURL="${Jamf_Pro_URL}/api/v1/managed-software-updates/plans"
	
	response=$(curl -X GET "$Jamf_Pro_URL/JSSResource/computers/udid/$udid" -H "accept: application/xml" -H "Authorization: Bearer ${api_token}")
	deviceID=$(echo $response | /usr/bin/awk -F'<id>|</id>' '{print $2}')
	
	# deviceID="42"
	
	if [[ $Upgrade_API == "true" ]]
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
		
		ScriptLogUpdate "[ Function-Create Plan ]: Successful MDM command for update/upgrade was sent successfully."
		
		ScriptLogUpdate "[ Function-Create Plan ]: plan was set successfully"
		
		# Extrahiere die Plan-ID aus der Antwort
		planID=$(echo "$commandRESULT" | grep -o '"planId" : "[^"]*' | awk -F'"' '{print $4}')
		
		# Überprüfe, ob die Extrahierung erfolgreich war
		if [[ ! -z "$planID" ]]; then
			
			ScriptLogUpdate "[ Function-Create Plan ]: Plan ID: $planID"
			
			sleep 300
			
			# Wait until the plan has been implemented before checking the result
			get_Plan_Status
			
		else
			
			ScriptLogUpdate "[ Function-Create Plan ]: Error when extracting the plan ID."
		fi
		
	else
		
		ScriptLogUpdate ""$commandRESULT""
		
		ScriptLogUpdate "[ Function-Create Plan ]: MDM command could not be sent."
		delete_api_token
		ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * *"
		
		exit 1
	fi
}

Enable_BootstrapToken_with_currentUser() {
	
if [ -z "$loggedInUser" -o "$loggedInUser" = "loginwindow" ]; then
	echo "No user logged in, cannot proceed"
	exit 1
fi


BootstrapToken_iconPath="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/FileVaultIcon.icns"


Language=$(/usr/libexec/PlistBuddy -c 'print AppleLanguages:0' "/Users/${currentUser}/Library/Preferences/.GlobalPreferences.plist")
if [[ $Language = de* ]]; then
	UserLanguage="de"
else
	UserLanguage="en"
fi


BootstrapToken_title_de="fehlender Bootstrap-Token"
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
	
	/usr/bin/dscl /Search -authonly "$loggedInUser" "$userPass"
	
	if [ $? -eq 0 ]; then
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
	exit 1
fi

if groups $loggedInUser | grep -q -w admin
then
	ScriptLogUpdate "[ Function-activate the bootstrap token ]: Current user: $loggedInUser is admin"
	
else
	ScriptLogUpdate "[ Function-activate the bootstrap token ]: User $loggedInUser will be added"
	
	/usr/sbin/dseditgroup -o edit -a $loggedInUser -t user admin
	removeAdmin="yes"
fi
	
	result=$(expect -c "
log_user 0
spawn /usr/bin/profiles install -type bootstraptoken
expect \"Enter the admin user name:\"
send ${loggedInUser}
send \r
expect \"Enter a password for '/',: \"
send ${userPass}
send \r
log_user 1
expect eof
")
			
if [[ $result == *"Unable to authenticate user information"* ]]; then
	ScriptLogUpdate "[ Function-activate the bootstrap token ]: Error. Token could not be activated "
	
	if [[ $removeAdmin == "yes" ]]; then
		dseditgroup -o edit -d $loggedInUser -t user admin
		ScriptLogUpdate "[ Function-activate the bootstrap token ]: User is removed again"
	fi
	
	ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * *"
	
	delete_api_token
	exit 1
	
else
	if [[ $removeAdmin == "yes" ]]; then
		dseditgroup -o edit -d $loggedInUser -t user admin
		ScriptLogUpdate "[ Function-activate the bootstrap token ]: User is removed again"
	fi
	
	/usr/local/bin/jamf recon
	
	delete_api_token
	ScriptLogUpdate "[ Function-activate the bootstrap token ]: Token activated. New plan is created in the next cycle "
	ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END * * * * * * * * * * * * * * * * * * * * * * *"
	exit 0
	
fi
}

get_Plan_Status() {
	
	response=$(curl -X GET "$Jamf_Pro_URL/api/v1/managed-software-updates/plans/$planID" -H "accept: application/json" -H "Authorization: Bearer ${api_token}")
	state=$(echo "$response" | awk -F'"' '/state/{print $4}')
	
	if [[ ! -z "$state" ]]
	then
		
		ScriptLogUpdate "Plan Status: $state"
		
		case $state in
			PlanFailed)
				
				ScriptLogUpdate "[ Function-Plan Status ]: Creation of the plan has failed."
				errorReasons=$(echo "$response" | awk -F'"' '/errorReasons/{gsub(/[\[\],]/,""); print $4}')
				
				if [[ ! -z "$errorReasons" ]]
				then
					
					ScriptLogUpdate "[ Function-Plan Status ]: Error reason: $errorReasons"
					
					if [[ "$errorReasons" == *"APPLE_SILICON_NO_ESCROW_KEY"* ]]
					then
						
						ScriptLogUpdate "[ Function-Plan Status ]: Bootstrap token is not stored in MDM"
						ScriptLogUpdate "[ Function-Plan Status ]: Try to reactivate it with the user"
						
						Enable_BootstrapToken_with_currentUser
						
					elif [[ "$errorReasons" == *"EXISTING_PLAN_FOR_DEVICE_IN_PROGRESS"* ]]
					then
						
						ScriptLogUpdate "[ Function-Plan Status ]: Another plan is already in progress for the device."
						ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END * * * * * * * * * * * * * * * * * * * * * * *"
						exit 0
						
					fi
				else
					
					ScriptLogUpdate "[ Function-Plan Status ]: It was terminated without an error code."
					
					setDeferral "$BundleID" "$DeferralType" "$Deferral_Value_Custom" "$DeferralPlist"
					
					if /usr/libexec/PlistBuddy -c "print :$BundleID:forceInstallLocalDateTime" "$DeferralPlist" >/dev/null 2>&1; then
						/usr/libexec/PlistBuddy -c "delete :$BundleID:forceInstallLocalDateTime" "$DeferralPlist"
					fi
					
					if /usr/libexec/PlistBuddy -c "print :$BundleID:PlanID" "$DeferralPlist" >/dev/null 2>&1; then
						/usr/libexec/PlistBuddy -c "delete :$BundleID:PlanID" "$DeferralPlist"
					fi
					
					ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * *"
					exit 1
				fi
				
			;;
			
			PlanCanceled)
				
				ScriptLogUpdate "[ Function-Plan Status ]: Plan was canceled"
				exit 0
			;;
			
			*)
				
				ScriptLogUpdate "[ Function-Plan Status ]: plan was accepted"
				
				ScriptLogUpdate "[ Function-Plan Status ]: Enter the date in the plist"
				
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
					
					ScriptLogUpdate "[ Function-Plan Status ]: Hours remaining until the time of installation: $remainingTime Stunden"
					remainingTime_Message=${!remainingHourseTitel}
				else
					# Calculate remaining days
					remainingTime=$((remainingTimeDayorHours / 86400))
					
					ScriptLogUpdate "[ Function-Plan Status ]: Days remaining until the time of installation: $remainingTime Tage"
					
					remainingTime_Message=${!remainingDaysTitel}
				fi
			
				
				if [[ $Language = de* ]]; then
					
					HumanReadableTime=$(date -jf "%Y-%m-%dT%H:%M:%S" "$ForceInstallDateTime" "+%A dem %d.%m.%Y um %H:%M Uhr")
					forceInstallLocalDateTime="$HumanReadableTime"
					
				else
					HumanReadableTime=$(date -jf "%Y-%m-%dT%H:%M:%S" "$ForceInstallDateTime" "+%A on %d.%m.%Y at %H:%M Uhr")
					forceInstallLocalDateTime="$HumanReadableTime"
				fi

				
				Standard_Update_Prompt=`/usr/libexec/PlistBuddy -c "Print :Messanges:StandardUpdatePrompt" /Library/Managed\ Preferences/${BundleIDPlist}.plist`
				Standard_Update_Prompt="$(echo -e "$Standard_Update_Prompt" | /usr/bin/sed "s/%REAL_NAME%/${realname}/" | /usr/bin/sed "s/%CURRENT_DEFERRAL_VALUE%/${CurrentDeferralValue}/" | /usr/bin/sed "s/%Install_Button_Custom%/${Install_Button_Custom}/" | /usr/bin/sed "s/%forceInstallLocalDateTime%/${forceInstallLocalDateTime}/")"
				
			;;
			
		esac
		
	else
		
		ScriptLogUpdate "[ Function-Plan Status ]: Error when extracting the plan status."
		
	fi
}
	

updateCLI_old() {
	jamfAPIURL="${Jamf_Pro_URL}/api/v1/macos-managed-software-updates/send-updates"
	
	response=$(curl -X GET "$Jamf_Pro_URL/JSSResource/computers/udid/$udid" -H "accept: application/xml" -H "Authorization: Bearer ${api_token}")
	deviceID=$(echo $response | /usr/bin/awk -F'<id>|</id>' '{print $2}')
	
	
	jamfJSON='{ "deviceIds": ["'${deviceID}'"], "applyMajorUpdate": false, "version": "'${macOSSoftwareUpdateVERSION}'", "updateAction": "DOWNLOAD_AND_INSTALL", "forceRestart": true }'
	
	
	commandRESULT=$(curl --header "Authorization: Bearer ${api_token}" --header "Content-Type: application/json" --write-out "%{http_code}" --silent --show-error --request POST --url "${jamfAPIURL}" --data "${jamfJSON}")
	
	if [[ $(echo "$commandRESULT" | grep -c '200') -gt 0 ]] || [[ $(echo "$commandRESULT" | grep -c '201') -gt 0 ]]; then
		
		ScriptLogUpdate "[ Function-Update macOS OLD API ]: Successful MDM command for update/upgrade was sent successfully."
		
		
		ScriptLogUpdate "[ Function-Update macOS OLD API ]: API token is rejected"
		
		delete_api_token
		pleaseWait_alt
		
	else
		
		ScriptLogUpdate ""$commandRESULT""
		
		ScriptLogUpdate "[ Function-Update macOS OLD API ]: MDM command could not be sent."
		
		ErrorMessage
	fi
}
				

updateCLI() {
	
	open "x-apple.systempreferences:com.apple.preferences.softwareupdate"
	
}


updateCLI_without_DDM() {
	
	jamfAPIURL="${Jamf_Pro_URL}/api/v1/managed-software-updates/plans"
	
	response=$(curl -X GET "$Jamf_Pro_URL/JSSResource/computers/udid/$udid" -H "accept: application/xml" -H "Authorization: Bearer ${api_token}")
	deviceID=$(echo $response | /usr/bin/awk -F'<id>|</id>' '{print $2}')
	
	
	if [[ $Upgrade_API == "true" ]]
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
	"maxDeferrals": 0
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
							"updateAction": "DOWNLOAD_INSTALL_RESTART",
							"versionType": "LATEST_MINOR",
							"specificVersion": "NO_SPECIFIC_VERSION"
					}
			}'
	fi
	
	commandRESULT=$(curl --header "Authorization: Bearer ${api_token}" --header "Content-Type: application/json" --write-out "%{http_code}" --silent --show-error --request POST --url "${jamfAPIURL}" --data "${jamfJSON}")
	
	if [[ $(echo "$commandRESULT" | grep -c '200') -gt 0 ]] || [[ $(echo "$commandRESULT" | grep -c '201') -gt 0 ]]
	then
		ScriptLogUpdate "[ Function-Update Without DDM ]:Successful: MDM command for update/upgrade was sent successfully."
		ScriptLogUpdate "[ FFunction-Update Without DDM ]:API token is rejected"
		delete_api_token
		pleaseWait_alt
		
	else
		ScriptLogUpdate ""$commandRESULT""
		ScriptLogUpdate "[ Function-Update Without DDM ]:MDM command could not be sent."
		
		ErrorMessage
	fi
	
}
	

get_Update_Status() {
	response=$(curl -X GET "$Jamf_Pro_URL/JSSResource/computers/udid/$udid" -H "accept: application/xml" -H "Authorization: Bearer ${api_token}")
	
	deviceID=$(echo $response | /usr/bin/awk -F'<id>|</id>' '{print $2}')
		
	jamfAPIURL_Status="${Jamf_Pro_URL}/api/v1/managed-software-updates/update-statuses/computers"
	
	commandRESULT=$(curl --header "Authorization: Bearer ${api_token}" --header "Content-Type: application/json" --write-out "%{http_code}" --silent --show-error --request GET --url "${jamfAPIURL_Status}/$deviceID")
	
	statusValue=$(echo "$commandRESULT" | grep -o '"status" *: *"[^"]*"' | awk -F'"' '{print $4}')
	
	
	ScriptLogUpdate "[ Function-GET Update Status ]:The status is: $statusValue"
	
}

pleaseWait_new(){
	
	# Aktuell nicht benötigt, da kein 'Please Wait'-Fenster mehr angezeigt wird.
	
	Please_Wait_Description=`/usr/libexec/PlistBuddy -c "Print :Messanges:PleaseWaitDescription" /Library/Managed\ Preferences/${BundleIDPlist}.plist`
	Please_Wait_Description="$(echo -e "$Please_Wait_Description" | /usr/bin/sed "s/%REAL_NAME%/${realname}/" | /usr/bin/sed "s/%CURRENT_DEFERRAL_VALUE%/${CurrentDeferralValue}/" | /usr/bin/sed "s/%forceInstallLocalDateTime%/${forceInstallLocalDateTime}/")"
	
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
	
	# Hintergrundschleife, die alle 30 Sekunden 'get_Update_Status' aufruft
	while true; do
		get_Update_Status
		sleep 40
		
		Please_Wait_Description="$(echo -e "$Please_Wait_Description" | /usr/bin/sed "s/%REAL_NAME%/${realname}/" | /usr/bin/sed "s/%CURRENT_DEFERRAL_VALUE%/${CurrentDeferralValue}/" | /usr/bin/sed "s/%statusValue%/${statusValue}/")"
		
		/bin/echo "message: $Please_Wait_Description" >> $dialog_log
	done &
	
	wait $!
	
}

pleaseWait_alt(){
	
	Please_Wait_Description=`/usr/libexec/PlistBuddy -c "Print :Messanges:PleaseWaitDescription" /Library/Managed\ Preferences/${BundleIDPlist}.plist`
	Please_Wait_Description="$(echo -e "$Please_Wait_Description" | /usr/bin/sed "s/%REAL_NAME%/${realname}/" | /usr/bin/sed "s/%CURRENT_DEFERRAL_VALUE%/${CurrentDeferralValue}/" | /usr/bin/sed "s/%forceInstallLocalDateTime%/${forceInstallLocalDateTime}/")"

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
			
			ScriptLogUpdate "[ Function-Find Correct API ]: Send the command to update the device via the new API"
			
			macOSMAJOR=$(sw_vers -productVersion | cut -d'.' -f1) # Erwartete Ausgabe: 10, 11, 12
			
			if [[ $macOSMAJOR -ge 14 ]]; then
				NEW_API="TRUE"
				ScriptLogUpdate "[ Function-Find Correct API ]: Current MajorOS $macOSMAJOR supports DDM"
			else
				NEW_API="DDM_False"
				ScriptLogUpdate "[ Function-Find Correct API ]: Current MajorOS $macOSMAJOR does not yet support DDM"
				
			fi
			
		else
			
			ScriptLogUpdate "[ Function-Find Correct API ]: Send the command via the old API. Please switch to the new API soon"
			
			NEW_API="FALSE"
			
		fi
	else
		
		ScriptLogUpdate "[ Function-Find Correct API ]: ERROR"
		ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * *"
		delete_api_token
		exit 1
	fi
}

				
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
	
	ScriptLogUpdate "[ Functions-Check macOS Updates ]: New software updates found"
	ScriptLogUpdate "[ Functions-Check macOS Updates ]: Check if this is for the macOS in question"
	
	if [[ $macOSMAJOR -ge 12 ]]; then 
		#Für macOS 12 können mehrere macOS-Updates/Upgrades aufgelistet werden.
		allSoftwareUpdateLABELS=($(echo "$softwareUpdateLIST" | awk -F ': ' '/Label:/{print $2}'))
		allSoftwareUpdateTITLES=($(echo "$softwareUpdateLIST" | awk -F ',' '/Title:/ {print $1}' | cut -d ' ' -f 2-))
		macOSSoftwareUpdateLABELS=($(echo "$softwareUpdateLIST" | grep 'Label: macOS' | sed -e 's/* Label: //' | sort -k3 -r -V))
		macOSSoftwareUpdateTITLES=($(echo "$softwareUpdateLIST" | grep 'Title: macOS' | sed -e 's/,/:/g' | awk -F ': ' '{print $2}' | sort -k3 -r -V))
		macOSSoftwareUpdateVERSIONS=($(echo "$softwareUpdateLIST" | grep 'Title: macOS' | sed -e 's/,/:/g' | awk -F ': ' '{print $4}' | sort -r -V))
		macOSSoftwareUpdateGBS=($(echo "$softwareUpdateLIST" | grep 'Title: macOS' | awk -F ': ' '{print $4}' | grep -o -E '[0-9]+' | awk '{print $1"/1000000 +1"}' | bc))
		macOSSoftwareUpdateLABEL=$(echo "${macOSSoftwareUpdateLABELS[*]}" | grep "$macOSMAJOR.\d")
		macOSSoftwareUpdateTITLE=$(echo "${macOSSoftwareUpdateTITLES[*]}" | grep "$macOSMAJOR.\d")
		macOSSoftwareUpdateVERSION=$(echo "${macOSSoftwareUpdateVERSIONS[*]}" | grep -o -E '(\d+\.)+\d+' | grep "$macOSMAJOR.")
		macOSSoftwareUpdateVERSIONUpgrade=$(echo "${macOSSoftwareUpdateVERSIONS[*]}" | grep -o -E '(\d+\.)+\d+')
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
	
elif [[ $(echo "$softwareUpdateLIST" | grep -c 'No new software available.') -gt 0 ]]; then
	
	ScriptLogUpdate "[ Functions-Check macOS Updates ]: No new software available."
	
	setDeferral "$BundleID" "$DeferralType" "$Deferral_Value_Custom" "$DeferralPlist"
	
	if /usr/libexec/PlistBuddy -c "print :$BundleID:forceInstallLocalDateTime" "$DeferralPlist" >/dev/null 2>&1; then
		/usr/libexec/PlistBuddy -c "delete :$BundleID:forceInstallLocalDateTime" "$DeferralPlist"
	fi
	
	if /usr/libexec/PlistBuddy -c "print :$BundleID:PlanID" "$DeferralPlist" >/dev/null 2>&1; then
		/usr/libexec/PlistBuddy -c "delete :$BundleID:PlanID" "$DeferralPlist"
	fi
	
	ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END * * * * * * * * * * * * * * * * * * * * * * *"
	exit 0
fi


Major_Updates_Avalible_Check=$(echo "${macOSSoftwareUpdateVERSIONUpgrade}" | cut -d '.' -f1)

if [[ $Major_Updates_Avalible_Check -gt $macOSMAJOR ]]
then
	Major_Updates_Avalible="true"
else
	Major_Updates_Avalible="false"
fi
	
if [[ $Major_Updates_Avalible == "True" && $Major_Update_apply == "true" ]]; then
	Upgrade_API="true"
else
	Upgrade_API="false"
fi

if [[ $Major_Updates_Avalible == "true" && $Major_Update_apply == "true" ]]; then
	
	ScriptLogUpdate "[ Functions-Check macOS Updates ]: Upgrades auf macOS $macOSSoftwareUpdateVERSIONUpgrade available"
	futureUpdate=$macOSSoftwareUpdateVERSIONUpgrade
	
	get_api_token
	find_correct_API
	
	if [[ "$NEW_API" == "TRUE" ]]
	then
		
		ScriptLogUpdate "[ Functions-Check macOS Updates ]: Check the current update plan"
		
		get_Install_forceDateTime
		
		
	elif [[ "$NEW_API" == "DDM_False" ]]; then
		ScriptLogUpdate "[ Functions-Check macOS Updates ]: NEW API without DDM"
		
	elif [[ "$NEW_API" == "FALSE" ]]; then	
		
		ScriptLogUpdate "[ Functions-Check macOS Updates ]: old API still activated."
		ScriptLogUpdate "[ Functions-Check macOS Updates ]: Plan cannot be set or tested"
		ScriptLogUpdate "[ Functions-Check macOS Updates ]: PLEASE switch to the new API"
		
	else
		ScriptLogUpdate "[ Functions-Check macOS Updates ]: API server point was not recognized"
		ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * *"
		exit 1
	fi
	
else
	
	
	if [[ $Major_Updates_Avalible_Check -gt $macOSMAJOR ]]; then
		ScriptLogUpdate "[ Functions-Check macOS Updates ]: Upgrades auf macOS $macOSSoftwareUpdateVERSIONUpgrade sind ebenfalls verfügbar"
	fi
	
	
	if [[ -n ${macOSSoftwareUpdateVERSION} ]]
	then
		futureUpdate=$macOSSoftwareUpdateVERSION
		get_api_token
		find_correct_API
		
		ScriptLogUpdate "[ Functions-Check macOS Updates ]: macOS Update '${macOSSoftwareUpdateVERSION}' was found."
		
		if [[ "$NEW_API" == "TRUE" ]]
		then
			
			ScriptLogUpdate "[ Functions-Check macOS Updates ]: Check the current update plan"
			
			get_Install_forceDateTime
			
			
		elif [[ "$NEW_API" == "DDM_False" ]]; then
			ScriptLogUpdate "[ Functions-Check macOS Updates ]: NEW API without DDM"
			
		elif [[ "$NEW_API" == "FALSE" ]]; then	
			
			ScriptLogUpdate "[ Functions-Check macOS Updates ]: old API still activated."
			ScriptLogUpdate "[ Functions-Check macOS Updates ]: Plan cannot be set or tested"
			ScriptLogUpdate "[ Functions-Check macOS Updates ]: PLEASE switch to the new API"
			
		else
			ScriptLogUpdate "[ Functions-Check macOS Updates ]: API server point was not recognized"
			ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * *"
			exit 1
		fi
		
	else
		
		ScriptLogUpdate "[ Functions-Check macOS Updates ]: no updates found"
		
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
fi



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # RUN Update # # # # # # # # # # # # # # # # # # # # # # # # ## # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

if [[ "$loggedInUser" == "" ]]
then
	
	ScriptLogUpdate "NO User logged in"
	exit 0
else
	
	if [[ "$NEW_API" == "TRUE" ]]
	then
		buttontimer=$buttontimer_Final_Message_Custom
		
		get_default_dialog_args "update"
		dialog_args=("${default_dialog_args[@]}")
		dialog_args+=(
			"--infobox"
			"_________________\n\n"${!Device_Info}"\n\n${!Current_OS}: $Current_macOS \n\n${!available_OS}: $futureUpdate \n\n$remainingTime_Message:\n$remainingTime"
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
			
			ScriptLogUpdate "#"
			ScriptLogUpdate ""
			ScriptLogUpdate "Updates ${macOSSoftwareUpdateVERSION} available."
			ScriptLogUpdate "User has moved the update."
			ScriptLogUpdate "Remaining number of days to force: $remainingDays"
			ScriptLogUpdate ""
			ScriptLogUpdate "#"
			
		else
			
			ScriptLogUpdate "#"
			ScriptLogUpdate ""
			ScriptLogUpdate "User has clicked on install."
			ScriptLogUpdate ""
			ScriptLogUpdate "#"
			updateCLI
			
		fi
		
	elif [[ "$NEW_API" == "DDM_False" ]]; then
		
		ScriptLogUpdate "Send the command to update via NEW API Without DDM"
		
		if [[ "$CurrentDeferralValue" -gt 0 ]]
		then
			
			# Reduce the timer by 1. The script will run again the next run
			let RemainingDeferrals=$CurrentDeferralValue-1
			# Write remaining deferrals to plist to use for next run
			
			setDeferral "$BundleID" "$DeferralType" "$RemainingDeferrals" "$DeferralPlist"
			
			CurrentDeferralValue="$(/usr/libexec/PlistBuddy -c "print :$BundleID:count" "$DeferralPlist" 2>/dev/null)"
			Standard_Update_Prompt_OLD=`/usr/libexec/PlistBuddy -c "Print :Messanges:StandardUpdatePrompt_OLD" /Library/Managed\ Preferences/${BundleIDPlist}.plist`
			Standard_Update_Prompt_OLD="$(echo -e "$Standard_Update_Prompt_OLD" | /usr/bin/sed "s/%REAL_NAME%/${realname}/" | /usr/bin/sed "s/%CURRENT_DEFERRAL_VALUE%/${CurrentDeferralValue}/" | /usr/bin/sed "s/%Install_Button_Custom%/${Install_Button_Custom}/" | /usr/bin/sed "s/%forceInstallLocalDateTime%/${forceInstallLocalDateTime}/")"
			
			
			buttontimer=$buttontimer_Final_Message_Custom
			
			get_default_dialog_args "update"
			dialog_args=("${default_dialog_args[@]}")
			dialog_args+=(
				"--infobox"
				"_________________\n\n"${!Device_Info}"\n\n${!Current_OS}: $Current_macOS \n\n${!available_OS}: $futureUpdate \n\n${!CurrentDeferralValue_Text}: $CurrentDeferralValue"
				"--icon"
				"${welcomeIcon}"
				"--iconsize"
				"128"
				"--title"
				"macOS Softwareupdate"
				"--message"
				"$Standard_Update_Prompt_OLD"
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
				
				ScriptLogUpdate "#"
				ScriptLogUpdate ""
				ScriptLogUpdate "Updates available."
				ScriptLogUpdate "User has moved the update."
				ScriptLogUpdate "Remaining number of displacements: $RemainingDeferrals."
				ScriptLogUpdate ""
				ScriptLogUpdate "#"
				ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END * * * * * * * * * * * * * * * * * * * * * * *"
				
			else
				
				ScriptLogUpdate "#"
				ScriptLogUpdate ""
				ScriptLogUpdate "User has clicked on install. Start update."
				ScriptLogUpdate ""
				ScriptLogUpdate "#"
				
				check_power_status
				updateCLI_without_DDM
				
			fi
			
			exit 0
		else
			
			buttontimer=$buttontimer_Final_Message_Custom
			
			get_default_dialog_args "update"
			dialog_args=("${default_dialog_args[@]}")
			dialog_args+=(
				"--infobox"
				"_________________\n\n"${!Device_Info}"\n\n${!Current_OS}: $Current_macOS \n\n${!available_OS}: $futureUpdate \n\n${!CurrentDeferralValue_Text}: $CurrentDeferralValue"
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
				
				ScriptLogUpdate "#"
				ScriptLogUpdate ""
				ScriptLogUpdate "Exit script automatically | User has clicked on install"
				ScriptLogUpdate ""
				ScriptLogUpdate "#"
				
				check_power_status
				updateCLI_without_DDM
				
			else
				
				ScriptLogUpdate "#"
				ScriptLogUpdate ""
				ScriptLogUpdate "Dialog was ended without a clear result"
				ScriptLogUpdate ""
				ScriptLogUpdate "#"
				ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * *"
				exit 1
			fi
			
		fi
		
	elif [[ "$NEW_API" == "FALSE" ]]; then
		
		ScriptLogUpdate "Send the command to update via the old API"
		
		if [[ "$CurrentDeferralValue" -gt 0 ]]
		then
			
			# Reduce the timer by 1. The script will run again the next run
			let RemainingDeferrals=$CurrentDeferralValue-1
			# Write remaining deferrals to plist to use for next run
			setDeferral "$BundleID" "$DeferralType" "$RemainingDeferrals" "$DeferralPlist"
			
			CurrentDeferralValue="$(/usr/libexec/PlistBuddy -c "print :$BundleID:count" "$DeferralPlist" 2>/dev/null)"
			Standard_Update_Prompt_OLD=`/usr/libexec/PlistBuddy -c "Print :Messanges:StandardUpdatePrompt_OLD" /Library/Managed\ Preferences/${BundleIDPlist}.plist`
			Standard_Update_Prompt_OLD="$(echo -e "$Standard_Update_Prompt_OLD" | /usr/bin/sed "s/%REAL_NAME%/${realname}/" | /usr/bin/sed "s/%CURRENT_DEFERRAL_VALUE%/${CurrentDeferralValue}/" | /usr/bin/sed "s/%Install_Button_Custom%/${Install_Button_Custom}/" | /usr/bin/sed "s/%forceInstallLocalDateTime%/${forceInstallLocalDateTime}/")"
			
			buttontimer=$buttontimer_Final_Message_Custom
			
			get_default_dialog_args "update"
			dialog_args=("${default_dialog_args[@]}")
			dialog_args+=(
				"--infobox"
				"_________________\n\n"${!Device_Info}"\n\n${!Current_OS}: $Current_macOS \n\n${!available_OS}: $futureUpdate \n\n${!CurrentDeferralValue_Text}: $CurrentDeferralValue"
				"--icon"
				"${welcomeIcon}"
				"--iconsize"
				"128"
				"--title"
				"macOS Softwareupdate"
				"--message"
				"$Standard_Update_Prompt_OLD"
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
				
				ScriptLogUpdate "#"
				ScriptLogUpdate ""
				ScriptLogUpdate "Updates available."
				ScriptLogUpdate "User has moved the update."
				ScriptLogUpdate "Remaining number of displacements: $RemainingDeferrals."
				ScriptLogUpdate ""
				ScriptLogUpdate "#"
				ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END * * * * * * * * * * * * * * * * * * * * * * *"
				
			else
				
				ScriptLogUpdate "#"
				ScriptLogUpdate ""
				ScriptLogUpdate "User has clicked on install. Start update."
				ScriptLogUpdate ""
				ScriptLogUpdate "#"
				
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
				"_________________\n\n"${!Device_Info}"\n\n${!Current_OS}: $Current_macOS \n\n${!available_OS}: $futureUpdate \n\n${!CurrentDeferralValue_Text}: $CurrentDeferralValue"
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
				
				ScriptLogUpdate "#"
				ScriptLogUpdate ""
				ScriptLogUpdate "Exit script automatically | User has clicked on install"
				ScriptLogUpdate ""
				ScriptLogUpdate "#"
				
				check_power_status
				updateCLI_old
				
			else
				
				ScriptLogUpdate "#"
				ScriptLogUpdate ""
				ScriptLogUpdate "Dialog was ended without a clear result"
				ScriptLogUpdate ""
				ScriptLogUpdate "#"
				ScriptLogUpdate "# * * * * * * * * * * * * * * * * * * * * * * * END WITH ERROR * * * * * * * * * * * * * * * * * * * * * * *"
				exit 1
			fi
		fi
	else
		ScriptLogUpdate "API server point was not recognized"
	fi
fi

exit 0
