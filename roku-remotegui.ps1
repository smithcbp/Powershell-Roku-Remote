<#
.NAME
    Roku-Remote
.SYNOPSIS
    Powershell and WPF based Roku Remote that automatically finds Rokus on the local network.
.SYNTAX
    Just run the script to launch the GUI
.DESCRIPTRION
   Powershell and WPF based Roku Remote that automatically finds Rokus on the local network.
.REMARKS
    Thank you to POSHGUI.com for help with the GUI
#>

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework

#region begin GUI{

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '400,600'
$Form.text                       = "Roku Remote"
$Form.TopMost                    = $false
$Form.BackColor                  = "DarkBlue"

$UpButton                        = New-Object system.Windows.Forms.Button
$UpButton.text                   = "▲"
$UpButton.width                  = 60
$UpButton.height                 = 60
$UpButton.location               = New-Object System.Drawing.Point(171,256)
$UpButton.Font                   = 'Microsoft Sans Serif,16'
$UpButton.BackColor              = "Cyan"

$DownButton                      = New-Object system.Windows.Forms.Button
$DownButton.text                 = "▼"
$DownButton.width                = 60
$DownButton.height               = 60
$DownButton.location             = New-Object System.Drawing.Point(171,387)
$DownButton.Font                 = 'Microsoft Sans Serif,16'
$DownButton.BackColor            = "Cyan"

$RightButton                     = New-Object system.Windows.Forms.Button
$RightButton.text                = "►"
$RightButton.width               = 60
$RightButton.height              = 60
$RightButton.location            = New-Object System.Drawing.Point(237,321)
$RightButton.Font                = 'Microsoft Sans Serif,30'
$RightButton.TextAlign           = "MiddleCenter"
$RightButton.BackColor           = "Cyan"

$SelectButton                    = New-Object system.Windows.Forms.Button
$SelectButton.text               = "OK"
$SelectButton.width              = 60
$SelectButton.height             = 60
$SelectButton.location           = New-Object System.Drawing.Point(171,321)
$SelectButton.Font               = 'Microsoft Sans Serif,12'
$SelectButton.BackColor          = "Cyan"

$LeftButton                      = New-Object system.Windows.Forms.Button
$LeftButton.text                 = "◄"
$LeftButton.width                = 60
$LeftButton.height               = 60
$LeftButton.location             = New-Object System.Drawing.Point(105,321)
$LeftButton.BackColor            = "Cyan"
$LeftButton.Font                 = 'Microsoft Sans Serif,30'


$BackButton                      = New-Object system.Windows.Forms.Button
$BackButton.text                 = "Back"
$BackButton.width                = 87
$BackButton.height               = 50
$BackButton.location             = New-Object System.Drawing.Point(78,195)
$BackButton.Font                 = 'Microsoft Sans Serif,12'
$BackButton.BackColor            = "Cyan"

$HomeButton                      = New-Object system.Windows.Forms.Button
$HomeButton.text                 = "Home"
$HomeButton.width                = 87
$HomeButton.height               = 50
$HomeButton.location             = New-Object System.Drawing.Point(236,195)
$HomeButton.Font                 = 'Microsoft Sans Serif,12'
$HomeButton.BackColor            = "Cyan"

$InfoButton                      = New-Object system.Windows.Forms.Button
$InfoButton.text                 = "*"
$InfoButton.width                = 50
$InfoButton.height               = 50
$InfoButton.location             = New-Object System.Drawing.Point(176,520)
$InfoButton.Font                 = 'Microsoft Sans Serif,24'
$InfoButton.TextAlign            = "MiddleCenter"
$InfoButton.BackColor            = "Cyan"

$RRButton                        = New-Object system.Windows.Forms.Button
$RRButton.text                   = "«"
$RRButton.width                  = 50
$RRButton.height                 = 50
$RRButton.location               = New-Object System.Drawing.Point(110,460)
$RRButton.Font                   = 'Microsoft Sans Serif,16'
$RRButton.BackColor              = "Cyan"

$PlayButton                      = New-Object system.Windows.Forms.Button
$PlayButton.text                 = "►"
$PlayButton.width                = 50
$PlayButton.height               = 50
$PlayButton.location             = New-Object System.Drawing.Point(176,460)
$PlayButton.Font                 = 'Microsoft Sans Serif,16'
$PlayButton.BackColor            = "Cyan"

$FFButton                        = New-Object system.Windows.Forms.Button
$FFButton.text                   = "»"
$FFButton.width                  = 50
$FFButton.height                 = 50
$FFButton.location               = New-Object System.Drawing.Point(240,460)
$FFButton.Font                   = 'Microsoft Sans Serif,16'
$FFButton.BackColor              = "Cyan"

$RebootButton                    = New-Object system.Windows.Forms.Button
$RebootButton.text               = "Reboot"
$RebootButton.width              = 100
$RebootButton.height             = 50
$RebootButton.location           = New-Object System.Drawing.Point(260,520)
$RebootButton.Font               = 'Microsoft Sans Serif,12'
$RebootButton.BackColor          = "Cyan"

$AppsButton                      = New-Object system.Windows.Forms.Button
$AppsButton.text                 = "Apps"
$AppsButton.width                = 100
$AppsButton.height               = 50
$AppsButton.location             = New-Object System.Drawing.Point(40,520)
$AppsButton.Font                 = 'Microsoft Sans Serif,12'
$AppsButton.BackColor            = "Cyan"

$RokuList                        = New-Object system.Windows.Forms.ListBox
$RokuList.width                  = 360
$RokuList.height                 = 130
$RokuList.location               = New-Object System.Drawing.Point(20,54)
$RokuList.Font                   = 'Consolas,14'
$RokuList.HorizontalScrollbar    = $true

$Label1                          = New-Object system.Windows.Forms.Label
$Label1.text                     = "Select your Roku"
$Label1.AutoSize                 = $true
$Label1.width                    = 25
$Label1.height                   = 10
$Label1.location                 = New-Object System.Drawing.Point(62,10)
$Label1.Font                     = 'Consolas,18'
$Label1.ForeColor                = "Cyan"

$Form.controls.AddRange(@($UpButton,$DownButton,$RightButton,$SelectButton,$LeftButton,$BackButton,$HomeButton,$RebootButton,$AppsButton,$RokuList,$Label1,$InfoButton,$RRButton,$PlayButton,$FFButton))

#region gui events

$UpButton.Add_Click({
    $selectedroku = $rokus | Where-Object Description -Like $RokuList.SelectedItem
    press-up -ip $selectedroku.ip
    })

$DownButton.Add_Click({
    $selectedroku = $rokus | Where-Object Description -Like $RokuList.SelectedItem
    press-down -ip $selectedroku.ip
    })

$RightButton.Add_Click({
    $selectedroku = $rokus | Where-Object Description -Like $RokuList.SelectedItem
    press-right -ip $selectedroku.ip
    })

$selectButton.Add_Click({
    $selectedroku = $rokus | Where-Object Description -Like $RokuList.SelectedItem
    press-select -ip $selectedroku.ip
    })

$LeftButton.Add_Click({
    $selectedroku = $rokus | Where-Object Description -Like $RokuList.SelectedItem
    press-left -ip $selectedroku.ip
    })

$BackButton.Add_Click({    
    $selectedroku = $rokus | Where-Object Description -Like $RokuList.SelectedItem
    press-back -ip $selectedroku.ip
    })

$HomeButton.Add_Click({
    $selectedroku = $rokus | Where-Object Description -Like $RokuList.SelectedItem
    press-home -ip $selectedroku.ip
    })

$InfoButton.Add_Click({
    $selectedroku = $rokus | Where-Object Description -Like $RokuList.SelectedItem
    press-info -ip $selectedroku.ip
    })

$RRButton.Add_Click({
    $selectedroku = $rokus | Where-Object Description -Like $RokuList.SelectedItem
    press-rev -ip $selectedroku.ip
    })

$PlayButton.Add_Click({
    $selectedroku = $rokus | Where-Object Description -Like $RokuList.SelectedItem
    press-play -ip $selectedroku.ip
    })

$FFButton.Add_Click({
    $selectedroku = $rokus | Where-Object Description -Like $RokuList.SelectedItem
    press-select -ip $selectedroku.ip
    })

$AppsButton.Add_Click({
    $selectedroku = $rokus | Where-Object Description -Like $RokuList.SelectedItem
    launch-rokuapp -ip $selectedroku.ip
    })

$RebootButton.Add_Click({
    $selectedroku = $rokus | Where-Object Description -Like $RokuList.SelectedItem
    RebootMacro -ip $selectedroku.ip
    })

#endregion

#endregion GUI

if (!(Test-Path .\roku-remote.psm1)){
    Write-Error -Message "Please download roku-commands.psm1 from XXX and place into the same folder as roku-remote.ps1"
    Return
    }

Import-Module (Resolve-Path('roku-remote.psm1'))

$rokus = Discover-Rokus
$rokus | ForEach-Object {[void] $RokuList.Items.Add($_.Description)}
$selectedroku = $rokus | Where-Object Description -Like $RokuList.SelectedItem
$rokuurl = "http://" + $selectedroku.ip + ":8060"

$result = $Form.ShowDialog()




