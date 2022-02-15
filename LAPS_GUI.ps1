###### Only Thing That Needs Updated. Change server names to a DC in both domains and grouped button to a name that corresponds. #######
$Server1 = "foobarServer1.domain1.com"
$Domain1 = "domain1"

$Server2 = "foobarServer2.domain2.com"
$Domain2 = "domain2"

############################################## Start functions ################################################
############################################## Form Specs/Unfilled Form 
function MakeForm {
    Hide-Console #Hides powershell console, comment out if error checking.
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")  

    $Form = New-Object System.Windows.Forms.Form    
    $Form.Text = "Local Administrator Password Lookup"
    $Form.Size = New-Object System.Drawing.Size(600, 400)
    $Form.StartPosition = "CenterScreen"  

    # Form Icon 
    $Icon = New-Object system.drawing.icon ("Paomedia-Small-N-Flat-Key.ico")
    $Form.Icon = $Icon
 
    # Background Image and form size
    $BackgroundImage = [system.drawing.image]::FromFile("Cyber-Security.jpg")
    $Form.BackgroundImage = $BackgroundImage
    $Form.BackgroundImageLayout = "None"
    $Form.Width = $BackgroundImage.Width
    $Form.Height = $BackgroundImage.Height
    $Form.FormBorderStyle = 'Fixed3D'
    $Form.MaximizeBox = $false

    # Group Box where Radio buttons live
    $groupBox = New-Object System.Windows.Forms.GroupBox
    $groupBox.Location = New-Object System.Drawing.Size(270, 30) 
    $groupBox.size = New-Object System.Drawing.Size(120, 120) 
    $groupBox.text = "Domain" 
    $groupBox.BackColor = "Transparent"
    $groupBox.ForeColor = "Yellow"
    $Form.Controls.Add($groupBox) 

    # Domain 1 Radio Button
    $RadioButton1 = New-Object System.Windows.Forms.RadioButton 
    $RadioButton1.Location = new-object System.Drawing.Point(15, 15) 
    $RadioButton1.size = New-Object System.Drawing.Size(80, 20) 
    $RadioButton1.Checked = $true 
    $RadioButton1.Text = $Button1 
    $groupBox.Controls.Add($Domain1) 
    # Domain 2 Radio Button
    $RadioButton2 = New-Object System.Windows.Forms.RadioButton
    $RadioButton2.Location = new-object System.Drawing.Point(15, 45)
    $RadioButton2.size = New-Object System.Drawing.Size(80, 20)
    $RadioButton2.Text = $Button2
    $groupBox.Controls.Add($Domain2)

    # Text Box Label
    $TextLabel = New-Object System.Windows.Forms.label
    $TextLabel.Location = New-Object System.Drawing.Size(50, 30)
    $TextLabel.Size = New-Object System.Drawing.Size(130, 15)
    $TextLabel.BackColor = "Transparent"
    $TextLabel.ForeColor = "yellow"
    $TextLabel.Text = "Enter Computer Name"
    $Form.Controls.Add($TextLabel)

    # Text Box 
    $TextBox = New-Object System.Windows.Forms.TextBox
    $TextBox.Location = New-Object System.Drawing.Size(20, 50) 
    $TextBox.Size = New-Object System.Drawing.Size(180, 20) 
    $Form.Controls.Add($TextBox)

    #OutputBox Specs. This box is ungenerated until PasswordLookup function is ran
    $OutputBox = New-Object System.Windows.Forms.TextBox 
    $OutputBox.Location = New-Object System.Drawing.Size(210, 200) 
    $OutputBox.Size = New-Object System.Drawing.Size(180, 50) 
    $OutputBox.MultiLine = $True 
    $OutputBox.TextAlign = "Center"

    #OutputLabel Specs. This label is ungenerated until PasswordLookup function is ran
    $OutputLabel = New-Object System.Windows.Forms.label
    $OutputLabel.Location = New-Object System.Drawing.Size(210, 150)
    $OutputLabel.Size = New-Object System.Drawing.Size(180, 50)
    #$OutputLabel.BorderStyle = [System.Windows.Forms.FormBorderStyle]::Fixed3D
    $OutputLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter

    # Start Button
    $SearchButton = New-Object System.Windows.Forms.Button 
    $SearchButton.Location = New-Object System.Drawing.Size(400, 30) 
    $SearchButton.Size = New-Object System.Drawing.Size(110, 80) 
    $SearchButton.Text = "Search" 
    $SearchButton.BackColor = "Transparent"
    $SearchButton.ForeColor = "Yellow"
    $SearchButton.Add_Click( { PasswordLookup }) # calls PasswordLookup function
    
    $Form.Controls.Add($SearchButton) 


    # Reset Button
    $ResetButton = New-Object System.Windows.Forms.Button 
    $ResetButton.Location = New-Object System.Drawing.Size(400, 110) 
    $ResetButton.Size = New-Object System.Drawing.Size(110, 40) 
    $ResetButton.Text = "Reset Form" 
    $ResetButton.TextAlign = "MiddleCenter"
    $ResetButton.BackColor = "Red"
    $ResetButton.ForeColor = "White"
    $ResetButton.Add_Click( { ResetForm }) # calls ResetForms function
    $Form.Controls.Add($ResetButton) 

    $Form.Add_Shown( { $Form.Activate() })
    [void] $Form.ShowDialog()
}

############################################## Filled/Finished Form 
function PasswordLookup {
    if ($RadioButton1.Checked -eq $true) { $Server = $Server1 }
    if ($RadioButton2.Checked -eq $true) { $Server = $Server2 }
    $ComputerInput = $TextBox.Text
    $ComputerProperties = Get-ADComputer -Identity $ComputerInput -Server $Server -properties * | Select Name, ms-mcs-admpwd
    $Password = (Get-ADComputer -Identity $ComputerInput -Server $Server -properties *).'ms-mcs-admpwd'
    # Generates OutputLabel
    $Form.Controls.Add($OutputLabel) 
    # Generates OutputBox
    $Form.Controls.Add($outputBox) 

    # Return Output
    if ($ComputerProperties -eq $null) {
        $OutputBox.ForeColor = "red"
        $OutputBox.text = "Either a computer with this name doesn't exist in this domain or no connection to Domain Controller."
        $OutputLabel.ForeColor = "red"
        $OutputLabel.text = "ERROR"
    }
    elseif ($Password -eq $null) {
        $OutputBox.ForeColor = "red"
        $OutputBox.text = "LAPS not enabled."
        $OutputLabel.ForeColor = "red"
        $OutputLabel.text = "ERROR"
        }
    else {
        $OutputBox.text = $ComputerProperties.'ms-mcs-admpwd'
        $OutputBox.ForeColor = "black"
        $OutputLabel.Text = $ComputerProperties.Name + "'s Local Administrator Password"
        $OutputLabel.ForeColor = "black"
    }
}
############################################# Reset Form/Clear Form 
function ResetForm {
    $Form.Close()
    $Form.Dispose()
    makeForm
}
############################################## Hide/Show Powershell Console Window 
# .Net methods for hiding/showing the console in the background
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
function Show-Console {
    $consolePtr = [Console.Window]::GetConsoleWindow()

    # Hide = 0,
    # ShowNormal = 1,
    # ShowMinimized = 2,
    # ShowMaximized = 3,
    # Maximize = 3,
    # ShowNormalNoActivate = 4,
    # Show = 5,
    # Minimize = 6,
    # ShowMinNoActivate = 7,
    # ShowNoActivate = 8,
    # Restore = 9,
    # ShowDefault = 10,
    # ForceMinimized = 11

    [Console.Window]::ShowWindow($consolePtr, 4)
}

function Hide-Console {
    $consolePtr = [Console.Window]::GetConsoleWindow()
    #0 hide
    [Console.Window]::ShowWindow($consolePtr, 0)
}

############################################## end functions ################################################
### Start script
MakeForm # Calls MakeForm function

