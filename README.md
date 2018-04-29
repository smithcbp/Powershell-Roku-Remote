roku-remote.psm1

.NAME
    roku-remote.psm1
.SYNOPSIS

A collection of functions for discovering and controlling local Roku devices.
Import-Module .\roku-commands.psm1

.EXAMPLE

PS C:\Scripts> Discover-Rokus
Ip            Name                          Model                Description
--            ----                          -----                -----------
192.168.0.110 Bedroom Roku Stick           Roku Stick 3500X     Bedroom Roku Stick | 192.168.0.110
192.168.0.111 Roku Express                 Roku Express 3700X   Roku Express  | 192.168.0.111

PS C:\Scripts> Press-home 192.168.0.110


roku-remotegui.ps1

.NAME
    Roku-RemoteGui.ps1
.SYNOPSIS
    Powershell and WPF based Roku Remote that automatically finds Rokus on the local network.
.SYNTAX
    Just run the script to launch the GUI
.DESCRIPTRION
   Powershell and WPF based Roku Remote that automatically finds Rokus on the local network.
.REMARKS
    Thank you to POSHGUI.com for help with the GUI
#>