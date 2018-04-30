
roku-remote.psm1


A collection of Roku remote functions.

Get-LocalRokus 

	Search the local network for Roku compatible devices and outputs the Name, IP, and Model.

Send-RokuCommand 
	
	Send-RokuCommand -ip $ip -RokuCommand ('Home','Rev','Fwd','Play','Select','Left','Right','Down','Up','Back','InstandReplay','Info','Backspace','Search','Enter','FindRemote')

Launch-App $ip

	Opens a GUI to select an app that will launch on the specified Roku

Send-RokuReboot $ip 

	Simulate the button presses to reboot the specified Roku
	




roku-remotegui.ps1

Launch a WPF GUI Roku remote.

