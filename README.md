# macOS Update
This script is used to manage macOS software updates within a time frame defined by the administrator.

The script offers the following advantages:

* The administrator does not need to manually schedule macOS updates.
* The script supports the current DDM update mechanisms.
* No hidden administrator account is required.
* No user password is required to perform the update.
* All texts displayed to the user in the dialog can be provided through a configuration profile, so no customization of the script itself is required.
* The window size and font size can also be configured through the configuration profile.
* Update installation deadlines can be dynamically determined based on the criticality of the macOS update.
* Specific weekdays can be excluded from the update installation schedule.

## Difference compared to Jamf Pro Blueprints

Unlike Jamf Pro Blueprints, the installation deadline for a macOS update can be dynamically determined based on the criticality of the update.

The update criticality is evaluated using information provided by [SOFA (Simple Organized Feed for Apple Software Updates)](https://sofa.macadmins.io/).

This allows different enforcement periods to be defined depending on the importance of an update. For example, a critical security update can be enforced much sooner, while users can be given a longer installation period for a non-critical update.

In addition, specific weekdays can be excluded from the update installation schedule. This makes it possible to prevent updates from being installed on selected business days where an enforced update would be undesirable.

By combining update criticality, configurable enforcement periods, and excluded installation days, the script provides more granular control over the macOS software update process.

  
Example of the dialog about an available macOS update for non-DDM-capable macOS
![](https://github.com/avogel-mac/Update_macOS_DDM/blob/main/Pictures/Bildschirmfoto%202026-04-01%20um%2013.02.45.png?raw=true)


Questions, suggestions, or improvement proposals are welcome and appreciated.
