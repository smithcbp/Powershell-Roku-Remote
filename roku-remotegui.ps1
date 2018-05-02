<#
.NAME
    Roku-RemoteGui
.SYNOPSIS
    Powershell and WPF based Roku Remote that automatically finds Rokus on the local network.
.DESCRIPTION
   Powershell and WPF based Roku Remote that automatically finds Rokus on the local network.
.NOTES
    Just run the script to launch the GUI
    Thank you to POSHGUI.com for help with the GUI
    Roku API https://sdkdocs.roku.com/display/sdkdoc/External+Control+API
#>

#region Path Variables

$IconName                        = 'rokuremote.ico'
$ModuleName                      = 'Roku-Remote.psm1'
$IconPath                        = Join-Path $PSScriptRoot $IconName
$ModulePath                      = Join-Path $PSScriptRoot $ModuleName

$FavApps                         = @(
                                      'Netflix'
                                      'Hulu'
                                      'Plex'
                                      'Pandora'
                                      )

#endregion

#region Add required assemblies.

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework
[System.Windows.Forms.Application]::EnableVisualStyles()

#endregion

#region begin GUI

$Form                            = New-Object System.Windows.Forms.Form
$Form.clientSize                 = '400,650'
$Form.text                       = 'Roku Remote'
$Form.topMost                    = $false
$Form.backcolor                  = 'Black'
$Form.icon                       = $IconPath
$Form.FormBorderStyle            = 'FixedSingle'
$Form.MaximizeBox                = $false

$Label1                          = New-Object System.Windows.Forms.Label
$Label1.text                     = 'Select your Roku:'
$Label1.textalign                = 'MiddleCenter' 
$Label1.autosize                 = $true
$Label1.width                    = 25
$Label1.height                   = 10
$Label1.location                 = New-Object System.Drawing.Point(20,20)
$Label1.font                     = 'Consolas,18'
$Label1.forecolor                = 'Cyan'

$UpButton                        = New-Object System.Windows.Forms.Button
$UpButton.text                   = '▲'
$UpButton.width                  = 60
$UpButton.height                 = 60
$UpButton.location               = New-Object System.Drawing.Point(171,256)
$UpButton.font                   = 'Microsoft Sans Serif,16'
$UpButton.backcolor              = 'Blue'
$UpButton.forecolor              = 'Cyan'

$DownButton                      = New-Object System.Windows.Forms.Button
$DownButton.text                 = '▼'
$DownButton.width                = 60
$DownButton.height               = 60
$DownButton.location             = New-Object System.Drawing.Point(171,387)
$DownButton.font                 = 'Microsoft Sans Serif,16'
$DownButton.backcolor            = 'Blue'
$DownButton.forecolor              = 'Cyan'

$RightButton                     = New-Object System.Windows.Forms.Button
$RightButton.text                = '►'
$RightButton.width               = 60
$RightButton.height              = 60
$RightButton.location            = New-Object System.Drawing.Point(237,321)
$RightButton.font                = 'Microsoft Sans Serif,30'
$RightButton.textAlign           = 'MiddleCenter'
$RightButton.backcolor           = 'Blue'
$RightButton.forecolor              = 'Cyan'

$SelectButton                    = New-Object System.Windows.Forms.Button
$SelectButton.text               = 'OK'
$SelectButton.width              = 60
$SelectButton.height             = 60
$SelectButton.location           = New-Object System.Drawing.Point(171,321)
$SelectButton.font               = 'Microsoft Sans Serif,12'
$SelectButton.backcolor          = 'Blue'
$SelectButton.forecolor              = 'Cyan'

$LeftButton                      = New-Object System.Windows.Forms.Button
$LeftButton.text                 = '◄'
$LeftButton.width                = 60
$LeftButton.height               = 60
$LeftButton.location             = New-Object System.Drawing.Point(105,321)
$LeftButton.backcolor            = 'Blue'
$LeftButton.forecolor              = 'Cyan'
$LeftButton.font                 = 'Microsoft Sans Serif,30'


$BackButton                      = New-Object System.Windows.Forms.Button
$BackButton.text                 = 'Back'
$BackButton.width                = 87
$BackButton.height               = 50
$BackButton.location             = New-Object System.Drawing.Point(78,195)
$BackButton.font                 = 'Microsoft Sans Serif,12'
$BackButton.backcolor            = 'Blue'
$BackButton.forecolor              = 'Cyan'

$HomeButton                      = New-Object System.Windows.Forms.Button
$HomeButton.text                 = 'Home'
$HomeButton.width                = 87
$HomeButton.height               = 50
$HomeButton.location             = New-Object System.Drawing.Point(236,195)
$HomeButton.font                 = 'Microsoft Sans Serif,12'
$HomeButton.backcolor            = 'Blue'
$HomeButton.forecolor              = 'Cyan'

$InfoButton                      = New-Object System.Windows.Forms.Button
$InfoButton.text                 = '*'
$InfoButton.width                = 50
$InfoButton.height               = 50
$InfoButton.location             = New-Object System.Drawing.Point(176,520)
$InfoButton.font                 = 'Microsoft Sans Serif,24'
$InfoButton.textalign            = 'MiddleCenter'
$InfoButton.backcolor            = 'Blue'
$InfoButton.forecolor              = 'Cyan'

$RRButton                        = New-Object System.Windows.Forms.Button
$RRButton.text                   = '«'
$RRButton.width                  = 50
$RRButton.height                 = 50
$RRButton.location               = New-Object System.Drawing.Point(110,460)
$RRButton.font                   = 'Microsoft Sans Serif,16'
$RRButton.backcolor              = 'Blue'
$RRButton.forecolor              = 'Cyan'

$PlayButton                      = New-Object System.Windows.Forms.Button
$PlayButton.text                 = '►'
$PlayButton.width                = 50
$PlayButton.height               = 50
$PlayButton.location             = New-Object System.Drawing.Point(176,460)
$PlayButton.font                 = 'Microsoft Sans Serif,16'
$PlayButton.backcolor            = 'Blue'
$PlayButton.forecolor              = 'Cyan'

$FFButton                        = New-Object System.Windows.Forms.Button
$FFButton.text                   = '»'
$FFButton.width                  = 50
$FFButton.height                 = 50
$FFButton.location               = New-Object System.Drawing.Point(240,460)
$FFButton.font                   = 'Microsoft Sans Serif,16'
$FFButton.backcolor              = 'Blue'
$FFButton.forecolor              = 'Cyan'

$RebootButton                    = New-Object System.Windows.Forms.Button
$RebootButton.text               = 'Reboot'
$RebootButton.width              = 100
$RebootButton.height             = 50
$RebootButton.location           = New-Object System.Drawing.Point(260,520)
$RebootButton.font               = 'Microsoft Sans Serif,12'
$RebootButton.backcolor          = 'Blue'
$RebootButton.forecolor              = 'Cyan'

$AppsButton                      = New-Object System.Windows.Forms.Button
$AppsButton.text                 = 'Apps'
$AppsButton.width                = 100
$AppsButton.height               = 50
$AppsButton.location             = New-Object System.Drawing.Point(40,520)
$AppsButton.font                 = 'Microsoft Sans Serif,12'
$AppsButton.backcolor            = 'Blue'
$AppsButton.forecolor              = 'Cyan'

$RokuList                        = New-Object System.Windows.Forms.ListBox
$RokuList.width                  = 360
$RokuList.height                 = 130
$RokuList.location               = New-Object System.Drawing.Point(20,54)
$RokuList.font                   = 'Consolas,14'
$RokuList.horizontalscrollbar    = $true
$RokuList.backcolor              = 'Black'
$RokuList.forecolor              = 'Cyan'

$FavButton1                      = New-Object System.Windows.Forms.Button
$FavButton1.text                 = $FavApps[0]
$FavButton1.width                = 80
$FavButton1.height               = 50
$FavButton1.location             = New-Object System.Drawing.Point(25,585)
$FavButton1.font                 = 'Microsoft Sans Serif,10'
$FavButton1.backcolor            = 'Blue'
$FavButton1.forecolor              = 'Cyan'

$FavButton2                      = New-Object System.Windows.Forms.Button
$FavButton2.text                 = $FavApps[1]
$FavButton2.width                = 80
$FavButton2.height               = 50
$FavButton2.location             = New-Object System.Drawing.Point(115,585)
$FavButton2.font                 = 'Microsoft Sans Serif,10'
$FavButton2.backcolor            = 'Blue'
$FavButton2.forecolor              = 'Cyan'

$FavButton3                      = New-Object System.Windows.Forms.Button
$FavButton3.text                 = $FavApps[2]
$FavButton3.width                = 80
$FavButton3.height               = 50
$FavButton3.location             = New-Object System.Drawing.Point(205,585)
$FavButton3.font                 = 'Microsoft Sans Serif,10'
$FavButton3.backcolor            = 'Blue'
$FavButton3.forecolor              = 'Cyan'

$FavButton4                      = New-Object System.Windows.Forms.Button
$FavButton4.text                 = $FavApps[3]
$FavButton4.width                = 80
$FavButton4.height               = 50
$FavButton4.location             = New-Object System.Drawing.Point(295,585)
$FavButton4.font                 = 'Microsoft Sans Serif,10'
$FavButton4.backcolor            = 'Blue'
$FavButton4.forecolor              = 'Cyan'


$Form.controls.AddRange(@($UpButton,$DownButton,$RightButton,$SelectButton,$LeftButton,$BackButton,$HomeButton,$RebootButton,$AppsButton,$RokuList,$Label1,$InfoButton,$RRButton,$PlayButton,$FFButton,$FavButton1,$FavButton2,$FavButton3,$FavButton4))

#endregion

#region Import Roku-Remote.psm1 module

if (!(Test-Path $modulepath)){
    Write-Error -Message 'Please download Roku-Remote.psm1 from https://github.com/smithcbp/Powershell-Roku-Remote and place into the same folder as Roku-remote.ps1'
    Return
    }

Import-Module (Resolve-Path($modulepath))

#endregion

#region GUI events

$UpButton.Add_Click({
    $SelectedRoku = $Rokus | Where-Object Description -Like $RokuList.SelectedItem
    Send-RokuCommand -ip $SelectedRoku.ip -RokuCommand 'Up'
    })

$DownButton.Add_Click({
    $SelectedRoku = $Rokus | Where-Object Description -Like $RokuList.SelectedItem
    Send-RokuCommand -ip $SelectedRoku.ip -RokuCommand 'Down'
    })

$RightButton.Add_Click({
    $SelectedRoku = $Rokus | Where-Object Description -Like $RokuList.SelectedItem
    Send-RokuCommand -ip $SelectedRoku.ip -RokuCommand 'Right'
    })

$SelectButton.Add_Click({
    $SelectedRoku = $Rokus | Where-Object Description -Like $RokuList.SelectedItem
    Send-RokuCommand -ip $SelectedRoku.ip -RokuCommand 'Select' 
    })

$LeftButton.Add_Click({
    $SelectedRoku = $Rokus | Where-Object Description -Like $RokuList.SelectedItem
    Send-RokuCommand -ip $SelectedRoku.ip -RokuCommand 'Left'
    })

$BackButton.Add_Click({    
    $SelectedRoku = $Rokus | Where-Object Description -Like $RokuList.SelectedItem
    Send-RokuCommand -ip $SelectedRoku.ip -RokuCommand 'Back'
    })

$HomeButton.Add_Click({
    $SelectedRoku = $Rokus | Where-Object Description -Like $RokuList.SelectedItem
    Send-RokuCommand -ip $SelectedRoku.ip -RokuCommand 'Home'
    })

$InfoButton.Add_Click({
    $SelectedRoku = $Rokus | Where-Object Description -Like $RokuList.SelectedItem
    Send-RokuCommand -ip $SelectedRoku.ip -RokuCommand 'Info'
    })

$RRButton.Add_Click({
    $SelectedRoku = $Rokus | Where-Object Description -Like $RokuList.SelectedItem
    Send-RokuCommand -ip $SelectedRoku.ip -RokuCommand 'Rev'
    })

$PlayButton.Add_Click({
    $SelectedRoku = $Rokus | Where-Object Description -Like $RokuList.SelectedItem
    Send-RokuCommand -ip $SelectedRoku.ip -RokuCommand 'Play'
    })

$FFButton.Add_Click({
    $SelectedRoku = $Rokus | Where-Object Description -Like $RokuList.SelectedItem
    Send-RokuSelect -ip $SelectedRoku.ip -RokuCommand 'Fwd'
    })

$AppsButton.Add_Click({
    $SelectedRoku = $Rokus | Where-Object Description -Like $RokuList.SelectedItem
    Start-Job -ArgumentList $SelectedRoku.ip -ScriptBlock {
        Import-Module C:\Scripts\roku-remote\Roku-Remote.psm1
        Select-RokuApp -ip $args[0] 
        } 
    })

$FavButton1.Add_Click({
    $SelectedRoku = $Rokus | Where-Object Description -Like $RokuList.SelectedItem
    Send-RokuApp -Ip $SelectedRoku.ip -Name $FavApps[0]
    })

$FavButton2.Add_Click({
    $SelectedRoku = $Rokus | Where-Object Description -Like $RokuList.SelectedItem
    Send-RokuApp -Ip $SelectedRoku.ip -Name $FavApps[1]
    })
$FavButton3.Add_Click({
    $SelectedRoku = $Rokus | Where-Object Description -Like $RokuList.SelectedItem
    Send-RokuApp -Ip $SelectedRoku.ip -Name $FavApps[2]
    })
$FavButton4.Add_Click({
    $SelectedRoku = $Rokus | Where-Object Description -Like $RokuList.SelectedItem
    Send-RokuApp -Ip $SelectedRoku.ip -Name $FavApps[3]
    })

$RebootButton.Add_Click({
    $SelectedRoku = $Rokus | Where-Object Description -Like $RokuList.SelectedItem
    Start-Job -ArgumentList $SelectedRoku.ip -ScriptBlock {
        Import-Module C:\Scripts\roku-remote\Roku-Remote.psm1
        Send-RokuReboot -ip $args[0] 
        } 
    })

#endregion

#region Find and List Rokus on local network

$Rokus = Get-LocalRokus 

if (!$Rokus) {
    $RokuList.Items.Add("Cannot find any Roku Devices")
    $RokuList.Items.Add("on the local network")
    }

if ($Rokus){
    $Rokus | ForEach-Object {[void] $RokuList.Items.Add($_.Description)}
    $SelectedRoku = $Rokus | Where-Object Description -Like $RokuList.SelectedItem
    }

#endregion

$Form.ShowDialog()




