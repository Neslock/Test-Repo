# Function Definitions
function Select-FileDialog
{
	param([string]$Title,[string]$Directory,[string]$Filter="All Files (*.*)|*.*")
	[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
	$objForm = New-Object System.Windows.Forms.OpenFileDialog
	$objForm.ShowHelp = $True
	$objForm.InitialDirectory = $Directory
	$objForm.Filter = $Filter
	$objForm.Title = $Title 
	$Show = $objForm.ShowDialog()
	If ($Show -eq "OK")
	{
		Return $objForm.FileName
	}
	Else
	{
		Write-Error "Operation cancelled by user."
	}
}

# Root credentials 
Clear-Host
Write-Host -foregroundcolor green "======================================================"
Write-Host "||     Enter Root Credentials..."
Write-Host -foregroundcolor green "======================================================"
$cred = Get-Credential

$filerlist = Select-FileDialog("Select text file containing filer list:")

$controllers = Get-Content $filerlist 

Clear-Host

# Loop through the physical filers
ForEach ($controller in $controllers)
{

	Write-Host -foregroundcolor green "======================================================"
	Write-Host -foregroundcolor red   "||     Connecting to " $controller
	Write-Host -foregroundcolor green "======================================================"
	Connect-NaController $controller -credential $cred

	# Check whether multistore is licensed (vfilers)
	$multistore = Get-NaLicense "multistore"
	Write-Host -foregroundcolor red "Multistore: " $multistore.IsLicensed
	
	If ($multistore.IsLicensed -eq $True)
	{
		# Loop through the vfilers on this controller
		Write-Host -foregroundcolor green "======================================================"
		Write-Host -foregroundcolor red "||     Looping vfilers...."
		Write-Host -foregroundcolor green "======================================================"
		ForEach ($vfiler in Get-NaVfiler)
		{
			$command = "vfiler run " + $vfiler + " cifs shares"
			Invoke-NaSsh $command
		}
	}
	Else
	# No vfilers, just the base filer
	{
		Write-Host -foregroundcolor red "Physical filer " $controller
		Invoke-NaSsh "cifs shares"
	}
}
