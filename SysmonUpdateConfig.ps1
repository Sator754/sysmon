# v.gordiy 31/07/2023
#update Configuration System Monitor

$sysmonConfigURL = "https://raw.githubusercontent.com/Sator754/sysmon/main/sysmonconfig.xml"
$sysmonConfigPath = "C:\Programdata\Sysmon\sysmonconfig-export.xml"
$sysmonFolderPath = "C:\ProgramData\Sysmon\"


# Download Sysmon Config
Invoke-WebRequest -Uri $sysmonConfigURL -OutFile $sysmonConfigPath

# Update Sysmon Config
CD $sysmonFolderPath
sysmon64 -c $sysmonConfigPath

#update custom Active Response

$ARexeURL = "https://raw.githubusercontent.com/Sator754/sysmon/main/vh-activeresponse.exe"
$ARexePath = "C:\Program Files (x86)\ossec-agent\active-response\bin\vh-activeresponse.exe"

# Download Active Response Exe
Invoke-WebRequest -Uri $ARexeURL -OutFile $ARexePath
