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

#region Variables

$IconName                        = 'rokuremote.ico'
$ModuleName                      = 'Roku-Remote.psm1'
$IconPath                        = Join-Path $PSScriptRoot $IconName
$ModulePath                      = Join-Path $PSScriptRoot $ModuleName

#Add your top 4 favorite apps here

$FavApps                         = @(
                                      'Netflix'
                                      'Hulu'
                                      'Plex'
                                      'YouTube'
                                      )

#endregion

#region Add required assemblies.

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework
[System.Windows.Forms.Application]::EnableVisualStyles()

#endregion

#region Build GUI

$Form                            = New-Object System.Windows.Forms.Form
$Form.clientSize                 = '400,510'
$Form.text                       = 'Roku Remote'
$Form.topMost                    = $false
$Form.backcolor                  = 'MidnightBlue'
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
$UpButton.location               = New-Object System.Drawing.Point(171,116)
$UpButton.font                   = 'Microsoft Sans Serif,16'
$UpButton.backcolor              = 'Blue'
$UpButton.forecolor              = 'Cyan'

$DownButton                      = New-Object System.Windows.Forms.Button
$DownButton.text                 = '▼'
$DownButton.width                = 60
$DownButton.height               = 60
$DownButton.location             = New-Object System.Drawing.Point(171,247)
$DownButton.font                 = 'Microsoft Sans Serif,16'
$DownButton.backcolor            = 'Blue'
$DownButton.forecolor            = 'Cyan'

$RightButton                     = New-Object System.Windows.Forms.Button
$RightButton.text                = '►'
$RightButton.width               = 60
$RightButton.height              = 60
$RightButton.location            = New-Object System.Drawing.Point(237,181)
$RightButton.font                = 'Microsoft Sans Serif,30'
$RightButton.textAlign           = 'MiddleCenter'
$RightButton.backcolor           = 'Blue'
$RightButton.forecolor           = 'Cyan'

$SelectButton                    = New-Object System.Windows.Forms.Button
$SelectButton.text               = 'OK'
$SelectButton.width              = 60
$SelectButton.height             = 60
$SelectButton.location           = New-Object System.Drawing.Point(171,181)
$SelectButton.font               = 'Microsoft Sans Serif,12'
$SelectButton.backcolor          = 'Blue'
$SelectButton.forecolor          = 'Cyan'

$LeftButton                      = New-Object System.Windows.Forms.Button
$LeftButton.text                 = '◄'
$LeftButton.width                = 60
$LeftButton.height               = 60
$LeftButton.location             = New-Object System.Drawing.Point(105,181)
$LeftButton.backcolor            = 'Blue'
$LeftButton.forecolor            = 'Cyan'
$LeftButton.font                 = 'Microsoft Sans Serif,30'

$BackButton                      = New-Object System.Windows.Forms.Button
$BackButton.text                 = 'Back'
$BackButton.width                = 80
$BackButton.height               = 50
$BackButton.location             = New-Object System.Drawing.Point(40,105)
$BackButton.font                 = 'Microsoft Sans Serif,12'
$BackButton.backcolor            = 'Blue'
$BackButton.forecolor            = 'Cyan'

$HomeButton                      = New-Object System.Windows.Forms.Button
$HomeButton.text                 = 'Home'
$HomeButton.width                = 80
$HomeButton.height               = 50
$HomeButton.location             = New-Object System.Drawing.Point(285,105)
$HomeButton.font                 = 'Microsoft Sans Serif,12'
$HomeButton.backcolor            = 'Blue'
$HomeButton.forecolor            = 'Cyan'

$InfoButton                      = New-Object System.Windows.Forms.Button
$InfoButton.text                 = "*"
$InfoButton.width                = 50
$InfoButton.height               = 50
$InfoButton.location             = New-Object System.Drawing.Point(176,380)
$InfoButton.font                 = 'Microsoft Sans Serif,24'
$InfoButton.backcolor            = 'Blue'
$InfoButton.forecolor            = 'Cyan'

$RRButton                        = New-Object System.Windows.Forms.Button
$RRButton.text                   = '«'
$RRButton.width                  = 50
$RRButton.height                 = 50
$RRButton.location               = New-Object System.Drawing.Point(110,320)
$RRButton.font                   = 'Microsoft Sans Serif,16'
$RRButton.backcolor              = 'Blue'
$RRButton.forecolor              = 'Cyan'

$PlayButton                      = New-Object System.Windows.Forms.Button
$PlayButton.text                 = '►'
$PlayButton.width                = 50
$PlayButton.height               = 50
$PlayButton.location             = New-Object System.Drawing.Point(176,320)
$PlayButton.font                 = 'Microsoft Sans Serif,16'
$PlayButton.backcolor            = 'Blue'
$PlayButton.forecolor              = 'Cyan'

$FFButton                        = New-Object System.Windows.Forms.Button
$FFButton.text                   = '»'
$FFButton.width                  = 50
$FFButton.height                 = 50
$FFButton.location               = New-Object System.Drawing.Point(240,320)
$FFButton.font                   = 'Microsoft Sans Serif,16'
$FFButton.backcolor              = 'Blue'
$FFButton.forecolor              = 'Cyan'

$RebootButton                    = New-Object System.Windows.Forms.Button
$RebootButton.text               = 'Reboot'
$RebootButton.width              = 100
$RebootButton.height             = 50
$RebootButton.location           = New-Object System.Drawing.Point(260,380)
$RebootButton.font               = 'Microsoft Sans Serif,12'
$RebootButton.backcolor          = 'Blue'
$RebootButton.forecolor          = 'Cyan'

$AppsButton                      = New-Object System.Windows.Forms.Button
$AppsButton.text                 = 'Apps'
$AppsButton.width                = 100
$AppsButton.height               = 50
$AppsButton.location             = New-Object System.Drawing.Point(40,380)
$AppsButton.font                 = 'Microsoft Sans Serif,12'
$AppsButton.backcolor            = 'Blue'
$AppsButton.forecolor            = 'Cyan'

$RokuList                        = New-Object system.Windows.Forms.ComboBox
$RokuList.width                  = 360
$RokuList.height                 = 125
$RokuList.location               = New-Object System.Drawing.Point(20,60)
$RokuList.font                   = 'Ariel,14'
$RokuList.backcolor              = 'DarkBlue'
$RokuList.forecolor              = 'Cyan'
$RokuList.DisplayMember          = "Name".Trim()
$RokuList.DropDownStyle          = 'DropDownList'


$FavButton1                      = New-Object System.Windows.Forms.Button
$FavButton1.width                = 80
$FavButton1.height               = 50
$FavButton1.location             = New-Object System.Drawing.Point(25,445)
$FavButton1.font                 = 'Microsoft Sans Serif,10'
$FavButton1.backcolor              = 'Black'

$FavButton2                      = New-Object System.Windows.Forms.Button
$FavButton2.width                = 80
$FavButton2.height               = 50
$FavButton2.location             = New-Object System.Drawing.Point(115,445)
$FavButton2.font                 = 'Microsoft Sans Serif,10'
$FavButton2.backcolor              = 'Black'

$FavButton3                      = New-Object System.Windows.Forms.Button
$FavButton3.width                = 80
$FavButton3.height               = 50
$FavButton3.location             = New-Object System.Drawing.Point(205,445)
$FavButton3.font                 = 'Microsoft Sans Serif,10'
$FavButton3.backcolor              = 'Black'

$FavButton4                      = New-Object System.Windows.Forms.Button
$FavButton4.width                = 80
$FavButton4.height               = 50
$FavButton4.location             = New-Object System.Drawing.Point(295,445)
$FavButton4.font                 = 'Microsoft Sans Serif,10'
$FavButton4.backcolor              = 'Black'

$Form.controls.AddRange(@($UpButton,$DownButton,$RightButton,$SelectButton,$LeftButton,$BackButton,$HomeButton,$RebootButton,$AppsButton,$RokuList,$Label1,$InfoButton,$RRButton,$PlayButton,$FFButton,$FavButton1,$FavButton2,$FavButton3,$FavButton4))

#endregion

#region Import Roku-Remote.psm1 module

if (!(Test-Path $modulepath)){
    Write-Error -Message 'Please download Roku-Remote.psm1 from https://github.com/smithcbp/Powershell-Roku-Remote and place into the same folder as Roku-remote.ps1'
    Return
    }

Import-Module -Force (Resolve-Path($modulepath))

#endregion

#region GUI Events

$UpButton.Add_Click({    
    Send-RokuCommand -ip $RokuList.SelectedItem.IP -RokuCommand 'Up'
    })

$DownButton.Add_Click({   
    Send-RokuCommand -ip $RokuList.SelectedItem.IP -RokuCommand 'Down'
    })

$RightButton.Add_Click({   
    Send-RokuCommand -ip $RokuList.SelectedItem.IP -RokuCommand 'Right'
    })

$SelectButton.Add_Click({    
    Send-RokuCommand -ip $RokuList.SelectedItem.IP -RokuCommand 'Select' 
    })

$LeftButton.Add_Click({    
    Send-RokuCommand -ip $RokuList.SelectedItem.IP -RokuCommand 'Left'
    })

$BackButton.Add_Click({        
    Send-RokuCommand -ip $RokuList.SelectedItem.IP -RokuCommand 'Back'
    })

$HomeButton.Add_Click({   
    Send-RokuCommand -ip $RokuList.SelectedItem.IP -RokuCommand 'Home'
    })

$InfoButton.Add_Click({   
    Send-RokuCommand -ip $RokuList.SelectedItem.IP -RokuCommand 'Info'
    })

$RRButton.Add_Click({   
    Send-RokuCommand -ip $RokuList.SelectedItem.IP -RokuCommand 'Rev'
    })

$PlayButton.Add_Click({   
    Send-RokuCommand -ip $RokuList.SelectedItem.IP -RokuCommand 'Play'
    })

$FFButton.Add_Click({  
    Send-RokuSelect -ip $RokuList.SelectedItem.IP -RokuCommand 'Fwd'
    })

$AppsButton.Add_Click({    
    Start-Job -ArgumentList $RokuList.SelectedItem.IP,$ModulePath -ScriptBlock {
        Import-Module $args[1]
        Select-RokuApp -ip $args[0] 
        } 
    })

$FavButton1.Add_Click({    
    Send-RokuApp -Ip $RokuList.SelectedItem.IP -Name $FavApps[0]
    })

$FavButton2.Add_Click({
    Send-RokuApp -Ip $RokuList.SelectedItem.IP -Name $FavApps[1]
    })

$FavButton3.Add_Click({
    Send-RokuApp -Ip $RokuList.SelectedItem.IP -Name $FavApps[2]
    })

$FavButton4.Add_Click({
    Send-RokuApp -Ip $RokuList.SelectedItem.IP -Name $FavApps[3]
    })

$RebootButton.Add_Click({
    Start-Job -ArgumentList $RokuList.SelectedItem.IP -ScriptBlock {
        Import-Module C:\Scripts\roku-remote\Roku-Remote.psm1
        Send-RokuReboot -ip $args[0] 
        } 
    })

#endregion

#region Keyboard Controls

$keys = @('W','S','A','D','Space','H','B','C','I','1-4')

$form.Add_KeyDown({
    if($_.KeyCode -eq 'W'){
        Send-RokuCommand -ip $RokuList.SelectedItem.IP -RokuCommand Up
        $UpButton.backcolor              = 'Black'
        Start-Sleep -Milliseconds 200
        $UpButton.backcolor              = 'Blue'
      }
})

$form.Add_KeyDown({
    if($_.KeyCode -eq 'S'){
        Send-RokuCommand -ip $RokuList.SelectedItem.IP -RokuCommand Down
        $DownButton.backcolor              = 'Black'
        Start-Sleep -Milliseconds 200
        $DownButton.backcolor              = 'Blue'
      }
})

$form.Add_KeyDown({
    if($_.KeyCode -eq 'A'){
        Send-RokuCommand -ip $RokuList.SelectedItem.IP -RokuCommand Left
        $LeftButton.backcolor              = 'Black'
        Start-Sleep -Milliseconds 200
        $LeftButton.backcolor              = 'Blue'
      }
})

$form.Add_KeyDown({
    if($_.KeyCode -eq 'D'){
        Send-RokuCommand -ip $RokuList.SelectedItem.IP -RokuCommand Right
        $RightButton.backcolor              = 'Black'
        Start-Sleep -Milliseconds 200
        $RightButton.backcolor              = 'Blue'
      }
})

$form.Add_KeyDown({
    if($_.KeyCode -eq 'Space'){
        Send-RokuCommand -ip $RokuList.SelectedItem.IP -RokuCommand 'Select'
        $SelectButton.backcolor              = 'Black'
        Start-Sleep -Milliseconds 200
        $SelectButton.backcolor              = 'Blue'
      }
})

$form.Add_KeyDown({
    if($_.KeyCode -eq 'H') {
        Send-RokuCommand -ip $RokuList.SelectedItem.IP -RokuCommand 'Home'
        $HomeButton.backcolor              = 'Black'
        Start-Sleep -Milliseconds 200
        $HomeButton.backcolor              = 'Blue'
      }
})

$form.Add_KeyDown({
    if($_.KeyCode -eq 'B') {
        $BackButton.backcolor              = 'Black'
        Start-Sleep -Milliseconds 200
        $BackButton.backcolor              = 'Blue'
        Send-RokuCommand -ip $RokuList.SelectedItem.IP -RokuCommand 'Back'
      }
})

$form.Add_KeyDown({
    if($_.KeyCode -eq 'C'){
        $AppsButton.backcolor              = 'Black'
        Start-Sleep -Milliseconds 200
        $AppsButton.backcolor              = 'Blue'
        Select-RokuApp -ip $RokuList.SelectedItem.IP 
        }
})

$form.Add_KeyDown({
    if($_.KeyCode -eq 'I'){
        $InfoButton.backcolor              = 'Black'
        Start-Sleep -Milliseconds 200
        $InfoButton.backcolor              = 'Blue'
        Send-RokuCommand -ip $RokuList.SelectedItem.IP -RokuCommand 'Info'
        }
})

$form.Add_KeyDown({
    if($_.KeyCode -eq '49'){
        $FavButton1.BackgroundImage       = $Null
        Send-RokuApp -Ip $RokuList.SelectedItem.IP -Name $FavApps[0]
        $FavButton1.BackgroundImage       = [System.Drawing.Image]::FromFile($FavButton1ImagePath)
        }
})

$form.Add_KeyDown({
    if($_.KeyCode -eq '50'){
        $FavButton2.BackgroundImage       = $Null
        Send-RokuApp -Ip $RokuList.SelectedItem.IP -Name $FavApps[1]
        $FavButton2.BackgroundImage       = [System.Drawing.Image]::FromFile($FavButton2ImagePath)
        }
})

$form.Add_KeyDown({
    if($_.KeyCode -eq '51'){
        $FavButton3.BackgroundImage       = $Null
        Send-RokuApp -Ip $RokuList.SelectedItem.IP -Name $FavApps[2]
        $FavButton3.BackgroundImage       = [System.Drawing.Image]::FromFile($FavButton3ImagePath)
        }
})

$form.Add_KeyDown({
    if($_.KeyCode -eq '52'){
        $FavButton4.BackgroundImage       = $Null
        Send-RokuApp -Ip $RokuList.SelectedItem.IP -Name $FavApps[3]
        $FavButton4.BackgroundImage       = [System.Drawing.Image]::FromFile($FavButton4ImagePath)
        }
})

$form.Add_KeyDown({
    if($_.KeyCode -eq '191'){
        $HelpMessage = "
Keyboard Shortcuts:

W  =  Up
A  =  Left
S  =  Down
D  =  Right
Space  =  Select
H  =  Home
B  =  Back
C  =  Channels (Apps)
I  =  Info (*Options)
1-4  =  Favorite Apps 1-4
Up/Down Arrow  =  Change Roku
?  =  Display this message.

Created by Chris Smith
https://github.com/smithcbp/Powershell-Roku-Remote"
        [System.Windows.MessageBox]::Show("$HelpMessage","Help")
      }
})

$form.KeyPreview = $true 
#endregion

#region Find and List Rokus on Local Network

$Rokus = Get-LocalRokus | sort "Name"

if (!$Rokus) {
    $RokuList.Items.Add("##### No Rokus Found! #####")
    $Rokulist.SelectedItem = $RokuList.Items[0]
    }

if ($Rokus){
    $Rokus | ForEach-Object {[void] $RokuList.Items.Add($_)}
    [void] $RokuList.Items.Add("##### Type ? for Help #####")
    $Rokulist.SelectedItem = $RokuList.Items[0]
    }

#endregion

#region Collect Favorite App Images

foreach ($AppName in $FavApps){
    if (!(Test-Path $env:Temp\$Appname.jpg)) {Get-RokuAppImage -Ip $Rokus[0].Ip -Name $AppName -DestFile $env:Temp\$Appname.jpg}
    }

$FavButton1ImagePath              = "$env:Temp" + "\" + $FavApps[0] + ".jpg"
$FavButton1.BackgroundImage       = [System.Drawing.Image]::FromFile($FavButton1ImagePath)
$FavButton1.BackgroundImageLayout = 'Stretch'

$FavButton2ImagePath              = "$env:Temp" + "\" + $FavApps[1] + ".jpg"
$FavButton2.BackgroundImage       = [System.Drawing.Image]::FromFile($FavButton2ImagePath)
$FavButton2.BackgroundImageLayout = 'Stretch'

$FavButton3ImagePath              = "$env:Temp" + "\" + $FavApps[2] + ".jpg"
$FavButton3.BackgroundImage       = [System.Drawing.Image]::FromFile($FavButton3ImagePath)
$FavButton3.BackgroundImageLayout = 'Stretch'

$FavButton4ImagePath              = "$env:Temp" + "\" + $FavApps[3] + ".jpg"
$FavButton4.BackgroundImage       = [System.Drawing.Image]::FromFile($FavButton4ImagePath)
$FavButton4.BackgroundImageLayout = 'Stretch'

#endregion

$Form.ShowDialog()




