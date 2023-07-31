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
