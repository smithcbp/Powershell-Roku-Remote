<#
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

StatusCode        : 200
StatusDescription : OK
Content           : {}
RawContent        : HTTP/1.1 200 OK
                    Content-Length: 0
                    Server: Roku UPnP/1.0 MiniUPnPd/1.4


Headers           : {[Content-Length, 0], [Server, Roku UPnP/1.0 MiniUPnPd/1.4]}
RawContentLength  : 0


#>

Function Discover-Rokus {

$rokuouis = "DC-3A-5E","D0-4D-2C","CC-6D-A0","C8-3A-6B","B8-A1-75","B8-3E-59","B0-EE-7B","B0-A7-37","AC-3A-7A","88-DE-A9","08-05-81","00-0D-4B"
$rokuips = @()
$rokus = @()

ForEach($oui in $rokuouis) {
    $rokuips += Get-NetNeighbor -LinkLayerAddress $oui*
    }

$rokus = ForEach ($rokuip in $rokuips) {
    $ip = $rokuip.IPAddress | Out-String
    $ip = $ip.Trim()
    $uri = "http://" + $ip + ":8060"
    $rokuweb = (Invoke-WebRequest -UseBasicParsing $uri)
    [xml]$rokuxml = $rokuweb.Content
    $rokuname = $rokuxml.root.device.friendlyName
    $rokumodel = $rokuxml.root.device.modelname + " " + $rokuxml.root.device.modelnumber
    [pscustomobject]@{
        Ip = $ip
        Name = $rokuname
        Model = $rokumodel
        Description = $rokuname + " | " + $ip
        }
    }
Write-Output $rokus
}

Function Press-Home {
    param([string]$ip)   
    $rokuurl = "http://" + $ip + ":8060"
    Invoke-WebRequest -UseBasicParsing -Uri "$rokuurl/keypress/Home" -method Post 
    }

Function Press-Rev {
    param([string]$ip)   
    $rokuurl = "http://" + $ip + ":8060"
    Invoke-WebRequest -UseBasicParsing -Uri "$rokuurl/keypress/Rev" -method Post 
    }

Function Press-Fwd {
    param([string]$ip)   
    $rokuurl = "http://" + $ip + ":8060"
    Invoke-WebRequest -UseBasicParsing -Uri "$rokuurl/keypress/Fwd" -method Post 
    }

Function Press-Play{
    param([string]$ip)   
    $rokuurl = "http://" + $ip + ":8060"
    Invoke-WebRequest -UseBasicParsing -Uri "$rokuurl/keypress/Play" -method Post 
    }

Function Press-Select {
    param([string]$ip)   
    $rokuurl = "http://" + $ip + ":8060"
    Invoke-WebRequest -UseBasicParsing -Uri "$rokuurl/keypress/Select" -method Post 
    }

Function Press-Left {
    param([string]$ip)   
    $rokuurl = "http://" + $ip + ":8060"
    Invoke-WebRequest -UseBasicParsing -Uri "$rokuurl/keypress/Left" -method Post 
    }

Function Press-Right {
    param([string]$ip)   
    $rokuurl = "http://" + $ip + ":8060"
    Invoke-WebRequest -UseBasicParsing -Uri "$rokuurl/keypress/Right" -method Post 
    }

Function Press-Down {
    param([string]$ip)   
    $rokuurl = "http://" + $ip + ":8060"
    Invoke-WebRequest -UseBasicParsing -Uri "$rokuurl/keypress/Down" -method Post 
    }

Function Press-Up {
    param([string]$ip)   
    $rokuurl = "http://" + $ip + ":8060"
    Invoke-WebRequest -UseBasicParsing -Uri "$rokuurl/keypress/Up" -method Post 
    }

Function Press-Back {
    param([string]$ip)   
    $rokuurl = "http://" + $ip + ":8060"
    Invoke-WebRequest -UseBasicParsing -Uri "$rokuurl/keypress/Back" -method Post 
    }

Function Press-InstantReplay {
    param([string]$ip)   
    $rokuurl = "http://" + $ip + ":8060"
    Invoke-WebRequest -UseBasicParsing -Uri "$rokuurl/keypress/InstantReplay" -method Post 
    }

Function Press-Info {
    param([string]$ip)   
    $rokuurl = "http://" + $ip + ":8060"
    Invoke-WebRequest -UseBasicParsing -Uri "$rokuurl/keypress/Info" -method Post 
    }

Function Press-Backspace {
    param([string]$ip)   
    $rokuurl = "http://" + $ip + ":8060"
    Invoke-WebRequest -UseBasicParsing -Uri "$rokuurl/keypress/Backspace" -method Post 
    }

Function Press-Search {
    param([string]$ip)   
    $rokuurl = "http://" + $ip + ":8060"
    Invoke-WebRequest -UseBasicParsing -Uri "$rokuurl/keypress/Search" -method Post 
    }

Function Press-Enter {
    param([string]$ip)   
    $rokuurl = "http://" + $ip + ":8060"
    Invoke-WebRequest -UseBasicParsing -Uri "$rokuurl/keypress/Enter" -method Post 
    }

Function RebootMacro {
    param([string]$ip)
    Press-Home $ip
    sleep -s 2
    Press-Home $ip
    sleep -s 2
    Press-Down $ip
    sleep -s 1
    Press-Down $ip
    sleep -s 1
    Press-Down $ip
    sleep -s 1
    Press-Down $ip
    sleep -s 1
    Press-Down $ip
    sleep -s 1
    Press-Down $ip
    sleep -s 1
    Press-Down $ip
    sleep -s 1
    Press-Select $ip
    sleep -s 2
    Press-Up $ip
    sleep -s 1
    Press-Right $ip
    sleep -s 1 
    Press-Up $ip
    sleep -s 1 
    Press-Up $ip
    sleep -s 1
    Press-Up $ip
    sleep -s 1
    Press-Right $ip
    sleep -s 1
    Press-Select $ip 
    }

Function Launch-RokuApp {
    param([string]$ip)
    
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Application]::EnableVisualStyles()
    Add-Type -AssemblyName System.Drawing
    Add-Type -AssemblyName PresentationFramework
    
    #region Apps Listbox Gui
    $form                           = New-Object System.Windows.Forms.Form
    $form.Text                      = 'Select an App'
    $form.Size                      = New-Object System.Drawing.Size(350,640)
    $form.StartPosition             = 'CenterScreen'
    $form.BackColor                 = "DarkBlue"

    $OKButton                       = New-Object System.Windows.Forms.Button
    $OKButton.Location              = New-Object System.Drawing.Point(75,545)
    $OKButton.Size                  = New-Object System.Drawing.Size(70,40)
    $OKButton.Text                  = 'OK'
    $OKButton.DialogResult          = [System.Windows.Forms.DialogResult]::OK
    $OKButton.Font                  = 'Microsoft Sans Serif,12'
    $OKButton.BackColor             = "Cyan"
    $form.AcceptButton              = $OKButton

    $CancelButton                   = New-Object System.Windows.Forms.Button
    $CancelButton.Location          = New-Object System.Drawing.Point(190,545)
    $CancelButton.Size              = New-Object System.Drawing.Size(70,40)
    $CancelButton.Text              = 'Cancel'
    $CancelButton.DialogResult      = [System.Windows.Forms.DialogResult]::Cancel
    $CancelButton.Font              = 'Microsoft Sans Serif,10'
    $CancelButton.BackColor         = "Cyan"
    $form.CancelButton              = $CancelButton

    $label                          = New-Object System.Windows.Forms.Label
    $label.Location                 = New-Object System.Drawing.Point(10,15)
    $label.Size                     = New-Object System.Drawing.Size(280,20)
    $label.Text                     = 'PLEASE SELECT AN APP:'
    $label.Font                     = 'Consolas,12'
    $label.ForeColor                = "Cyan"

    $form.Controls.AddRange(@($label,$CancelButton,$OKButton))

    $listBox                        = New-Object System.Windows.Forms.ListBox
    $listBox.Location               = New-Object System.Drawing.Point(10,40)
    $listBox.Size                   = New-Object System.Drawing.Size(313,20)
    $listBox.Height                 = 500
    $listBox.Font                   = New-Object System.Drawing.Font("Comic Sans MS",16,[System.Drawing.FontStyle]::Bold)

    #endregion

    #Select App
    $rokuurl = "http://" + $ip + ":8060"
    $appsweb = Invoke-WebRequest -UseBasicParsing -Uri "$rokuurl/query/apps" -method Get
    [xml]$appsxml = $appsweb.Content
    $apps = $appsxml.apps.app | select "#text",id -ExpandProperty "#text" | sort "#text"
    foreach ($app in $apps){
        [void] $listBox.Items.Add($app)
    }

    $form.Controls.Add($listBox)
    $form.Topmost = $true
    $form.ShowDialog()

    $selectedapp = $listBox.SelectedItem
    $app = $apps | Where-Object "#text" -Like $selectedapp
    $appid = $app.id | Out-String
    Invoke-WebRequest -UseBasicParsing -Uri "$rokuurl/launch/$appid" -method Post

}