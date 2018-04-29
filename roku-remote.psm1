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

Send-RokuCommand -ip $IP -rokucommand 'Home'
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

Function Send-RokuCommand {
    param(       
        [Parameter(Mandatory)]  
        [ValidateSet('Home','Rev','Fwd','Play','Select','Left','Right','Down','Up','Back','InstandReplay','Info','Backspace','Search','Enter')]
        [string]
        $RokuCommand,
        [Parameter(Mandatory)] 
        [string]
        $Ip
        )
    $RokuUrl = 'http://' + $Ip + ':8060'
    Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/keypress/$RokuCommand" -method Post 
}

Function Send-RokuRebootMacro {
    param(
    [Parameter(Mandatory)] 
    [string]
    $Ip
    )
    Send-RokuCommand -ip $Ip -RokuCommand 'Home'
    Start-Sleep -Seconds 2
    Send-RokuCommand -ip $Ip -RokuCommand 'Home'
    Start-Sleep -Seconds 2
    Send-RokuCommand -ip $Ip -RokuCommand 'Down'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Down'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Down'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Down'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Down'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Down'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Down'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Select'
    Start-Sleep -Seconds 2
    Send-RokuCommand -ip $Ip -RokuCommand 'Up'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Right'
    Start-Sleep -Seconds 1 
    Send-RokuCommand -ip $Ip -RokuCommand 'Up'
    Start-Sleep -Seconds 1 
    Send-RokuCommand -ip $Ip -RokuCommand 'Up'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Up'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Right'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Select' 
    }

Function Open-RokuApp {
    param(
    [Parameter(Mandatory)] 
    [string]
    $Ip
    )
    
#region WPF Form App Selection List

    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Application]::EnableVisualStyles()
    Add-Type -AssemblyName System.Drawing
    Add-Type -AssemblyName PresentationFramework
    
    #region Apps Listbox Gui
    $Form                           = New-Object System.Windows.Forms.Form
    $Form.text                      = 'Select an App'
    $Form.size                      = New-Object System.Drawing.Size(350,640)
    $Form.startposition             = 'CenterScreen'
    $Form.backcolor                 = 'DarkBlue'

    $OKButton                       = New-Object System.Windows.Forms.Button
    $OKButton.location              = New-Object System.Drawing.Point(75,545)
    $OKButton.size                  = New-Object System.Drawing.Size(70,40)
    $OKButton.text                  = 'OK'
    $OKButton.dialogresult          = [System.Windows.Forms.DialogResult]::OK
    $OKButton.font                  = 'Microsoft Sans Serif,12'
    $OKButton.backcolor             = 'Cyan'
    $Form.acceptbutton              = $OKButton

    $CancelButton                   = New-Object System.Windows.Forms.Button
    $CancelButton.location          = New-Object System.Drawing.Point(190,545)
    $CancelButton.size              = New-Object System.Drawing.Size(70,40)
    $CancelButton.text              = 'Cancel'
    $CancelButton.dialogResult      = [System.Windows.Forms.DialogResult]::Cancel
    $CancelButton.font              = 'Microsoft Sans Serif,10'
    $CancelButton.backColor         = 'Cyan'
    $Form.cancelbutton              = $CancelButton

    $Label                          = New-Object System.Windows.Forms.Label
    $Label.location                 = New-Object System.Drawing.Point(10,15)
    $Label.size                     = New-Object System.Drawing.Size(280,20)
    $Label.text                     = 'PLEASE SELECT AN APP:'
    $Label.font                     = 'Consolas,12'
    $Label.forecolor                = 'Cyan'
    
    $Listbox                        = New-Object System.Windows.Forms.ListBox
    $Listbox.location               = New-Object System.Drawing.Point(10,40)
    $Listbox.size                   = New-Object System.Drawing.Size(313,20)
    $Listbox.height                 = 500
    $Listbox.font                   = New-Object System.Drawing.Font('Consolas','14',[System.Drawing.FontStyle]::Bold)

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

#endregion

#region Out-Gridview App Selection List.
<#
    #Select App
    $RokuUrl = 'http://' + $Ip + ':8060'
    $AppsWeb = Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/query/apps" -method Get
    [xml]$Appsxml = $AppsWeb.Content
    $Apps = $Appsxml.apps.app | select "#text",id | sort "#text" 
    $App = $Apps | Out-GridView -PassThru
    $AppId = $App.id | Out-String
    Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/launch/$Appid" -method Post
    }
#>
#endregion