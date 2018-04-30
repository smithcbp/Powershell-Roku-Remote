<#
.SYNOPSIS

A collection of Functions for discovering and controlling local Roku devices.
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
        [ValidateSet('Home','Rev','Fwd','Play','Select','Left','Right','Down','Up','Back','InstandReplay','Info','Backspace','Search','Enter','FindRemote')]
        [string]
        $RokuCommand,
        [Parameter(Mandatory)] 
        [string]
        $Ip
        )
    $RokuUrl = 'http://' + $Ip + ':8060'
    Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/keypress/$RokuCommand" -method Post 

}

Function Send-RokuReboot {
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
    
    $RokuName = Get-LocalRokus | Where-Object ip -Like "$ip" | select -ExpandProperty name

    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Application]::EnableVisualStyles()
    Add-Type -AssemblyName System.Drawing
    Add-Type -AssemblyName PresentationFramework
    
    #region Apps Listbox Gui
    $Form                           = New-Object System.Windows.Forms.Form
    $Form.text                      = 'Select an App'
    $Form.size                      = New-Object System.Drawing.Size(350,640)
    $Form.startposition             = 'CenterScreen'
    $Form.backcolor                 = 'Black'
    $Form.FormBorderStyle           = 'FixedSingle'
    $Form.MaximizeBox                = $false

    $OKButton                       = New-Object System.Windows.Forms.Button
    $OKButton.location              = New-Object System.Drawing.Point(75,545)
    $OKButton.size                  = New-Object System.Drawing.Size(70,40)
    $OKButton.text                  = 'OK'
    $OKButton.dialogresult          = [System.Windows.Forms.DialogResult]::OK
    $OKButton.font                  = 'Microsoft Sans Serif,12'
    $OKButton.forecolor             = 'Cyan'
    $OKButton.backcolor             = 'Blue'
    $Form.acceptbutton              = $OKButton

    $CancelButton                   = New-Object System.Windows.Forms.Button
    $CancelButton.location          = New-Object System.Drawing.Point(190,545)
    $CancelButton.size              = New-Object System.Drawing.Size(70,40)
    $CancelButton.text              = 'Cancel'
    $CancelButton.dialogResult      = [System.Windows.Forms.DialogResult]::Cancel
    $CancelButton.font              = 'Microsoft Sans Serif,11'
    $CancelButton.foreColor         = 'Cyan'
    $CancelButton.backcolor         = 'Blue'
    $Form.cancelbutton              = $CancelButton

    $Label                          = New-Object System.Windows.Forms.Label
    $Label.location                 = New-Object System.Drawing.Point(10,15)
    $Label.size                     = New-Object System.Drawing.Size(280,20)
    $Label.text                     = 'Launch which app on:'
    $Label.font                     = 'Consolas,12'
    $Label.forecolor                = 'Cyan'
    
    $Label2                          = New-Object System.Windows.Forms.Label
    $Label2.location                 = New-Object System.Drawing.Point(10,35)
    $Label2.size                     = New-Object System.Drawing.Size(280,20)
    $Label2.text                     = "$RokuName"
    $Label2.font                     = 'Consolas,12'
    $Label2.forecolor                = 'Cyan'

    $Listbox                        = New-Object System.Windows.Forms.ListBox
    $Listbox.location               = New-Object System.Drawing.Point(10,60)
    $Listbox.size                   = New-Object System.Drawing.Size(293,20)
    $Listbox.height                 = 480
    $Listbox.font                   = New-Object System.Drawing.Font('Consolas','14',[System.Drawing.FontStyle]::Bold)
    $Listbox.BackColor              = 'Black'
    $Listbox.ForeColor              = 'Cyan'

    $Form.Controls.AddRange(@($Label,$Label2,$CancelButton,$OKButton,$Listbox))

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

#Hidden Menus (some might work) Based off of https://lifehacker.com/all-the-roku-secret-commands-and-menus-in-one-graphic-1779010902

Function Send-RokuSecretMenu1 {
        param(
    [Parameter(Mandatory)] 
    [string]
    $Ip
    )
    Send-RokuCommand -ip $Ip -RokuCommand 'Home'
    Start-Sleep -Seconds 3
    Send-RokuCommand -ip $Ip -RokuCommand 'Home'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Home'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Home'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Home'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Home'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Fwd'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Fwd'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Fwd'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Rev'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Rev'
    
    }

Function Send-RokuSecretMenu2 {
        param(
    [Parameter(Mandatory)] 
    [string]
    $Ip
    )
    Send-RokuCommand -ip $Ip -RokuCommand 'Home'
    Start-Sleep -Seconds 3
    Send-RokuCommand -ip $Ip -RokuCommand 'Home'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Home'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Home'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Home'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Home'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Up'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Right'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Down'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Left'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Up'
    
    }

Function Send-RokuWifiMenu {
        param(
    [Parameter(Mandatory)] 
    [string]
    $Ip
    )
    Send-RokuCommand -ip $Ip -RokuCommand 'Home'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Home'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Home'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Home'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Home'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Up'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Down'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Up'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Down'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Up'
    
    }

Function Send-PlatformMenu {
        param(
    [Parameter(Mandatory)] 
    [string]
    $Ip
    )
    Send-RokuCommand -ip $Ip -RokuCommand 'Home'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Home'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Home'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Home'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Home'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Fwd'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Play'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Rew'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Play'
    Start-Sleep -Seconds 1
    Send-RokuCommand -ip $Ip -RokuCommand 'Fw'
    
    }

Function Send-DeveloperMenu {
        param(
    [Parameter(Mandatory)] 
    [string]
    $Ip
    )
    Send-RokuCommand -ip $Ip -RokuCommand 'Home'
    Start-Sleep -Milliseconds 700
    Send-RokuCommand -ip $Ip -RokuCommand 'Home'
    Start-Sleep -Milliseconds 700
    Send-RokuCommand -ip $Ip -RokuCommand 'Home'
    Start-Sleep -Milliseconds 700
    Send-RokuCommand -ip $Ip -RokuCommand 'Up'
    Start-Sleep -Milliseconds 700
    Send-RokuCommand -ip $Ip -RokuCommand 'Up'
    Start-Sleep -Milliseconds 700
    Send-RokuCommand -ip $Ip -RokuCommand 'Right'
    Start-Sleep -Milliseconds 700
    Send-RokuCommand -ip $Ip -RokuCommand 'Left'
    Start-Sleep -Milliseconds 700
    Send-RokuCommand -ip $Ip -RokuCommand 'Right'
    Start-Sleep -Milliseconds 700
    Send-RokuCommand -ip $Ip -RokuCommand 'Left'
    Start-Sleep -Milliseconds 700
    Send-RokuCommand -ip $Ip -RokuCommand 'Right'
    
    }