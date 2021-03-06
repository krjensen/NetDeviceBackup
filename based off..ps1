## PowerShell: Script To Telnet To Remote Hosts And Run Commands Against Them With Output To A File ##
## Overview: Useful for Telnet connections to Cisco Switches and other devices. Can add additional command strings
## Usage Examples: Add your environment specific details into the parameters below, or include when calling the script:
## ./PowerShellTelnetRemoteSession.ps1 "127.0.0.1" "23" "admin" "password" "term len 0" "en" "enablepassword" "show interface"
  
param(
    #[string] $remoteHost = "172.31.0.111", 
    #[int] $port = 23,
    [string] $username = "admin",
    [string] $password = "",
    #[string] $termlength = "term len 0", #Useful for older consoles that have line display limitations
    [string] $enable = "en", #Useful for appliances like Cisco switches that have an 'enable' command mode
    [string] $enablepassword = "",
    [string] $command1 = "show run", #You can add additional commands below here with additonal strings if you want
    [string] $command2 = " ",
    [string] $command3 = " ",
    [string] $command4 = " ",
    [string] $command5 = " ",
    [int] $commandDelay = 1000
   )
  

function Main
{
    param ($ip,$port)
  ## Open the socket, and connect to the computer on the specified port
  
  Write-Host "Connecting to $ip on port $port"
 
 
  $socket = New-Object System.Net.Sockets.TcpClient($ip, $port)
   
  
  Write-Host "Connected. Press ^D followed by [ENTER] to exit.`n"
  
  $stream = $socket.GetStream()
  
  $writer = New-Object System.IO.StreamWriter $stream
  
    ## Receive the output that has buffered so far
    $SCRIPT:output += GetOutput
  
        $writer.WriteLine($username)
        $writer.Flush()
        Start-Sleep -m $commandDelay
                $writer.WriteLine($password)
        $writer.Flush()
        #Start-Sleep -m $commandDelay
                #$writer.WriteLine($termlength)
        #$writer.Flush()
        Start-Sleep -m $commandDelay
                $writer.WriteLine($enable)
        $writer.Flush()
        Start-Sleep -m $commandDelay
                $writer.WriteLine($enablepassword)
        $writer.Flush()
        Start-Sleep -m $commandDelay
                $writer.WriteLine($command1) #Add additional entries below here for additional 'strings' you created above
        $writer.Flush()
        Start-Sleep -m $commandDelay
                $writer.WriteLine($command2) #Add additional entries below here for additional 'strings' you created above
        $writer.Flush()
                Start-Sleep -m $commandDelay
                $writer.WriteLine($command3) #Add additional entries below here for additional 'strings' you created above
        $writer.Flush()
                Start-Sleep -m $commandDelay
                $writer.WriteLine($command4) #Add additional entries below here for additional 'strings' you created above
        $writer.Flush()
                Start-Sleep -m $commandDelay
                $writer.WriteLine($command5) #Add additional entries below here for additional 'strings' you created above
        $writer.Flush()
        Start-Sleep -m $commandDelay
        $SCRIPT:output += GetOutput
                 
  
  
  ## Close the streams
  $writer.Close()
  $stream.Close()
 
  #building file name
  $filename = "c:\switch\$ip - " + $timestamp + ".txt"
  
  $output | Out-File $filename  #Change this to suit your environment
}
 
#build the list of ips to be interegated 
$ips = "192.168.1.2","169.254.2.2","192.168.1.101"
 
#building a file path
$timestamp = get-date -Format g | foreach {$_ -replace ":","."}
 
#building different file paths for different functions
$errortimestamp = Get-Date -Format o | foreach {$_ -replace ":", "."}
$errorfilename = "c:\switch\" + $timestamp + " - ERROR.txt"
 
#building different file paths for different functions
$blockedtimestamp = Get-Date -Format o | foreach {$_ -replace ":", "."}
$blockedfilename = "c:\switch\" + $timestamp + " - blocked.txt"
 
#looping through each ip in ip list
foreach ($ip in $ips)
{
    Write-host "Testing $ip"
    #test to see if device is responding to pings
    if (Test-Connection $ip -Quiet)
    {
        #creating connection on port 23
        $t = New-Object Net.Sockets.TcpClient
        $t.Connect($ip, 23)
 
        #if it connects, runs the required function with the ip
        if ($t.Connected)
        {
            . Main $ip "23"
        }
        #script block for device responding to ping, but port 23 is NOT open
        else
        {
            $portblocked = "Port 23 on $ip is closed , You may need to contact your IT team to open it. "
            Add-Content $blockedfilename "`n$portblocked"
        }
    }
    #script block for NO RESPONSE
    else 
        {
        $errorfilename = "c:\switch\" + $timestamp + " - ERROR.txt" 
        Add-Content $errorfilename "`nCould not ping $ip"
        }
}
 
#displaying information on console
Write-Host "Build file list" -NoNewline
#getting file list to be emailed
$files = Get-ChildItem C:\Switch\ | Where {-NOT $_.PSIsContainer} | foreach {$_.fullname}
#pausing script
Start-Sleep 3
Write-Host "`t" [File List Built] -ForegroundColor "Green"
 
Write-Host "Sending Email" -NoNewline
 
#building checks for sending emails
 
#no error
 
#replace as needed
$to = "<to>"
$from = "<from>"
$smtpserver = "<smtpserver>"
 
try
{
    Send-MailMessage -Attachments $files -to $to -from $from -Subject "Network Config backup - $timestamp" -SmtpServer $smtpserver -ErrorAction Stop
    Write-Host "`t [Email Sent]" -ForegroundColor "Green"
}
#error
catch
{
    $ErrorMessage = $_.Exception.Message
    #$ErrorMessage
    if ($ErrorMessage -ne $null)
    {
        Write-Host "`t [Unable to send Mail]" -ForegroundColor "Red"
        Write-Host "There was an error: $ErrorMessage" -ForegroundColor "Yellow"
    }
}
 
Start-Sleep 3
Write-Host "Removing Files" -NoNewline
$files | Remove-Item
Write-Host "`t [Files removed]" -ForegroundColor "Green"