# changed 31/07/2023 VH
# for My ITSecOps purpose


#Author: NerbalOne
#This PowerShell script will first create the Sysmon folder if it does not exist. It will then identify which OS architecture the endpoint is running and download the appropriate Sysmon version along with the Sysmon config and Sysmon Update script. It will then install Sysmon with the config and create a Scheduled Task to run hourly to update the Sysmon config.
#You may have issues while running this script on Windows Server 2012 R2 servers as it seems this server version only works with the Sysmon.exe and not the Sysmon64.exe with the newer Sysmon versions. 

# Define Sysmon URLs
$sysmon64URL = "https://live.sysinternals.com/sysmon64.exe"
$sysmonConfigURL = "https://raw.githubusercontent.com/Sator754/sysmon/main/sysmonconfig.xml"
$sysmonUpdateConfig = "https://raw.githubusercontent.com/Sator754/sysmon/main/SysmonUpdateConfig.ps1"

# Define Local Path for Sysmon File and Sysmon Config
$sysmon64Path = "C:\Programdata\Sysmon\sysmon64.exe"
$sysmonConfigPath = "C:\Programdata\Sysmon\sysmonconfig-export.xml"
$sysmonUpdatePath = "C:\Programdata\Sysmon\SysmonUpdateConfig.ps1"
$sysmonFolderPath = "C:\ProgramData\Sysmon\"

# Create Sysmon Folder if it Doesn't Exist
if (-not (Test-Path $sysmonFolderPath)) {
    # Create the Folder
    try {
        New-Item -ItemType Directory -Path $sysmonFolderPath -Force
        Write-Host "Folder created successfully at $folderPath"
    }
    catch {
        Write-Host "Error creating the folder: $_"
    }
}
else {
    Write-Host "The folder already exists at $folderPath"
}


# Download Sysmon Update Script
Invoke-WebRequest -Uri $sysmonUpdateConfig -OutFile $sysmonUpdatePath

# Download Sysmon Config
Invoke-WebRequest -Uri $sysmonConfigURL -OutFile $sysmonConfigPath

# Download Sysmon 64 bit
Invoke-WebRequest -Uri $sysmon64URL -OutFile $sysmon64Path

# Install Sysmon with Config
Start-Process -FilePath $sysmon64Path -ArgumentList "-accepteula -i $sysmonConfigPath" -NoNewWindow -Wait



# Create a New Scheduled Task
Start-Process schtasks.exe -ArgumentList '/Create /RU SYSTEM /RL HIGHEST /SC HOURLY /TN Update_Sysmon_Rules /TR "powershell.exe -ExecutionPolicy Bypass -File "C:\Programdata\Sysmon\SysmonUpdateConfig.ps1"" /f' -Wait -WindowStyle Hidden
Start-Process schtasks.exe -ArgumentList '/Run /TN Update_Sysmon_Rules' -Wait -WindowStyle Hidden

# Define Sysmon service Name Based on OS Architecture
$sysmonServiceName = "Sysmon64"

# Check if Sysmon Service Exists
try {
    $service = Get-Service -Name $sysmonServiceName -ErrorAction Stop
    Write-Output "Sysmon service exists"
} catch {
    Write-Output "Sysmon service does not exist"
}

# Check if Scheduled Task is Created Successfully
try {
    $task = Get-ScheduledTask -TaskName "Update_Sysmon_Rules" -ErrorAction Stop
    Write-Output "Scheduled task created successfully"
} catch {
    Write-Output "Scheduled task creation failed"
}




# install integration Sysmon to Wazuh for IT SecOps Endpoint protection

$SoftwareName="Wazuh_sysmon_integration"
$WazuhConfigFile = "C:\Program Files (x86)\ossec-agent\ossec.conf"


if ((Test-Path $WazuhConfigFile)) {
	write-host "File exist"
	$SEL = Select-String -Path $WazuhConfigFile -Pattern "Add Sysmon Policy monitoring Endpoint IT Security by vh"
}else{
	write-host "File not exist"
	$SEL = "not need to patch"
}


if ($SEL -eq $null)
{	write-host "Begin patch WazuhConfigFile"
	Add-Content $WazuhConfigFile ""
	Add-Content $WazuhConfigFile "<!-- Add Sysmon Policy monitoring Endpoint IT Security by vh -->"
	Add-Content $WazuhConfigFile "<ossec_config>"
	Add-Content $WazuhConfigFile "  <localfile>"
	Add-Content $WazuhConfigFile "    <location>Microsoft-Windows-Sysmon/Operational</location>"
	Add-Content $WazuhConfigFile "    <log_format>eventchannel</log_format>"
	Add-Content $WazuhConfigFile "  </localfile>"
 	Add-Content $WazuhConfigFile ""
	Add-Content $WazuhConfigFile "  <localfile>"
	Add-Content $WazuhConfigFile "    <location>Microsoft-Windows-PowerShell/Operational</location>"
	Add-Content $WazuhConfigFile "    <log_format>eventchannel</log_format>"
	Add-Content $WazuhConfigFile "  </localfile>"
	Add-Content $WazuhConfigFile "</ossec_config>"
	Add-Content $WazuhConfigFile ""
	Restart-Service -Name wazuh
}

#update custom Active Response

$ARexeURL = "https://raw.githubusercontent.com/Sator754/sysmon/main/vh-activeresponse.exe"
$ARexePath = "C:\Program Files (x86)\ossec-agent\active-response\bin\vh-activeresponse.exe"

# Download Active Response Exe
Invoke-WebRequest -Uri $ARexeURL -OutFile $ARexePath

#update RCL Files

try {
    $ARexeURL = "https://raw.githubusercontent.com/Sator754/sysmon/main/shared/win_applications_rcl.txt"
	$ARexePath = "C:\Program Files (x86)\ossec-agent\shared\win_applications_rcl.txt"
	Invoke-WebRequest -Uri $ARexeURL -OutFile $ARexePath
} catch {
    write-host "Download failed $ARexeURL"
}
try {
    $ARexeURL = "https://raw.githubusercontent.com/Sator754/sysmon/main/shared/win_malware_rcl.txt.txt"
	$ARexePath = "C:\Program Files (x86)\ossec-agent\shared\win_malware_rcl.txt"
	Invoke-WebRequest -Uri $ARexeURL -OutFile $ARexePath
} catch {
    write-host "Download failed $ARexeURL"
}




Restart-Service -Name wazuh