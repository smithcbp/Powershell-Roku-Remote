Powershell Roku Remote
======================

	Powershell based Roku GUI remote and module

roku-remote.psm1 
------------------
	A collection of Roku remote functions.
	Import-Module ./roku-remote.psm1

Get-LocalRokus
	Outputs the Name, Model, IP, and Description of all of the local Roku Devices.

Send-RokuCommand -ip $IP -rokucommand 'Home'
    Sends the specified command to the specified roku

Send-RokuReboot -ip $IP
    Sends a command macro to the Roku navigating to "Restart System"

Get-RokuApp -ip $IP 
    Outputs all of the installed Roku apps and their corresponding IDs.

Send-RokuApp -Ip $IP ((-name "Netflix") or (-ID "12"))
    Launches the specified app.

Select-RokuApp -Ip $IP
    Launches a gui to select and launch a roku app.
	

roku-remotegui.ps1
------------------
	Launch a WPF GUI Roku remote.

