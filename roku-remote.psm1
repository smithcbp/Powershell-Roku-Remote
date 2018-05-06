<#
.SYNOPSIS

A collection of Functions for discovering and controlling local Roku devices.
Import-Module .\roku-commands.psm1

.NOTES

Get-LocalRokus [-usearp] 
    The -usearp switch collects the Roku IPs by parsing arp -a. Compatible with Powershell 6 (on Windows)

Ip            Name                          Model                Description
--            ----                          -----                -----------
192.168.0.110 Bedroom Roku Stick           Roku Stick 3500X     Bedroom Roku Stick | 192.168.0.110
192.168.0.111 Roku Express                 Roku Express 3700X   Roku Express  | 192.168.0.111


Send-RokuCommand -ip $IP -rokucommand 'Home' (adding updown will send /keydown/$RokuCommand, wait 100ms, /keyup/$RokuCommand instead of /keypress/$RokuCommand)
    Sends the specified command to the specified roku

Send-RokuReboot -ip $IP
    Sends a command macro to the Roku navigating to "Restart System"

Get-RokuApp -ip $IP 
    Outputs all of the installed Roku apps and their corresponding IDs.

Send-RokuApp -Ip $IP ((-name "Netflix") or (-ID "12"))
    Launches the specified app.

Select-RokuApp -Ip $IP
    Launches a gui to select and launch a roku app.


Roku API https://sdkdocs.roku.com/display/sdkdoc/External+Control+API

#>

Function Get-LocalRokus {
    param(
        [switch]$usearp
        )

    if ((!$usearp) -and ($PSVersionTable.PSVersion.Major -ge 6)){
        Write-Error -Message "Powershell 6+ Detected use 'Get-LocalRokus -usearp' Instead"
        return
        }

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
$Rokus = @()
$RokuIps = @()

if($usearp -eq $True){
    $arp = arp -a
    $regex = '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'
    foreach ($item in $RokuOUIS){
        [string]$RokuArp = $arp | Select-String -Pattern $item
        $RokuIps += $Rokuarp | Select-String -Pattern $regex | % { $_.Matches } | % { $_.Value } 
    }
}

else{
    foreach($Oui in $RokuOUIS) {
        $RokuIps += Get-NetNeighbor -LinkLayerAddress $Oui*
        }
}

$Rokus = foreach ($RokuIp_Item in $RokuIps) {
    if ($usearp){$Ip = $RokuIp_Item}
    if (!$usearp){$Ip = $RokuIp_Item.IPAddress | Out-String}
    $Ip = $Ip.Trim()
    $Uri = 'http://' + $Ip + ':8060'
    $Rokuweb = (Invoke-WebRequest -UseBasicParsing $Uri)
    [xml]$RokuXML = $Rokuweb.Content
    $RokuName = $RokuXML.root.device.friendlyName
    $RokuModel = $RokuXML.root.device.modelname + ' ' + $RokuXML.root.device.modelnumber
    [pscustomobject]@{
        Ip = $Ip
        Name = $RokuName
        Model = $RokuModel
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
        [switch]
        $updown,
        [Parameter(Mandatory)]
        [string]
        $Ip
        )
    $RokuUrl = 'http://' + $Ip + ':8060'
    
    if ($updown){
        $web = Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/keydown/$RokuCommand" -method Post
        if ($web.StatusDescription -like "OK"){Write-Output "Sending $RokuCommand to $Ip,keydown"}
        Start-Sleep -Milliseconds 100
        $web = Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/keyup/$RokuCommand" -method Post 
        if ($web.StatusDescription -like "OK"){Write-Output "Sending $RokuCommand to $Ip,keyup"}
        }
    else {
        $web = Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/keypress/$RokuCommand" -method Post
        if ($web.StatusDescription -like "OK"){Write-Output "Sending $RokuCommand to $Ip"}
        }
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

Function Get-RokuApps {
    param(
    [Parameter(Mandatory)] 
    [string]
    $Ip
    )
    $RokuUrl = 'http://' + $Ip + ':8060'
    $AppsWeb = Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/query/apps" -method Get
    [xml]$Appsxml = $AppsWeb.Content
    Write-Output $Appsxml.apps.app
}

Function Get-RokuAppImage {
    param(
    [Parameter(Mandatory)] 
    [string]
    $Ip,
    [string]
    $AppId,
    [string]
    $Name,
    [Parameter(Mandatory)] 
    [string]
    $DestFile
    )

    $RokuUrl = 'http://' + $Ip + ':8060'

    if($AppId){
        if (Test-Path $DestFile) {write-verbose "$DestFile Exists Already"}
        if (!(Test-Path $DestFile)) {Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/query/icon/$Appid" -method Get -OutFile $DestFile}
    }
    if($Name){
    $appid = (get-rokuapps $Ip | Where-Object "#text" -like "$Name").id
    if (Test-Path $DestFile) {write-verbose "$DestFile Exists Already"}
    if (!(Test-Path $DestFile)) {Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/query/icon/$Appid" -method Get -OutFile $DestFile}
    }
}

Function Send-RokuApp {
    param(
    [Parameter(Mandatory)] 
    [string]
    $Ip,
    [string]
    $AppId,
    [string]
    $Name
    )
    $RokuUrl = 'http://' + $Ip + ':8060'
    if($AppId){
    Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/launch/$Appid" -method Post
    }
    if($Name){
    $appid = (get-rokuapps $Ip | Where-Object "#text" -like "$Name").id
    Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/launch/$Appid" -method Post
    }
}

Function Select-RokuApp {
    param(
    [Parameter(Mandatory)] 
    [string]
    $Ip
    )   

    if ($PSVersionTable.PSVersion.Major -ge 6){
        Write-Error -Message "This GUI based function is not compatible with PowerShell 6. Use Send-RokuApp instead."
        return
        }

#region WPF Form App Selection List
    
    $RokuName = Get-LocalRokus | Where-Object ip -Like "$ip" | select -ExpandProperty name

    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Application]::EnableVisualStyles()
    Add-Type -AssemblyName System.Drawing
    Add-Type -AssemblyName PresentationFramework
    
    #region Apps Listbox Gui
    $Form                           = New-Object System.Windows.Forms.Form
    $Form.text                      = 'Select an App'
    $Form.size                      = New-Object System.Drawing.Size(400,640)
    $Form.startposition             = 'CenterScreen'
    $Form.backcolor                 = 'MidnightBlue'
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
    $Listbox.size                   = New-Object System.Drawing.Size(360,20)
    $Listbox.height                 = 480
    $Listbox.font                   = New-Object System.Drawing.Font('Consolas','14',[System.Drawing.FontStyle]::Bold)
    $Listbox.BackColor              = 'DarkBlue'
    $Listbox.ForeColor              = 'Cyan'

    $Form.Controls.AddRange(@($Label,$Label2,$CancelButton,$OKButton,$Listbox))

    #endregion

    #Select App
    $Apps = Get-RokuApps $Ip | sort "#text"
    foreach ($App in $Apps){
        [void] $Listbox.Items.Add($App."#text")
    }

    $Form.Topmost = $true
    $Result = $Form.ShowDialog()
    if ($Result -eq 'Cancel'){Return}
    if ($Result -eq 'OK'){
        Send-RokuApp -Ip $Ip -Name $Listbox.SelectedItem
        }



#endregion
}

Function Set-RokuFavApps {
param(
    [Parameter(Mandatory)] 
    [string]
    $Ip
    )   

    if ($PSVersionTable.PSVersion.Major -ge 6){
        Write-Error -Message "This GUI based function is not compatible with PowerShell 6. Use Send-RokuApp instead."
        return
        }

#region WPF Form App Selection List
    
    $RokuName = Get-LocalRokus | Where-Object ip -Like "$ip" | select -ExpandProperty name

    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Application]::EnableVisualStyles()
    Add-Type -AssemblyName System.Drawing
    Add-Type -AssemblyName PresentationFramework
    
    #region Apps Listbox Gui
    $Form                           = New-Object System.Windows.Forms.Form
    $Form.text                      = 'Select your 4 favorite apps'
    $Form.size                      = New-Object System.Drawing.Size(400,640)
    $Form.startposition             = 'CenterScreen'
    $Form.backcolor                 = 'MidnightBlue'
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
    $Label.text                     = 'Select your 4 favorite apps'
    $Label.font                     = 'Consolas,12'
    $Label.forecolor                = 'Cyan'
    
    $Listbox                        = New-Object System.Windows.Forms.CheckedListBox
    $Listbox.location               = New-Object System.Drawing.Point(10,60)
    $Listbox.size                   = New-Object System.Drawing.Size(360,20)
    $Listbox.height                 = 480
    $Listbox.font                   = New-Object System.Drawing.Font('Consolas','14',[System.Drawing.FontStyle]::Bold)
    $Listbox.BackColor              = 'DarkBlue'
    $Listbox.ForeColor              = 'Cyan'
    $Listbox.CheckOnClick           = $True

    $Form.Controls.AddRange(@($Label,$Label2,$CancelButton,$OKButton,$Listbox))

    #endregion

    #Select App
    $Apps = Get-RokuApps $Ip | sort "#text"
    foreach ($App in $Apps){
        [void] $Listbox.Items.Add($App."#text")
    }

    $Form.Topmost = $true
    $Result = $Form.ShowDialog()
    if ($Result -eq 'Cancel'){Return}
    if ($Result -eq 'OK'){
        $favs = $Listbox.CheckedItems
        While($favs.Count -ne 4){[System.Windows.MessageBox]::Show("Please select exactly 4 apps")
                              $Result = $Form.ShowDialog()}
        Set-Content -Path "$env:TEMP/Rokufavs.txt" -Force -Value $favs
        }
    $favs = $favs | Out-String
        
#endregion
}







#Hidden Menus (some might work) Reference: https://lifehacker.com/all-the-roku-secret-commands-and-menus-in-one-graphic-1779010902

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
    
    } #Works

Function Send-RokuSecretMenu2 {
        param(
    [Parameter(Mandatory)] 
    [string]
    $Ip
    )
    Send-RokuCommand  -ip $Ip -RokuCommand 'Home'
    Start-Sleep -Seconds 3
    Send-RokuCommand  -ip $Ip -RokuCommand 'Home'
    Start-Sleep -Seconds 1
    Send-RokuCommand  -ip $Ip -RokuCommand 'Home'
    Start-Sleep -Seconds 1
    Send-RokuCommand  -ip $Ip -RokuCommand 'Home'
    Start-Sleep -Seconds 1
    Send-RokuCommand  -ip $Ip -RokuCommand 'Home'
    Start-Sleep -Seconds 1
    Send-RokuCommand  -ip $Ip -RokuCommand 'Home'
    Start-Sleep -Seconds 1
    Send-RokuCommand  -ip $Ip -RokuCommand 'Up'
    Start-Sleep -Seconds 1
    Send-RokuCommand  -ip $Ip -RokuCommand 'Right'
    Start-Sleep -Seconds 1
    Send-RokuCommand  -ip $Ip -RokuCommand 'Down'
    Start-Sleep -Seconds 1
    Send-RokuCommand  -ip $Ip -RokuCommand 'Left'
    Start-Sleep -Seconds 1
    Send-RokuCommand  -ip $Ip -RokuCommand 'Up'
    
    } #Does not work with function. Works with real remote.

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
    
    } #Does not work with function. Works with real remote.

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
    
    } #Does not work with function. Works with real remote.

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
    
    } #Does not work with function. Works with real remote.