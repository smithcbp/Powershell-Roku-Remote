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

#region Non-Gui Functions

Function Get-LocalRokus {
    param(
        [switch]$usearp
    )

    if ((!$usearp) -and ($PSVersionTable.PSVersion.Major -ge 6)) {
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

    if ($usearp -eq $True) {
        $arp = arp -a
        $regex = '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'
        foreach ($item in $RokuOUIS) {
            [string]$RokuArp = $arp | Select-String -Pattern $item
            $RokuIps += $Rokuarp | Select-String -Pattern $regex | ForEach-Object { $_.Matches } | ForEach-Object { $_.Value } 
        }
    }

    else {
        foreach ($Oui in $RokuOUIS) {
            $RokuIps += Get-NetNeighbor -LinkLayerAddress $Oui*
        }
    }

    $Rokus = foreach ($RokuIp_Item in $RokuIps) {
        if ($usearp) {$Ip = $RokuIp_Item}
        if (!$usearp) {$Ip = $RokuIp_Item.IPAddress | Out-String}
        $Ip = $Ip.Trim()
        $Uri = 'http://' + $Ip + ':8060'
        $Rokuweb = (Invoke-WebRequest -UseBasicParsing $Uri)
        [xml]$RokuXML = $Rokuweb.Content
        $RokuName = $RokuXML.root.device.friendlyName
        $RokuModel = $RokuXML.root.device.modelname + ' ' + $RokuXML.root.device.modelnumber
        [pscustomobject]@{
            Ip          = $Ip
            Name        = $RokuName
            Model       = $RokuModel
            Description = $RokuName + ' | ' + $Ip
        }
    }
    Write-Output $Rokus
}

Function Add-Roku {
    param(
        [Parameter(Mandatory)] 
        [string]
        $Ip
    )

    $Ip = $Ip.Trim()
    $Uri = 'http://' + $Ip + ':8060'
    $Rokuweb = (Invoke-WebRequest -UseBasicParsing $Uri)
    [xml]$RokuXML = $Rokuweb.Content
    $RokuName = $RokuXML.root.device.friendlyName
    $RokuModel = $RokuXML.root.device.modelname + ' ' + $RokuXML.root.device.modelnumber
    [pscustomobject]@{
        Ip          = $Ip
        Name        = $RokuName
        Model       = $RokuModel
        Description = $RokuName + ' | ' + $Ip
    }

}

Function Send-RokuCommand {   
    param(       
        [Parameter(Mandatory)]  
        [ValidateSet('Home', 'Rev', 'Fwd', 'Play', 'Select', 'Left', 'Right', 'Down', 'Up', 'Back', 'InstantReplay', 'Info', 'Backspace', 'Search', 'Enter', 'FindRemote')]
        [string]
        $RokuCommand, 
        [switch]
        $updown,
        [Parameter(Mandatory)]
        [string]
        $Ip
    )
    $RokuUrl = 'http://' + $Ip + ':8060'
    
    if ($updown) {
        $web = Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/keydown/$RokuCommand" -method Post
        if ($web.StatusDescription -like "OK") {Write-Output "Sending $RokuCommand to $Ip,keydown"}
        Start-Sleep -Milliseconds 100
        $web = Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/keyup/$RokuCommand" -method Post 
        if ($web.StatusDescription -like "OK") {Write-Output "Sending $RokuCommand to $Ip,keyup"}
    }
    else {
        $web = Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/keypress/$RokuCommand" -method Post
        if ($web.StatusDescription -like "OK") {Write-Output "Sending $RokuCommand to $Ip"}
    }
}

Function Send-RokuSearch {
    param(       
        [Parameter(Mandatory)]  
        [string]
        $Keyword,
        [Parameter(Mandatory)]
        [string]
        $Ip,
        [switch]
        $launch
    )
    $RokuUrl = 'http://' + $Ip + ':8060'
    $web = Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/search/browse?keyword=$Keyword" -method Post
    if ($web.StatusDescription -like "OK") {Write-Output "Sending Roku Search $Keyword to $Ip"}
     
}

Function Start-RokuVoice {
    param(
        [Parameter(Mandatory)] 
        [string]
        $Ip
    )


    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Speech");

    ##Setup the speaker, this allows the computer to talk
    $speaker = [System.Speech.Synthesis.SpeechSynthesizer]::new();
    $speaker.SelectVoice('Microsoft Zira Desktop');

    ##Setup the Speech Recognition Engine, this allows the computer to listen
    $speechRecogEng = [System.Speech.Recognition.SpeechRecognitionEngine]::new();

    ##Setup the verbal commands hello and exit
    $grammarhome = [System.Speech.Recognition.GrammarBuilder]::new();
    $grammarback = [System.Speech.Recognition.GrammarBuilder]::new();
    $grammarup = [System.Speech.Recognition.GrammarBuilder]::new();
    $grammardown = [System.Speech.Recognition.GrammarBuilder]::new();
    $grammarleft = [System.Speech.Recognition.GrammarBuilder]::new();
    $grammarright = [System.Speech.Recognition.GrammarBuilder]::new();
    $grammarselect = [System.Speech.Recognition.GrammarBuilder]::new();
    $grammarexit = [System.Speech.Recognition.GrammarBuilder]::new();
    $grammarinfo = [System.Speech.Recognition.GrammarBuilder]::new();
    $grammarreplay = [System.Speech.Recognition.GrammarBuilder]::new();
    $grammarplay = [System.Speech.Recognition.GrammarBuilder]::new();
    $grammarpause = [System.Speech.Recognition.GrammarBuilder]::new();
    $grammarff = [System.Speech.Recognition.GrammarBuilder]::new(); 
    $grammarrw = [System.Speech.Recognition.GrammarBuilder]::new();
    $grammarhome.Append('Home');
    $grammarback.Append('Back');
    $grammarup.Append('Up');
    $grammardown.Append('Down');
    $grammarleft.Append('Left');
    $grammarright.Append('Right');
    $grammarselect.Append('Select');
    $grammarexit.Append('exit');
    $grammarinfo.Append('Info');
    $grammarreplay.Append('Replay');
    $grammarplay.Append('Play');
    $grammarpause.Append('Pause');
    $grammarff.Append('Fast Forward');
    $grammarrw.Append('Rewind');
    $speechRecogEng.LoadGrammar($grammarhome);
    $speechRecogEng.LoadGrammar($grammarback);
    $speechRecogEng.LoadGrammar($grammarup);
    $speechRecogEng.LoadGrammar($grammardown);
    $speechRecogEng.LoadGrammar($grammarleft);
    $speechRecogEng.LoadGrammar($grammarright);
    $speechRecogEng.LoadGrammar($grammarselect);
    $speechRecogEng.LoadGrammar($grammarexit);
    $speechRecogEng.LoadGrammar($grammarinfo);
    $speechRecogEng.LoadGrammar($grammarreplay);
    $speechRecogEng.LoadGrammar($grammarplay);
    $speechRecogEng.LoadGrammar($grammarpause);
    $speechRecogEng.LoadGrammar($grammarff);
    $speechRecogEng.LoadGrammar($grammarrw);

    $speechRecogEng.InitialSilenceTimeout = 15
    $speechRecogEng.SetInputToDefaultAudioDevice();
    $cmdBoolean = $false;
    $speaker.Speak("Roku Listening")

    while (!$cmdBoolean) {
        $speechRecognize = $speechRecogEng.Recognize();
        $conf = $speechRecognize.Confidence;
        $myWords = $speechRecognize.text;
        if ($myWords -match 'Home' -and [double]$conf -gt .75) {
            Send-RokuCommand -Ip $Ip -RokuCommand Home
        }
        if ($myWords -match 'Back' -and [double]$conf -gt .70) {
            Send-RokuCommand -Ip $Ip -RokuCommand Back
        }
        if ($myWords -match 'Up' -and [double]$conf -gt .50) {
            Send-RokuCommand -Ip $Ip -RokuCommand Up
        }
        if ($myWords -match 'Down' -and [double]$conf -gt .60) {
            Send-RokuCommand -Ip $Ip -RokuCommand Down
        }
        if ($myWords -match 'Left' -and [double]$conf -gt .70) {
            Send-RokuCommand -Ip $Ip -RokuCommand Left 
        }
        if ($myWords -match 'Right' -and [double]$conf -gt .70) {
            Send-RokuCommand -Ip $Ip -RokuCommand 'Right'
        }
        if ($myWords -match 'Select' -and [double]$conf -gt .70) {
            Send-RokuCommand -Ip $Ip -RokuCommand 'Select'
        } 
        if ($myWords -match 'Info' -and [double]$conf -gt .70) {
            Send-RokuCommand -Ip $Ip -RokuCommand 'Info'
        } 
        if ($myWords -match 'Replay' -and [double]$conf -gt .70) {
            Send-RokuCommand -Ip $Ip -RokuCommand 'Replay'
        } 
        if ($myWords -match 'Play' -and [double]$conf -gt .70) {
            Send-RokuCommand -Ip $Ip -RokuCommand 'Play'
        } 
        if ($myWords -match 'Pause' -and [double]$conf -gt .70) {
            Send-RokuCommand -Ip $Ip -RokuCommand 'Play'
        } 
        if ($myWords -match 'Fast Forward' -and [double]$conf -gt .70) {
            Send-RokuCommand -Ip $Ip -RokuCommand 'Fast Forward'
        } 
        if ($myWords -match 'Rewind' -and [double]$conf -gt .70) {
            Send-RokuCommand -Ip $Ip -RokuCommand 'Rewind'
        } 
    
    
    
        if ($myWords -match 'exit' -and [double]$conf -gt .70) {
            $speaker.Speak('Goodbye');
            $cmdBoolean = $true;
            Stop-Job -Name RokuVoice
            Remove-Job -Name RokuVoice
            $form.Close()
        }
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

    if ($AppId) {
        if (Test-Path $DestFile) {write-verbose "$DestFile Exists Already"}
        if (!(Test-Path $DestFile)) {Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/query/icon/$Appid" -method Get -OutFile $DestFile}
    }
    if ($Name) {
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
    if ($AppId) {
        Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/launch/$Appid" -method Post
    }
    if ($Name) {
        $appid = (get-rokuapps $Ip | Where-Object "#text" -like "$Name").id
        Invoke-WebRequest -UseBasicParsing -Uri "$RokuUrl/launch/$Appid" -method Post
    }
}

#endregion

#region GUI Functions

Function Select-RokuApp {
    param(
        [Parameter(Mandatory)] 
        [string]
        $Ip,
        [string]
        $backcolor,
        [string]
        $textcolor,
        [string]
        $buttoncolor
    )   

    if ($PSVersionTable.PSVersion.Major -ge 6) {
        Write-Error -Message "This GUI based function is not compatible with PowerShell 6. Use Send-RokuApp instead."
        return
    }

    #region WPF Form App Selection List
    
    $IconName = 'rokuremote.ico'
    $IconPath = Join-Path $PSScriptRoot $IconName

    $RokuName = Get-LocalRokus | Where-Object ip -Like "$ip" | Select-Object -ExpandProperty name

    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Application]::EnableVisualStyles()
    Add-Type -AssemblyName System.Drawing
    Add-Type -AssemblyName PresentationFramework
    
    if (!$backcolor) {$backcolor = 'MidnightBlue'}
    if (!$textcolor) {$textcolor = 'Cyan'}
    if (!$buttoncolor) {$buttoncolor = 'Blue'}

    #region Apps Listbox Gui
    $Form = New-Object System.Windows.Forms.Form
    $Form.Icon = $IconPath
    $Form.text = 'Select an App'
    $Form.clientSize = '400,530'
    $Form.startposition = 'CenterScreen'
    $Form.backcolor = $BackColor
    $Form.FormBorderStyle = 'FixedSingle'
    $Form.MaximizeBox = $false

    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.location = New-Object System.Drawing.Point(75, 470)
    $OKButton.size = New-Object System.Drawing.Size(70, 40)
    $OKButton.text = 'OK'
    $OKButton.dialogresult = [System.Windows.Forms.DialogResult]::OK
    $OKButton.font = 'Microsoft Sans Serif,12'
    $OKButton.forecolor = $textcolor
    $OKButton.backcolor = $buttoncolor
    $Form.acceptbutton = $OKButton

    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.location = New-Object System.Drawing.Point(190, 470)
    $CancelButton.size = New-Object System.Drawing.Size(70, 40)
    $CancelButton.text = 'Cancel'
    $CancelButton.dialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $CancelButton.font = 'Microsoft Sans Serif,11'
    $CancelButton.foreColor = $TextColor
    $CancelButton.backcolor = $ButtonColor
    $Form.cancelbutton = $CancelButton

    $Label = New-Object System.Windows.Forms.Label
    $Label.location = New-Object System.Drawing.Point(10, 15)
    $Label.size = New-Object System.Drawing.Size(280, 20)
    $Label.text = 'Launch which app on:'
    $Label.font = 'Consolas,12'
    $Label.forecolor = $TextColor
    
    $Label2 = New-Object System.Windows.Forms.Label
    $Label2.location = New-Object System.Drawing.Point(10, 35)
    $Label2.size = New-Object System.Drawing.Size(280, 20)
    $Label2.text = "$RokuName"
    $Label2.font = 'Consolas,12'
    $Label2.forecolor = $TextColor

    $Listbox = New-Object System.Windows.Forms.ListBox
    $Listbox.location = New-Object System.Drawing.Point(10, 60)
    $Listbox.size = New-Object System.Drawing.Size(380, 20)
    $Listbox.height = 420
    $Listbox.font = New-Object System.Drawing.Font('Consolas', '14', [System.Drawing.FontStyle]::Bold)
    $Listbox.BackColor = $backcolor
    $Listbox.ForeColor = $TextColor

    $Form.Controls.AddRange(@($Label, $Label2, $CancelButton, $OKButton, $Listbox))

    #endregion

    #Select App
    $Apps = Get-RokuApps $Ip | Sort-Object "#text"
    foreach ($App in $Apps) {
        [void] $Listbox.Items.Add($App."#text")
    }

    $Form.Topmost = $true
    $Result = $Form.ShowDialog()
    if ($Result -eq 'Cancel') {Return}
    if ($Result -eq 'OK') {
        Send-RokuApp -Ip $Ip -Name $Listbox.SelectedItem
    }

    #endregion
}

Function Set-RokuFavApps {
    param(
        [Parameter(Mandatory)] 
        [string]
        $Ip,
        [string]
        $backcolor,
        [string]
        $textcolor,
        [string]
        $buttoncolor
    )   

    if ($PSVersionTable.PSVersion.Major -ge 6) {
        Write-Error -Message "This GUI based function is not compatible with PowerShell 6."
        return
    }

    if (!$backcolor) {$backcolor = 'MidnightBlue'}
    if (!$textcolor) {$textcolor = 'Cyan'}
    if (!$buttoncolor) {$buttoncolor = 'Blue'}

    #region WPF Form App Selection List
    
    $IconName = 'rokuremote.ico'
    $IconPath = Join-Path $PSScriptRoot $IconName
    
    ###   $RokuName = Get-LocalRokus | Where-Object ip -Like "$ip" | select -ExpandProperty name

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    Add-Type -AssemblyName PresentationFramework
    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
    [System.Windows.Forms.Application]::EnableVisualStyles()
    
    #region Apps Listbox Gui
    $Form = New-Object System.Windows.Forms.Form
    $Form.Icon = $IconPath
    $Form.text = 'Select an App'
    $Form.clientSize = '400,530'
    $Form.startposition = 'CenterScreen'
    $Form.backcolor = $BackColor
    $Form.FormBorderStyle = 'FixedSingle'
    $Form.MaximizeBox = $false

    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.location = New-Object System.Drawing.Point(75, 470)
    $OKButton.size = New-Object System.Drawing.Size(70, 40)
    $OKButton.text = 'OK'
    $OKButton.dialogresult = [System.Windows.Forms.DialogResult]::OK
    $OKButton.font = 'Microsoft Sans Serif,12'
    $OKButton.forecolor = $TextColor
    $OKButton.backcolor = $ButtonColor
    $Form.acceptbutton = $OKButton

    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.location = New-Object System.Drawing.Point(190, 470)
    $CancelButton.size = New-Object System.Drawing.Size(70, 40)
    $CancelButton.text = 'Cancel'
    $CancelButton.dialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $CancelButton.font = 'Microsoft Sans Serif,11'
    $CancelButton.foreColor = $TextColor
    $CancelButton.backcolor = $ButtonColor
    $Form.cancelbutton = $CancelButton

    $Label = New-Object System.Windows.Forms.Label
    $Label.location = New-Object System.Drawing.Point(10, 15)
    $Label.size = New-Object System.Drawing.Size(280, 20)
    $Label.text = 'Select 4 favorite apps'
    $Label.font = 'Consolas,12'
    $Label.forecolor = $TextColor
    
    $Listbox = New-Object System.Windows.Forms.CheckedListBox
    $Listbox.location = New-Object System.Drawing.Point(10, 40)
    $Listbox.size = New-Object System.Drawing.Size(380, 20)
    $Listbox.height = 430
    $Listbox.font = New-Object System.Drawing.Font('Consolas', '14', [System.Drawing.FontStyle]::Bold)
    $Listbox.BackColor = $backcolor
    $Listbox.ForeColor = $TextColor
    $Listbox.CheckOnClick = $True

    $Form.Controls.AddRange(@($Label, $Label2, $CancelButton, $OKButton, $Listbox))

    #endregion

    #Select App
    $Apps = Get-RokuApps $Ip | Sort-Object "#text"
    foreach ($App in $Apps) {
        [void] $Listbox.Items.Add($App."#text")
    }

    $Form.Topmost = $true
    $Result = $Form.ShowDialog()
    if ($Result -eq 'Cancel') {Return}
    if ($Result -eq 'OK') {
        $favs = $Listbox.CheckedItems  
        While ($favs.Count -ne 4) {
            $needed = 4 - $favs.Count
            [System.Windows.MessageBox]::Show("Select $needed more apps.")
            $Result = $Form.ShowDialog()
            if ($Result -eq 'Cancel') {Return}
        }

        Set-Content -Path "$env:TEMP/Rokufavs.txt" -Force -Value $favs
    }
    $favs = $favs | Out-String
    $favs
        
    #endregion
}

Function Set-FavAppsPics {
    param(
        [Parameter(Mandatory)] 
        [string]
        $IP
    )

    $FavApps = Get-Content "$env:Temp\Rokufavs.txt"

    foreach ($AppName in $FavApps) {
        if (!(Test-Path $env:Temp\$Appname.jpg)) {
            Get-RokuAppImage -Ip $IP -Name $AppName -DestFile $env:Temp\$Appname.jpg
        }
    }

    $FavButton1ImagePath = "$env:Temp" + "\" + $FavApps[0] + ".jpg"
    $FavButton1.BackgroundImage = [System.Drawing.Image]::FromFile($FavButton1ImagePath)
    $FavButton1.BackgroundImageLayout = 'Stretch'

    $FavButton2ImagePath = "$env:Temp" + "\" + $FavApps[1] + ".jpg"
    $FavButton2.BackgroundImage = [System.Drawing.Image]::FromFile($FavButton2ImagePath)
    $FavButton2.BackgroundImageLayout = 'Stretch'

    $FavButton3ImagePath = "$env:Temp" + "\" + $FavApps[2] + ".jpg"
    $FavButton3.BackgroundImage = [System.Drawing.Image]::FromFile($FavButton3ImagePath)
    $FavButton3.BackgroundImageLayout = 'Stretch'

    $FavButton4ImagePath = "$env:Temp" + "\" + $FavApps[3] + ".jpg"
    $FavButton4.BackgroundImage = [System.Drawing.Image]::FromFile($FavButton4ImagePath)
    $FavButton4.BackgroundImageLayout = 'Stretch'

}

Function Send-RokuVoiceGui {
    
    param(
        [Parameter(Mandatory)] 
        [string]
        $Ip,
        [string]
        $backcolor,
        [string]
        $textcolor,
        [string]
        $buttoncolor
    )   

    $help = '
Voice Commands:

    Home
    Back
    Up/Down/Left/Right
    Select (OK Button)
    Info (* Button)
    Play/Pause
    Replay
    Fast Forward
    Rewind
'




    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Application]::EnableVisualStyles()

    $rokuname = Get-LocalRokus | Where-Object IP -Like $Ip | Select-Object -ExpandProperty "Name"

    if (!$backcolor) {$backcolor = 'MidnightBlue'}
    if (!$textcolor) {$textcolor = 'Cyan'}
    if (!$buttoncolor) {$buttoncolor = 'Blue'}

    $IconName = 'rokuremote.ico'
    $IconPath = Join-Path $PSScriptRoot $IconName
    $voicestatus = $null

    #region begin GUI{ 

    $Form = New-Object system.Windows.Forms.Form
    $Form.ClientSize = '260,380'
    $Form.text = $rokuname
    $Form.TopMost = $false
    $Form.TabIndexChanged
    $Form.BackColor = $BackColor
    $Form.Icon = $IconPath
    $Form.FormBorderStyle = 'FixedSingle'
    $Form.MaximizeBox = $false

    $Button1 = New-Object system.Windows.Forms.Button
    $Button1.text = "Start"
    $Button1.width = 60
    $Button1.height = 30
    $Button1.location = New-Object System.Drawing.Point(20, 80)
    $Button1.Font = 'Microsoft Sans Serif,10'
    $Button1.backcolor = $ButtonColor
    $Button1.ForeColor = $TextColor

    $Button2 = New-Object system.Windows.Forms.Button
    $Button2.text = "Stop"
    $Button2.width = 60
    $Button2.height = 30
    $Button2.location = New-Object System.Drawing.Point(90, 80)
    $Button2.Font = 'Microsoft Sans Serif,10'
    $Button2.backcolor = $ButtonColor
    $Button2.ForeColor = $TextColor

    $Button3 = New-Object system.Windows.Forms.Button
    $Button3.text = "Close"
    $Button3.width = 60
    $Button3.height = 30
    $Button3.location = New-Object System.Drawing.Point(160, 80)
    $Button3.Font = 'Microsoft Sans Serif,10'
    $Button3.backcolor = $ButtonColor
    $Button3.ForeColor = $TextColor

    $RokuNameLabel = New-Object system.Windows.Forms.Label
    $RokuNameLabel.text = "$rokuname"
    $RokuNameLabel.AutoSize = $true
    $RokuNameLabel.width = 25
    $RokuNameLabel.height = 12
    $RokuNameLabel.location = New-Object System.Drawing.Point(10, 10)
    $RokuNameLabel.Font = 'Microsoft Sans Serif,12'
    $RokuNameLabel.ForeColor = $TextColor

    $VoiceStatusLabel = New-Object system.Windows.Forms.Label
    $VoiceStatusLabel.text = "Voice Status: $voicestatus"
    $VoiceStatusLabel.AutoSize = $true
    $VoiceStatusLabel.width = 25
    $VoiceStatusLabel.height = 12
    $VoiceStatusLabel.location = New-Object System.Drawing.Point(10, 40)
    $VoiceStatusLabel.Font = 'Microsoft Sans Serif,16'
    $VoiceStatusLabel.ForeColor = $TextColor

    $HelpLabel = New-Object system.Windows.Forms.Label
    $HelpLabel.text = "$help"
    $HelpLabel.AutoSize = $true
    $HelpLabel.width = 25
    $HelpLabel.height = 12
    $HelpLabel.location = New-Object System.Drawing.Point(10, 115)
    $HelpLabel.Font = 'Microsoft Sans Serif,12'
    $HelpLabel.ForeColor = $TextColor

    $Form.controls.AddRange(@($Button1, $Button2, $RokuNameLabel, $Button3, $VoiceStatusLabel, $HelpLabel))

    #region gui events {

    $Button1.Add_Click( {
            $voicestatus = 'Starting...'
            $VoiceStatusLabel.text = "Voice Status: $voicestatus"
            Start-Job -Name RokuVoice -ArgumentList $Ip -ScriptBlock {
                Import-Module C:\Scripts\roku-remote\Roku-Remote.psm1
                Start-RokuVoice -ip $args[0]
            }
            if (Get-Job -Name RokuVoice) {
                $voicestatus = 'Listening'
                $VoiceStatusLabel.ForeColor = 'Green'
                $VoiceStatusLabel.text = "Voice Status: $voicestatus"
            }
        })

    $Button2.Add_Click( {
            Stop-Job -Name RokuVoice
            Remove-Job -Name RokuVoice
            if (!(get-job -Name RokuVoice)) {
                $voicestatus = 'Stopped'
                $VoiceStatusLabel.ForeColor = "$textcolor"
                $VoiceStatusLabel.text = "Voice Status: $voicestatus"
            }
        })

    $Button3.Add_Click( {
            Stop-Job -Name RokuVoice
            Remove-Job -Name RokuVoice
            if (!(get-job -Name RokuVoice)) {
                $voicestatus = 'Stopped'
                $VoiceStatusLabel.text = "Voice Status: $voicestatus"
                $VoiceStatusLabel.ForeColor = "$textcolor"
            }
            Stop-Job -Name RokuVoiceGui
            Remove-Job -Name RokuVoiceGui
            $Form.Close()
        })

    #endregion events }

    #endregion GUI }


    #Write your logic code here

    Start-Job -Name 'RokuVoice' -ArgumentList $Ip -ScriptBlock {
        Import-Module C:\Scripts\roku-remote\Roku-Remote.psm1
        Start-RokuVoice -ip $args[0]
    }
    if ((Get-Job -Name RokuVoice).State -like "Running") {
        $voicestatus = 'Listening'
        $VoiceStatusLabel.ForeColor = "Green"
        $VoiceStatusLabel.text = "Voice Status: $voicestatus"
    }

    [void][System.Windows.Forms.Application]::Run($form)

}

#endregion

#region Hidden Menus (some might work) Reference: https://lifehacker.com/all-the-roku-secret-commands-and-menus-in-one-graphic-1779010902

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

#endregion 