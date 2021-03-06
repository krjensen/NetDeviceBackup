#Patrick Squire - 05/01/2013
#This script will Backup the configuration of all devices in ./backupconfig.xml

#Import SSH Powershell Module
Import-Module SSH-Sessions

#Get Params from XML Config
[xml]$xmlconfig = (Get-Content ./backupconfig.xml)

[string]$output = ""


function GetOutput
{
##Create a buffer to recieve the response

$buffer = New-Object System.Byte[] 8192
$encoding = New-Object System.Text.ASCIIEncoding

$outputBuffer = ""
$foundmore = $false

##Read all the data abilable from the streatm, writing to the output
##buffer when done

do {
	##Allow Data to buffer for a bit
	Start-Sleep -Milliseconds 1000
	
	##Read What Data is available
	$foundmore = $false
	$stream.ReadTimeout = 1000
	
	do {
	 	try{
	 		$read = $stream.Read($buffer, 0, 1024)
	 
	 		if ($read -gt 0)
				{
					$foundmore = $true
					$outputBuffer += ($encoding.GetString($buffer, 0, $read))
				}
			} catch { $foundmore = $false; $read = 0 }
		} while ($read -gt 0)
	} while ($foundmore)
		$outputBuffer
}

function Main
{
param ($IP, $port, $user, $pass, $model)

##do some magic to SSH to the server
New-SshSession -ComputerName $IP -Username $user -Password $pass

#Enter-SshSession -ComputerName $IP

Write-Host "Connected to Remote NetDevice $IP"
$sshoutput = $null

if ($model -eq "3com")
{
 $sshoutput = Invoke-SshCommand -ComputerName $IP -Command 'display current-configuration'
}

if ($model -eq "Fortigate")
{
 $sshoutput = Invoke-SshCommand -ComputerName $IP -Command 'some Fortigate diag command'
}

####Create Stream writer and write out $sshoutput stream


$xmlconfig.configuration.device
}

#build a list of all details to be passed into above methods, loop through them and wirte them one at a time