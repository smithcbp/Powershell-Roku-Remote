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
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework
[System.Windows.Forms.Application]::EnableVisualStyles()

#region begin GUI

$Form                            = New-Object System.Windows.Forms.Form
$Form.clientSize                 = '400,600'
$Form.text                       = 'Roku Remote'
$Form.topMost                    = $false
$Form.backcolor                  = 'DarkBlue'

$UpButton                        = New-Object System.Windows.Forms.Button
$UpButton.text                   = '▲'
$UpButton.width                  = 60
$UpButton.height                 = 60
$UpButton.location               = New-Object System.Drawing.Point(171,256)
$UpButton.Font                   = 'Microsoft Sans Serif,16'
$UpButton.backcolor              = 'Cyan'

$DownButton                      = New-Object System.Windows.Forms.Button
$DownButton.text                 = '▼'
$DownButton.width                = 60
$DownButton.height               = 60
$DownButton.location             = New-Object System.Drawing.Point(171,387)
$DownButton.font                 = 'Microsoft Sans Serif,16'
$DownButton.backcolor            = 'Cyan'

$RightButton                     = New-Object System.Windows.Forms.Button
$RightButton.text                = '►'
$RightButton.width               = 60
$RightButton.height              = 60
$RightButton.location            = New-Object System.Drawing.Point(237,321)
$RightButton.font                = 'Microsoft Sans Serif,30'
$RightButton.textAlign           = 'MiddleCenter'
$RightButton.backcolor           = 'Cyan'

$SelectButton                    = New-Object System.Windows.Forms.Button
$SelectButton.text               = 'OK'
$SelectButton.width              = 60
$SelectButton.height             = 60
$SelectButton.location           = New-Object System.Drawing.Point(171,321)
$SelectButton.font               = 'Microsoft Sans Serif,12'
$SelectButton.backcolor          = 'Cyan'

$LeftButton                      = New-Object System.Windows.Forms.Button
$LeftButton.text                 = '◄'
$LeftButton.width                = 60
$LeftButton.height               = 60
$LeftButton.location             = New-Object System.Drawing.Point(105,321)
$LeftButton.backcolor            = 'Cyan'
$LeftButton.font                 = 'Microsoft Sans Serif,30'


$BackButton                      = New-Object System.Windows.Forms.Button
$BackButton.text                 = 'Back'
$BackButton.width                = 87
$BackButton.height               = 50
$BackButton.location             = New-Object System.Drawing.Point(78,195)
$BackButton.font                 = 'Microsoft Sans Serif,12'
$BackButton.backcolor            = 'Cyan'

$HomeButton                      = New-Object System.Windows.Forms.Button
$HomeButton.text                 = 'Home'
$HomeButton.width                = 87
$HomeButton.height               = 50
$HomeButton.location             = New-Object System.Drawing.Point(236,195)
$HomeButton.font                 = 'Microsoft Sans Serif,12'
$HomeButton.backcolor            = 'Cyan'

$InfoButton                      = New-Object System.Windows.Forms.Button
$InfoButton.text                 = '*'
$InfoButton.width                = 50
$InfoButton.height               = 50
$InfoButton.location             = New-Object System.Drawing.Point(176,520)
$InfoButton.font                 = 'Microsoft Sans Serif,24'
$InfoButton.textalign            = 'MiddleCenter'
$InfoButton.backcolor            = 'Cyan'

$RRButton                        = New-Object System.Windows.Forms.Button
$RRButton.text                   = '«'
$RRButton.width                  = 50
$RRButton.height                 = 50
$RRButton.location               = New-Object System.Drawing.Point(110,460)
$RRButton.font                   = 'Microsoft Sans Serif,16'
$RRButton.backcolor              = 'Cyan'

$PlayButton                      = New-Object System.Windows.Forms.Button
$PlayButton.text                 = '►'
$PlayButton.width                = 50
$PlayButton.height               = 50
$PlayButton.location             = New-Object System.Drawing.Point(176,460)
$PlayButton.font                 = 'Microsoft Sans Serif,16'
$PlayButton.backcolor            = 'Cyan'

$FFButton                        = New-Object System.Windows.Forms.Button
$FFButton.text                   = '»'
$FFButton.width                  = 50
$FFButton.height                 = 50
$FFButton.location               = New-Object System.Drawing.Point(240,460)
$FFButton.font                   = 'Microsoft Sans Serif,16'
$FFButton.backcolor              = 'Cyan'

$RebootButton                    = New-Object System.Windows.Forms.Button
$RebootButton.text               = 'Reboot'
$RebootButton.width              = 100
$RebootButton.height             = 50
$RebootButton.location           = New-Object System.Drawing.Point(260,520)
$RebootButton.font               = 'Microsoft Sans Serif,12'
$RebootButton.backcolor          = 'Cyan'

$AppsButton                      = New-Object System.Windows.Forms.Button
$AppsButton.text                 = 'Apps'
$AppsButton.width                = 100
$AppsButton.height               = 50
$AppsButton.location             = New-Object System.Drawing.Point(40,520)
$AppsButton.font                 = 'Microsoft Sans Serif,12'
$AppsButton.backcolor            = 'Cyan'

$RokuList                        = New-Object System.Windows.Forms.ListBox
$RokuList.width                  = 360
$RokuList.height                 = 130
$RokuList.location               = New-Object System.Drawing.Point(20,54)
$RokuList.font                   = 'Consolas,14'
$RokuList.horizontalscrollbar    = $true

$Label1                          = New-Object System.Windows.Forms.Label
$Label1.text                     = 'Select your Roku:'
$Label1.textalign                = 'MiddleCenter' 
$Label1.autosize                 = $true
$Label1.width                    = 25
$Label1.height                   = 10
$Label1.location                 = New-Object System.Drawing.Point(20,20)
$Label1.font                     = 'Consolas,18'
$Label1.forecolor                = 'Cyan'

$Form.controls.AddRange(@($UpButton,$DownButton,$RightButton,$SelectButton,$LeftButton,$BackButton,$HomeButton,$RebootButton,$AppsButton,$RokuList,$Label1,$InfoButton,$RRButton,$PlayButton,$FFButton))

#endregion

if (!(Test-Path .\Roku-remote.psm1)){
    Write-Error -Message 'Please download Roku-Remote.psm1 from https://github.com/smithcbp/Powershell-Roku-Remote and place into the same folder as Roku-remote.ps1'
    Return
    }

Import-Module (Resolve-Path('Roku-remote.psm1'))

#region GUI events

$UpButton.Add_Click({
    $SelectedRoku = $Rokus | Where-Object Description -Like $RokuList.SelectedItem
    Send-RokuUp -ip $SelectedRoku.ip
    })

$DownButton.Add_Click({
    $SelectedRoku = $Rokus | Where-Object Description -Like $RokuList.SelectedItem
    Send-RokuDown -ip $SelectedRoku.ip
    })

$RightButton.Add_Click({
    $SelectedRoku = $Rokus | Where-Object Description -Like $RokuList.SelectedItem
    Send-RokuRight -ip $SelectedRoku.ip
    })

$SelectButton.Add_Click({
    $SelectedRoku = $Rokus | Where-Object Description -Like $RokuList.SelectedItem
    Send-RokuSelect -ip $SelectedRoku.ip
    })

$LeftButton.Add_Click({
    $SelectedRoku = $Rokus | Where-Object Description -Like $RokuList.SelectedItem
    Send-RokuLeft -ip $SelectedRoku.ip
    })

$BackButton.Add_Click({    
    $SelectedRoku = $Rokus | Where-Object Description -Like $RokuList.SelectedItem
    Send-RokuBack -ip $SelectedRoku.ip
    })

$HomeButton.Add_Click({
    $SelectedRoku = $Rokus | Where-Object Description -Like $RokuList.SelectedItem
    Send-RokuHome -ip $SelectedRoku.ip
    })

$InfoButton.Add_Click({
    $SelectedRoku = $Rokus | Where-Object Description -Like $RokuList.SelectedItem
    Send-RokuInfo -ip $SelectedRoku.ip
    })

$RRButton.Add_Click({
    $SelectedRoku = $Rokus | Where-Object Description -Like $RokuList.SelectedItem
    Send-RokuRev -ip $SelectedRoku.ip
    })

$PlayButton.Add_Click({
    $SelectedRoku = $Rokus | Where-Object Description -Like $RokuList.SelectedItem
    Send-RokuPlay -ip $SelectedRoku.ip
    })

$FFButton.Add_Click({
    $SelectedRoku = $Rokus | Where-Object Description -Like $RokuList.SelectedItem
    Send-RokuSelect -ip $SelectedRoku.ip
    })

$AppsButton.Add_Click({
    $SelectedRoku = $Rokus | Where-Object Description -Like $RokuList.SelectedItem
    Open-RokuApp -ip $SelectedRoku.ip
    })

$RebootButton.Add_Click({
    $SelectedRoku = $Rokus | Where-Object Description -Like $RokuList.SelectedItem
    Send-RokuRebootMacro -ip $SelectedRoku.ip
    })

#endregion

$Rokus = Get-LocalRokus
$Rokus | ForEach-Object {[void] $RokuList.Items.Add($_.Description)}
$SelectedRoku = $Rokus | Where-Object Description -Like $RokuList.SelectedItem
$Rokuurl = 'http://' + $SelectedRoku.ip + ':8060'

$Form.ShowDialog()




