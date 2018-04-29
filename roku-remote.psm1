<#
.SYNOPSIS

A collection of functions for discovering and controlling local Roku devices.
Import-Module .\roku-commands.psm1

.NOTES

Get-LocalRokus
Ip            Name                          Model                Description
--            ----                          -----                -----------
192.168.0.110 Bedroom Roku Stick           Roku Stick 3500X     Bedroom Roku Stick | 192.168.0.110
192.168.0.111 Roku Express                 Roku Express 3700X   Roku Express  | 192.168.0.111

Send-RokuXXX -ip $Ip
RebootMacro -ip $Ip
Open-RokuApp -ip $Ip

#>

Function Get-LocalRokus {

$RokuOUIS = @(
    'DC-3A-5E'
    'D0-4D-2C'
    'CC-6D-A0'
    'C8-3A-6B'
    'B8-A1-75'
    'B8-3E-59'
    'B0-EE-7B'
    'B0-A7-37'
    'AC-3A-7A'
    '88-DE-A9'
    '08-05-81'
    '00-0D-4B'
    )
$RokuIps = @()
$Rokus = @()

foreach($Oui in $RokuOUIS) {
    $RokuIps += Get-NetNeighbor -LinkLayerAddress $Oui*
    }

$Rokus = foreach ($RokuIp_Item in $RokuIps) {
    $Ip = $RokuIp_Item.IPAddress | Out-String
    $Ip = $Ip.Trim()
    $Uri = 'http://' + $Ip + ':8060'
    $Rokuweb = (Invoke-WebRequest -UseBasicParsing $Uri)
    [xml]$RokuXML = $Rokuweb.Content
    $RokuName = $RokuXML.root.device.friendlyName
    $RokuModes = $RokuXML.root.device.modelname + ' ' + $RokuXML.root.device.modelnumber
    [pscustomobject]@{
        Ip = $Ip
        Name = $RokuName
        Model = $RokuModes
        Description = $RokuName + ' | ' + $Ip
        }
    }
Write-Output $Rokus
}

Function Send-RokuHome {
    param([string]$Ip)   
    $RokuUrl = 'http://' + $Ip + ':8060'
    Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/keypress/Home" -method Post 
    }

Function Send-RokuRev {
    param([string]$Ip)   
    $RokuUrl = 'http://' + $Ip + ':8060'
    Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/keypress/Rev" -method Post 
    }

Function Send-RokuFwd {
    param([string]$Ip)   
    $RokuUrl = 'http://' + $Ip + ':8060'
    Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/keypress/Fwd" -method Post 
    }

Function Send-RokuPlay{
    param([string]$Ip)   
    $RokuUrl = 'http://' + $Ip + ':8060'
    Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/keypress/Play" -method Post 
    }

Function Send-RokuSelect {
    param([string]$Ip)   
    $RokuUrl = 'http://' + $Ip + ':8060'
    Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/keypress/Select" -method Post 
    }

Function Send-RokuLeft {
    param([string]$Ip)   
    $RokuUrl = 'http://' + $Ip + ':8060'
    Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/keypress/Left" -method Post 
    }

Function Send-RokuRight {
    param([string]$Ip)   
    $RokuUrl = 'http://' + $Ip + ':8060'
    Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/keypress/Right" -method Post 
    }

Function Send-RokuDown {
    param([string]$Ip)   
    $RokuUrl = 'http://' + $Ip + ':8060'
    Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/keypress/Down" -method Post 
    }

Function Send-RokuUp {
    param([string]$Ip)   
    $RokuUrl = 'http://' + $Ip + ':8060'
    Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/keypress/Up" -method Post 
    }

Function Send-RokuBack {
    param([string]$Ip)   
    $RokuUrl = 'http://' + $Ip + ':8060'
    Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/keypress/Back" -method Post 
    }

Function Send-RokuInstantReplay {
    param([string]$Ip)   
    $RokuUrl = 'http://' + $Ip + ':8060'
    Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/keypress/InstantReplay" -method Post 
    }

Function Send-RokuInfo {
    param([string]$Ip)   
    $RokuUrl = 'http://' + $Ip + ':8060'
    Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/keypress/Info" -method Post 
    }

Function Send-RokuBackspace {
    param([string]$Ip)   
    $RokuUrl = 'http://' + $Ip + ':8060'
    Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/keypress/Backspace" -method Post 
    }

Function Send-RokuSearch {
    param([string]$Ip)   
    $RokuUrl = 'http://' + $Ip + ':8060'
    Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/keypress/Search" -method Post 
    }

Function Send-RokuEnter {
    param([string]$Ip)   
    $RokuUrl = 'http://' + $Ip + ':8060'
    Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/keypress/Enter" -method Post 
    }

Function Send-RokuRebootMacro {
    param([string]$Ip)
    Send-RokuHome $Ip
    Start-Sleep -Seconds 2
    Send-RokuHome $Ip
    Start-Sleep -Seconds 2
    Send-RokuDown $Ip
    Start-Sleep -Seconds 1
    Send-RokuDown $Ip
    Start-Sleep -Seconds 1
    Send-RokuDown $Ip
    Start-Sleep -Seconds 1
    Send-RokuDown $Ip
    Start-Sleep -Seconds 1
    Send-RokuDown $Ip
    Start-Sleep -Seconds 1
    Send-RokuDown $Ip
    Start-Sleep -Seconds 1
    Send-RokuDown $Ip
    Start-Sleep -Seconds 1
    Send-RokuSelect $Ip
    Start-Sleep -Seconds 2
    Send-RokuUp $Ip
    Start-Sleep -Seconds 1
    Send-RokuRight $Ip
    Start-Sleep -Seconds 1 
    Send-RokuUp $Ip
    Start-Sleep -Seconds 1 
    Send-RokuUp $Ip
    Start-Sleep -Seconds 1
    Send-RokuUp $Ip
    Start-Sleep -Seconds 1
    Send-RokuRight $Ip
    Start-Sleep -Seconds 1
    Send-RokuSelect $Ip 
    }

Function Open-RokuApp {
    param([string]$Ip)
    
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Application]::EnableVisualStyles()
    Add-Type -AssemblyName System.Drawing
    Add-Type -AssemblyName PresentationFramework
    
    #region Apps Listbox Gui
    $Form                           = New-Object System.Windows.Forms.Form
    $Form.Text                      = 'Select an App'
    $Form.Size                      = New-Object System.Drawing.Size(350,640)
    $Form.StartPosition             = 'CenterScreen'
    $Form.BackColor                 = 'DarkBlue'

    $OKButton                       = New-Object System.Windows.Forms.Button
    $OKButton.Location              = New-Object System.Drawing.Point(75,545)
    $OKButton.Size                  = New-Object System.Drawing.Size(70,40)
    $OKButton.Text                  = 'OK'
    $OKButton.DialogResult          = [System.Windows.Forms.DialogResult]::OK
    $OKButton.Font                  = 'Microsoft Sans Serif,12'
    $OKButton.BackColor             = 'Cyan'
    $Form.AcceptButton              = $OKButton

    $CancelButton                   = New-Object System.Windows.Forms.Button
    $CancelButton.Location          = New-Object System.Drawing.Point(190,545)
    $CancelButton.Size              = New-Object System.Drawing.Size(70,40)
    $CancelButton.Text              = 'Cancel'
    $CancelButton.DialogResult      = [System.Windows.Forms.DialogResult]::Cancel
    $CancelButton.Font              = 'Microsoft Sans Serif,10'
    $CancelButton.BackColor         = 'Cyan'
    $Form.CancelButton              = $CancelButton

    $Label                          = New-Object System.Windows.Forms.Label
    $Label.Location                 = New-Object System.Drawing.Point(10,15)
    $Label.Size                     = New-Object System.Drawing.Size(280,20)
    $Label.Text                     = 'PLEASE SELECT AN APP:'
    $Label.Font                     = 'Consolas,12'
    $Label.ForeColor                = 'Cyan'
    
    $Listbox                        = New-Object System.Windows.Forms.ListBox
    $Listbox.Location               = New-Object System.Drawing.Point(10,40)
    $Listbox.Size                   = New-Object System.Drawing.Size(313,20)
    $Listbox.Height                 = 500
    $Listbox.Font                   = New-Object System.Drawing.Font('Comic Sans MS',16,[System.Drawing.FontStyle]::Bold)

    $Form.Controls.AddRange(@($Label,$CancelButton,$OKButton,$Listbox))

    #endregion

    #Select App
    $RokuUrl = 'http://' + $Ip + ':8060'
    $AppsWeb = Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/query/apps" -method Get
    [xml]$Appsxml = $AppsWeb.Content
    $Apps = $Appsxml.apps.app | select "#text",id -ExpandProperty "#text" | sort "#text"
    foreach ($App in $Apps){
        [void] $Listbox.Items.Add($App)
    }

    $Form.Topmost = $true
    $Result = $Form.ShowDialog()
    if ($Result -eq 'Cancel'){Return}
    if ($Result -eq 'OK'){
        $SelectedApp = $Listbox.SelectedItem
        $App = $Apps | Where-Object "#text" -Like $SelectedApp
        $AppId = $App.id | Out-String
        Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/launch/$Appid" -method Post
        }
}