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

$FavApps = Get-Content "$env:Temp\Rokufavs.txt"

$IconName                        = 'rokuremote.ico'
$ModuleName                      = 'Roku-Remote.psm1'
$IconPath                        = Join-Path $PSScriptRoot $IconName
$ModulePath                      = Join-Path $PSScriptRoot $ModuleName

$backcolor                       = 'MidnightBlue'
$buttoncolor                     = 'Blue'
$textcolor                       = 'Cyan'



#endregion

#region Help Message
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

#endregion

#region Add required assemblies.

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
[System.Windows.Forms.Application]::EnableVisualStyles()
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") 

#endregion

#region Mouse Hover Help

$tooltip1 = New-Object System.Windows.Forms.ToolTip
 
<#
define a scriptblock to display the tooltip
add a _MouseHover event to display the corresponding tool tip
 e.g. $txtPath.add_MouseHover($ShowHelp)
 #>
$ShowHelp={
    #display popup help
    #each value is the name of a control on the form.
    
    Switch ($this.Name) {
    "HomeButton" {$tip = 'Home'}
    "BackButton" {$tip = 'Back'}
    "UpButton" {$tip = 'Up'}
    "DownButton" {$tip = 'Down'}
    "LeftButton" {$tip = 'Left'}
    "RightButton" {$tip = 'Right'}
    "SelectButton" {$tip = 'Select'}
    "ReplayButton" {$tip = 'Replay'}
    "InfoButton" {$tip = 'Info'}
    "PlayButton" {$tip = 'Play/Pause'}
    "FFButton" {$tip = 'Fast Forward'}
    "RRButton" {$tip = 'Rewind'}
    "AppsButton" {$tip = 'Launch an App'}
    "SearchButton" {$tip = 'Search'}
    "RebootButton" {$tip = 'Reboot'}
    "VoiceButton" {$tip = 'Enable Voice Recognition/Control'}
    "ChangeFavButton" {$tip = "Select New Favorites"}
    }

 $tooltip1.SetToolTip($this,$tip)

} #end ShowHelp

#endregion

#region Build GUI

$Form                            = New-Object System.Windows.Forms.Form
$Form.clientSize                 = '400,580'
$Form.text                       = 'Roku Remote'
$Form.topMost                    = $false
$Form.backcolor                  = $backcolor
$Form.icon                       = $IconPath
$Form.FormBorderStyle            = 'FixedSingle'
$Form.MaximizeBox                = $false


$Label1                          = New-Object System.Windows.Forms.Label
$Label1.text                     = 'Select Roku:'
$Label1.textalign                = 'MiddleCenter' 
$Label1.autosize                 = $true
$Label1.width                    = 25
$Label1.height                   = 10
$Label1.location                 = New-Object System.Drawing.Point(20,20)
$Label1.font                     = 'Consolas,18'
$Label1.forecolor                = $textcolor

$AddRokuButton                        = New-Object System.Windows.Forms.Button
$AddRokuButton.Name                   = 'AddRokuButton'
$AddRokuButton.text                   = 'Add by IP'
$AddRokuButton.width                  = 120
$AddRokuButton.height                 = 25
$AddRokuButton.location               = New-Object System.Drawing.Point(200,25)
$AddRokuButton.font                   = 'Microsoft Sans Serif,10'
$AddRokuButton.backcolor              = $ButtonColor
$AddRokuButton.forecolor              = $textcolor
$AddRokuButton.Add_MouseHover($ShowHelp)

$UpButton                        = New-Object System.Windows.Forms.Button
$UpButton.Name                   = 'UpButton'
$UpButton.text                   = '▲'
$UpButton.width                  = 60
$UpButton.height                 = 60
$UpButton.location               = New-Object System.Drawing.Point(171,116)
$UpButton.font                   = 'Microsoft Sans Serif,16'
$UpButton.backcolor              = $ButtonColor
$UpButton.forecolor              = $textcolor
$UpButton.Add_MouseHover($ShowHelp)

$DownButton                      = New-Object System.Windows.Forms.Button
$DownButton.Name                 = 'DownButton' 
$DownButton.text                 = '▼'
$DownButton.width                = 60
$DownButton.height               = 60
$DownButton.location             = New-Object System.Drawing.Point(171,247)
$DownButton.font                 = 'Microsoft Sans Serif,16'
$DownButton.backcolor            = $ButtonColor
$DownButton.forecolor            = $textcolor
$DownButton.Add_MouseHover($ShowHelp)

$RightButton                     = New-Object System.Windows.Forms.Button
$RightButton.Name                = 'RightButton' 
$RightButton.text                = '►'
$RightButton.width               = 60
$RightButton.height              = 60
$RightButton.location            = New-Object System.Drawing.Point(237,181)
$RightButton.font                = 'Microsoft Sans Serif,30'
$RightButton.textAlign           = 'MiddleCenter'
$RightButton.backcolor           = $ButtonColor
$RightButton.forecolor           = $textcolor
$RightButton.Add_MouseHover($ShowHelp)

$SelectButton                    = New-Object System.Windows.Forms.Button
$SelectButton.Name                 = 'SelectButton' 
$SelectButton.text               = 'OK'
$SelectButton.width              = 60
$SelectButton.height             = 60
$SelectButton.location           = New-Object System.Drawing.Point(171,181)
$SelectButton.font               = 'Microsoft Sans Serif,12'
$SelectButton.backcolor          = $ButtonColor
$SelectButton.forecolor          = $textcolor
$SelectButton.Add_MouseHover($ShowHelp)

$LeftButton                      = New-Object System.Windows.Forms.Button
$LeftButton.Name                 = 'LeftButton' 
$LeftButton.text                 = '◄'
$LeftButton.width                = 60
$LeftButton.height               = 60
$LeftButton.location             = New-Object System.Drawing.Point(105,181)
$LeftButton.backcolor            = $ButtonColor
$LeftButton.forecolor            = $textcolor
$LeftButton.font                 = 'Microsoft Sans Serif,30'
$LeftButton.Add_MouseHover($ShowHelp)

$BackButton                      = New-Object System.Windows.Forms.Button
$BackButton.Name                 = 'BackButton' 
$BackButton.text                 = 'Back'
$BackButton.width                = 80
$BackButton.height               = 50
$BackButton.location             = New-Object System.Drawing.Point(40,105)
$BackButton.font                 = 'Microsoft Sans Serif,12'
$BackButton.backcolor            = $ButtonColor
$BackButton.forecolor            = $textcolor
$BackButton.Add_MouseHover($ShowHelp)

$HomeButton                      = New-Object System.Windows.Forms.Button
$HomeButton.Name                 = 'HomeButton' 
$HomeButton.text                 = 'Home'
$HomeButton.width                = 80
$HomeButton.height               = 50
$HomeButton.location             = New-Object System.Drawing.Point(285,105)
$HomeButton.font                 = 'Microsoft Sans Serif,12'
$HomeButton.backcolor            = $ButtonColor
$HomeButton.forecolor            = $textcolor
$HomeButton.Add_MouseHover($ShowHelp)

$InfoButton                      = New-Object System.Windows.Forms.Button
$InfoButton.Name                 = 'InfoButton' 
$InfoButton.TextAlign            ='BottomCenter'
$InfoButton.text                 = "*"
$InfoButton.width                = 50
$InfoButton.height               = 50
$InfoButton.location             = New-Object System.Drawing.Point(206,313)
$InfoButton.font                 = '­­Microsoft Sans Serif,24'
$InfoButton.backcolor            = $ButtonColor
$InfoButton.forecolor            = $textcolor
$InfoButton.Add_MouseHover($ShowHelp)

$ReplayButton                      = New-Object System.Windows.Forms.Button
$ReplayButton.Name                 = 'ReplayButton'
$ReplayButton.TextAlign            ='MiddleCenter'
$ReplayButton.text                 = "®"
$ReplayButton.width                = 50
$ReplayButton.height               = 50
$ReplayButton.location             = New-Object System.Drawing.Point(146,313)
$ReplayButton.font                 = '­­Microsoft Sans Serif,16'
$ReplayButton.backcolor            = $ButtonColor
$ReplayButton.forecolor            = $textcolor
$ReplayButton.Name                 = 'ReplayButton'    
$ReplayButton.Add_MouseHover($ShowHelp)

$RRButton                        = New-Object System.Windows.Forms.Button
$RRButton.Name                 = 'RRButton' 
$RRButton.text                   = '«'
$RRButton.width                  = 50
$RRButton.height                 = 50
$RRButton.location               = New-Object System.Drawing.Point(110,370)
$RRButton.font                   = 'Microsoft Sans Serif,16'
$RRButton.backcolor              = $ButtonColor
$RRButton.forecolor              = $textcolor
$RRButton.Add_MouseHover($ShowHelp)

$PlayButton                      = New-Object System.Windows.Forms.Button
$PlayButton.Name                 = 'PlayButton' 
$PlayButton.text                 = '►'
$PlayButton.width                = 50
$PlayButton.height               = 50
$PlayButton.location             = New-Object System.Drawing.Point(176,370)
$PlayButton.font                 = 'Microsoft Sans Serif,16'
$PlayButton.backcolor            = $ButtonColor
$PlayButton.forecolor              = $textcolor
$PlayButton.Add_MouseHover($ShowHelp)

$FFButton                        = New-Object System.Windows.Forms.Button
$FFButton.Name                 = 'FFButton' 
$FFButton.text                   = '»'
$FFButton.width                  = 50
$FFButton.height                 = 50
$FFButton.location               = New-Object System.Drawing.Point(240,370)
$FFButton.font                   = 'Microsoft Sans Serif,16'
$FFButton.backcolor              = $ButtonColor
$FFButton.forecolor              = $textcolor
$FFButton.Add_MouseHover($ShowHelp)

$RebootButton                    = New-Object System.Windows.Forms.Button
$RebootButton.Name                 = 'RebootButton' 
$RebootButton.text               = 'Reboot'
$RebootButton.width              = 80
$RebootButton.height             = 50
$RebootButton.location           = New-Object System.Drawing.Point(205,430)
$RebootButton.font               = 'Microsoft Sans Serif,12'
$RebootButton.backcolor          = $ButtonColor
$RebootButton.forecolor          = $textcolor
$RebootButton.Add_MouseHover($ShowHelp)

$AppsButton                      = New-Object System.Windows.Forms.Button
$AppsButton.Name                 = 'AppsButton' 
$AppsButton.text                 = 'Apps'
$AppsButton.width                = 80
$AppsButton.height               = 50
$AppsButton.location             = New-Object System.Drawing.Point(25,430)
$AppsButton.font                 = 'Microsoft Sans Serif,12'
$AppsButton.backcolor            = $ButtonColor
$AppsButton.forecolor            = $textcolor
$AppsButton.Add_MouseHover($ShowHelp)

$RokuList                        = New-Object system.Windows.Forms.ComboBox
$RokuList.width                  = 360
$RokuList.height                 = 125
$RokuList.location               = New-Object System.Drawing.Point(20,60)
$RokuList.font                   = 'Ariel,14'
$RokuList.backcolor              = 'DarkBlue'
$RokuList.forecolor              = $textcolor
$RokuList.DisplayMember          = "Name".Trim()
$RokuList.DropDownStyle          = 'DropDownList'

$FavLabel                          = New-Object System.Windows.Forms.Label
$FavLabel.text                     = 'Favorite Apps:'
$FavLabel.textalign                = 'MiddleCenter' 
$FavLabel.autosize                 = $true
$FavLabel.width                    = 25
$FavLabel.height                   = 10
$FavLabel.location                 = New-Object System.Drawing.Point(23,485)
$FavLabel.font                     = 'Consolas,12'
$FavLabel.forecolor                = $textcolor
$FavLabel.Add_MouseHover($ShowHelp)

$ChangeFavButton                   = New-Object System.Windows.Forms.Button
$ChangeFavButton.Name              = 'ChangeFavButton' 
$ChangeFavButton.width             = 30
$ChangeFavButton.height            = 20
$ChangeFavButton.location          = New-Object System.Drawing.Point(155,488)
$ChangeFavButton.font              = 'Microsoft Sans Serif,8'
$ChangeFavButton.backcolor         = $backcolor
$ChangeFavButton.ForeColor         = $textcolor
$ChangeFavButton.Text              = 'Set'
$ChangeFavButton.Add_MouseHover($ShowHelp)

$FavButton1                      = New-Object System.Windows.Forms.Button
$FavButton1.Name                 = 'FavButton1' 
$FavButton1.width                = 80
$FavButton1.height               = 50
$FavButton1.location             = New-Object System.Drawing.Point(25,515)
$FavButton1.font                 = 'Microsoft  Sans Serif,10'
$FavButton1.backcolor              = 'Black'
$FavButton1.Add_MouseHover($ShowHelp)

$FavButton2                      = New-Object System.Windows.Forms.Button
$FavButton2.Name                 = 'FavButton2' 
$FavButton2.width                = 80
$FavButton2.height               = 50
$FavButton2.location             = New-Object System.Drawing.Point(115,515)
$FavButton2.font                 = 'Microsoft Sans Serif,10'
$FavButton2.backcolor              = 'Black'
$FavButton2.Add_MouseHover($ShowHelp)

$FavButton3                      = New-Object System.Windows.Forms.Button
$FavButton3.Name                 = 'FavButton3' 
$FavButton3.width                = 80
$FavButton3.height               = 50
$FavButton3.location             = New-Object System.Drawing.Point(205,515)
$FavButton3.font                 = 'Microsoft Sans Serif,10'
$FavButton3.backcolor              = 'Black'
$FavButton3.Add_MouseHover($ShowHelp)

$FavButton4                      = New-Object System.Windows.Forms.Button
$FavButton4.Name                 = 'FavButton4' 
$FavButton4.width                = 80
$FavButton4.height               = 50
$FavButton4.location             = New-Object System.Drawing.Point(295,515)
$FavButton4.font                 = 'Microsoft Sans Serif,10'
$FavButton4.backcolor              = 'Black'
$FavButton4.Add_MouseHover($ShowHelp)

$SearchButton                    = New-Object System.Windows.Forms.Button
$SearchButton.Name               = 'SearchButton'
$SearchButton.text               = 'Search'
$SearchButton.width              = 80
$SearchButton.height             = 50
$SearchButton.location           = New-Object System.Drawing.Point(115,430)
$SearchButton.font               = 'Microsoft Sans Serif,12'
$SearchButton.backcolor          = $ButtonColor
$SearchButton.forecolor          = $textcolor
$SearchButton.Add_MouseHover($ShowHelp)

$VoiceButton                    = New-Object System.Windows.Forms.Button
$VoiceButton.Name               = 'VoiceButton'
$VoiceButton.text               = "Voice`nControl"
$VoiceButton.width              = 80
$VoiceButton.height             = 50
$VoiceButton.location           = New-Object System.Drawing.Point(295,430)
$VoiceButton.font               = 'Microsoft Sans Serif,10'
$VoiceButton.backcolor          = $ButtonColor
$VoiceButton.forecolor          = $textcolor
$VoiceButton.Add_MouseHover($ShowHelp)

$Form.controls.AddRange(@($AddRokuButton,$UpButton,$DownButton,$RightButton,$SelectButton,$LeftButton,$BackButton,$HomeButton,$RebootButton,$AppsButton,$RokuList,$Label1,$InfoButton,$ReplayButton,$RRButton,$PlayButton,$FFButton,$FavButton1,$FavButton2,$FavButton3,$FavButton4,$FavLabel,$ChangeFavButton,$SearchButton,$VoiceButton))

#endregion

#region Import Roku-Remote.psm1 module

if (!(Test-Path $modulepath)){
    Write-Error -Message 'Please download Roku-Remote.psm1 from https://github.com/smithcbp/Powershell-Roku-Remote and place into the same folder as Roku-remote.ps1'
    Return
    }

Import-Module -Force (Resolve-Path($modulepath))

#endregion

#region GUI Events

$AddRokuButton.Add_Click({    
    $IP = [Microsoft.VisualBasic.Interaction]::InputBox("Enter IP Address:", "Add Roku by IP Address")
    $roku = add-roku -ip $IP
    if(!($roku.name)){
        Write-Error "No Roku found at $IP"
        [System.Windows.MessageBox]::Show("No Roku found at $IP","Error")
        return}
    if($roku.name){ $roku | Export-Csv -NoTypeInformation -Append -Path $env:Temp\addedrokus.csv }
    Find-Rokus
    })

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

$ReplayButton.Add_Click({   
    Send-RokuCommand -ip $RokuList.SelectedItem.IP -RokuCommand 'InstantReplay'
    })

$RRButton.Add_Click({   
    Send-RokuCommand -ip $RokuList.SelectedItem.IP -RokuCommand 'Rev'
    })

$PlayButton.Add_Click({   
    Send-RokuCommand -ip $RokuList.SelectedItem.IP -RokuCommand 'Play'
    })

$FFButton.Add_Click({  
    Send-RokuCommand -ip $RokuList.SelectedItem.IP -RokuCommand 'Fwd'
    })

$AppsButton.Add_Click({    
    Start-Job -Name 'RokuApp' -ArgumentList $RokuList.SelectedItem.IP,$ModulePath,$backcolor,$textcolor,$buttoncolor -ScriptBlock {
        Import-Module $args[1]
        Select-RokuApp -ip $args[0] -backcolor $args[2] -textcolor $args[3] -buttoncolor $args[4]
        } 
    })

$ChangeFavButton.Add_Click({
    Set-RokuFavApps -Ip $RokuList.SelectedItem.IP -backcolor $backcolor -textcolor $textcolor -buttoncolor $buttoncolor
    Set-FavAppsPics -Ip $RokuList.SelectedItem.IP
    })

$FavButton1.Add_Click({    
    $FavApps = Get-Content "$env:Temp\Rokufavs.txt"
    Send-RokuApp -Ip $RokuList.SelectedItem.IP -Name $FavApps[0]
    })

$FavButton2.Add_Click({
    $FavApps = Get-Content "$env:Temp\Rokufavs.txt"
    Send-RokuApp -Ip $RokuList.SelectedItem.IP -Name $FavApps[1]
    })

$FavButton3.Add_Click({
    $FavApps = Get-Content "$env:Temp\Rokufavs.txt"
    Send-RokuApp -Ip $RokuList.SelectedItem.IP -Name $FavApps[2]
    })

$FavButton4.Add_Click({
    $FavApps = Get-Content "$env:Temp\Rokufavs.txt"
    Send-RokuApp -Ip $RokuList.SelectedItem.IP -Name $FavApps[3]
    })

$RebootButton.Add_Click({
    Start-Job -Name 'RokuReboot' -ArgumentList $RokuList.SelectedItem.IP -ScriptBlock {
        Import-Module C:\Scripts\roku-remote\Roku-Remote.psm1
        Send-RokuReboot -ip $args[0] 
        } 
    })

$VoiceButton.Add_Click({    
    Start-Job -Name 'RokuVoiceGui' -ArgumentList $RokuList.SelectedItem.IP,$backcolor,$textcolor,$buttoncolor -ScriptBlock {
        Import-Module C:\Scripts\roku-remote\Roku-Remote.psm1
        Send-RokuVoiceGui -ip $args[0] -backcolor $args[1] -textcolor $args[2] -buttoncolor $args[3]
        } 
    })

$SearchButton.Add_Click({
    $searchquery = [Microsoft.VisualBasic.Interaction]::InputBox("Search:", "Roku Search")
    if($searchquery){Send-RokuSearch -Keyword $searchquery -Ip $RokuList.SelectedItem.Ip}
    })

#endregion

#region Keyboard Controls

## $keys = @('W','S','A','D','Space','H','B','C','I','1-4')

$form.Add_KeyDown({
    if($_.KeyCode -eq 'W'){
        Send-RokuCommand -ip $RokuList.SelectedItem.IP -RokuCommand Up
        $UpButton.backcolor              = 'Black'
        Start-Sleep -Milliseconds 200
        $UpButton.backcolor              = $ButtonColor
      }
})

$form.Add_KeyDown({
    if($_.KeyCode -eq 'S'){
        Send-RokuCommand -ip $RokuList.SelectedItem.IP -RokuCommand Down
        $DownButton.backcolor              = 'Black'
        Start-Sleep -Milliseconds 200
        $DownButton.backcolor              = $ButtonColor
      }
})

$form.Add_KeyDown({
    if($_.KeyCode -eq 'A'){
        Send-RokuCommand -ip $RokuList.SelectedItem.IP -RokuCommand Left
        $LeftButton.backcolor              = 'Black'
        Start-Sleep -Milliseconds 200
        $LeftButton.backcolor              = $ButtonColor
      }
})

$form.Add_KeyDown({
    if($_.KeyCode -eq 'D'){
        Send-RokuCommand -ip $RokuList.SelectedItem.IP -RokuCommand Right
        $RightButton.backcolor              = 'Black'
        Start-Sleep -Milliseconds 200
        $RightButton.backcolor              = $ButtonColor
      }
})

$form.Add_KeyDown({
    if($_.KeyCode -eq 'Space'){
        Send-RokuCommand -ip $RokuList.SelectedItem.IP -RokuCommand 'Select'
        $SelectButton.backcolor              = 'Black'
        Start-Sleep -Milliseconds 200
        $SelectButton.backcolor              = $ButtonColor
      }
})

$form.Add_KeyDown({
    if($_.KeyCode -eq 'H') {
        Send-RokuCommand -ip $RokuList.SelectedItem.IP -RokuCommand 'Home'
        $HomeButton.backcolor              = 'Black'
        Start-Sleep -Milliseconds 200
        $HomeButton.backcolor              = $ButtonColor
      }
})

$form.Add_KeyDown({
    if($_.KeyCode -eq 'B') {
        $BackButton.backcolor              = 'Black'
        Start-Sleep -Milliseconds 200
        $BackButton.backcolor              = $ButtonColor
        Send-RokuCommand -ip $RokuList.SelectedItem.IP -RokuCommand 'Back'
      }
})

$form.Add_KeyDown({
    if($_.KeyCode -eq 'C'){
        $AppsButton.backcolor              = 'Black'
        Start-Sleep -Milliseconds 200
        $AppsButton.backcolor              = $ButtonColor
        Select-RokuApp -ip $RokuList.SelectedItem.IP 
        }
})

$form.Add_KeyDown({
    if($_.KeyCode -eq 'I'){
        $InfoButton.backcolor              = 'Black'
        Start-Sleep -Milliseconds 200
        $InfoButton.backcolor              = $ButtonColor
        Send-RokuCommand -ip $RokuList.SelectedItem.IP -RokuCommand 'Info'
        }
})

$form.Add_KeyDown({
    if($_.KeyCode -eq 'R'){
        $InfoButton.backcolor              = 'Black'
        Start-Sleep -Milliseconds 200
        $InfoButton.backcolor              = $ButtonColor
        Send-RokuCommand -ip $RokuList.SelectedItem.IP -RokuCommand 'InstantReplay'
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
    if($_.KeyCode -eq 'V'){
    Start-Job -Name 'RokuVoice' -ArgumentList $RokuList.SelectedItem.IP -ScriptBlock {
        Import-Module C:\Scripts\roku-remote\Roku-Remote.psm1
        Send-RokuVoiceGui -ip $args[0]
            }
        }
})

$form.Add_KeyDown({
    if($_.KeyCode -eq '191'){
        [System.Windows.MessageBox]::Show("$HelpMessage","Help")
      }
})

$form.KeyPreview = $true 
#endregion

#region Find and List Rokus on Local Network

Function Find-Rokus {
$Rokus = Get-LocalRokus | Sort-Object "Name"
$Rokus += Import-Csv $env:Temp\addedrokus.csv
$Rokus = $Rokus | Sort-Object Name -Unique
$RokuList.Items.Clear()

if (!$Rokus) {  
    $RokuList.Items.Add("##### No Rokus Found! #####")
    $Rokulist.SelectedItem = $RokuList.Items[0]
    }

if ($Rokus){
    $Rokus | ForEach-Object {[void] $RokuList.Items.Add($_)}
    [void] $RokuList.Items.Add("##### Type ? for Help #####")
    $Rokulist.SelectedItem = $RokuList.Items[0]
    }

}
#endregion

Find-Rokus

#region Collect Favorite App Images

Set-FavAppsPics -IP $RokuList.SelectedItem.IP

#endregion

$Form.ShowDialog()








