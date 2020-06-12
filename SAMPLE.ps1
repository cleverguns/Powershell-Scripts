#Load required assemblies
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

# Drawing form and controls
$Form_HelloKaPD = New-Object System.Windows.Forms.Form
    $Form_HelloKaPD.Text = "Alam Nyo ba gamit ko dito?"
    $Form_HelloKaPD.Size = New-Object System.Drawing.Size(300,180)
    $Form_HelloKaPD.FormBorderStyle = "FixedDialog"
    $Form_HelloKaPD.TopMost = $true
    $Form_HelloKaPD.MaximizeBox = $false
    $Form_HelloKaPD.MinimizeBox = $false
    $Form_HelloKaPD.ControlBox = $true
    $Form_HelloKaPD.StartPosition = "CenterScreen"
    $Form_HelloKaPD.Font = "Segoe UI"

#adding a label to the form
$label_HelloKaPD = New-Object System.Windows.Forms.Label
    $label_HelloKaPD.Location= New-Object System.Drawing.Size(15,15)
    $label_HelloKaPD.Size =New-Object System.Drawing.Size(240,32)
    $label_HelloKaPD.TextAlign = "MiddleCenter"
    $label_HelloKaPD.Text = "Hello mga Ka Programmers Developers"
    $Form_HelloKaPD.Controls.Add($label_HelloKaPD)

#adding a button to this form
$button_ClickMe = New-Object System.Windows.Forms.Button
    $button_ClickMe.Location = New-Object System.Drawing.Size(8,80)
    $button_ClickMe.Size = New-Object System.Drawing.Size(240,32)
    $button_ClickMe.TextAlign = "MiddleCenter"
    $button_ClickMe.Text= "Click mo to! Gagaling ka sa MATH"
    $button_ClickMe.Add_Click({
        $button_ClickMe.Text = "Galing no?"
        Start-Process SnippingTool.exe
    })
        $Form_HelloKaPD.Controls.Add($button_ClickMe)

#show form
$Form_HelloKaPD.Add_Shown({$Form_HelloKaPD.Activate()})
[void]$Form_HelloKaPD.ShowDialog()
    