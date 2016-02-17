$session = New-PSSession -ComputerName vagrant-170766f

######################
# System Information
######################

$system_information  = Invoke-Command -Session $session -ScriptBlock {

  $OS   = Get-WmiObject -Class Win32_OperatingSystem
  $OS1  = Get-WmiObject -Class Win32_PhysicalMemory | Measure-Object -Property capacity -Sum
  $Bios = Get-WmiObject -Class Win32_BIOS
  $SerialNumber = $Bios | Select-Object -ExpandProperty serialnumber
  $CS  = Get-WmiObject -Class Win32_ComputerSystem
  $CPU = (Get-WmiObject -Class Win32_Processor)
  $drives = Get-WmiObject -Class Win32_LogicalDisk
  $OSRunning = $OS.caption + " " + $OS.OSArchitecture + " SP " + $OS.ServicePackMajorVersion
  $TotalAvailMemory = ([math]::round(($OS1.Sum / 1GB),2))

  $TotalMem = "{0:N2}" -f $TotalAvailMemory
  $date = Get-Date

  #Posh 3 directly gives date values in dd/mm/yy format. So, no need to use converttodatetime function. If you are using ISE < posh3, then use converttodatetime function.
  $uptime = $OS.ConvertToDateTime($OS.lastbootuptime)
  #$uptime = $OS.LastBootUpTime
  $BiosVersion = $Bios.Manufacturer + " " + $Bios.SMBIOSBIOSVERSION + " " + $Bios.ConvertToDateTime($Bios.Releasedate)
  #$BiosVersion = $Bios.Manufacturer + " " + $Bios.SMBIOSBIOSVERSION + " " + $Bios.Releasedate
  $CPUCount = $cpu | select name | measure | Select -ExpandProperty count
  $CPUInfo = $CPU[0].Name
  $CPUMaxSpeed = ($CPU[0].MaxClockSpeed/1000)
  $Model = $CS.Model
  $Manufacturer = $CS.Manufacturer
  $Description = $CS.Description
  $PrimaryOwnerName = $CS.PrimaryOwnerName
  $Systemtype = $CS.Systemtype

  $system_information = new-object PSCustomObject -Property @{
    Computer     = $env:computername
    Domain       = $env:userdomain
    OSRunning    = $OSRunning
    TotalMemGB   = "$TotalMem GB"
    Uptime       = $uptime
    BiosVersion  = $BiosVersion
    SerialNumber = "$SerialNumber"
    CPUInfo      = $CPUInfo
    CPUCount     = $CPUCount
    CPUMaxSpeed  = $CPUMaxSpeed
  }

  return $system_information
}

######################
# Network Info
######################

$networkinfo  = Invoke-Command -Session $session -ScriptBlock {
  $networkinfo = Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where {$_.ipenabled -eq "true" -and $_.IPAddress -ne "0.0.0.0"}
  return $networkinfo
}

$Description = $networkinfo.description
$IPAddress = $networkinfo.IPAddress
$DHCPServer = $networkinfo.dhcpserver
$DefaultIPGateway = $networkinfo.DefaultIPGateway
$DNSDomain = $networkinfo.DNSDomain
$DHCPEnabled = $networkinfo.DHCPEnabled
$MACAddress = $networkinfo.MACAddress

######################
# Firewall Config
######################

$firewall_config  = Invoke-Command -Session $session -ScriptBlock {
  $firewall_config = netsh firewall show config

  return $firewall_config
}

$firewall_config | Out-Default

######################
# Installed Programs
######################

$installed_programs = Invoke-Command -Session $session -ScriptBlock {
  $RegBase = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine,$Computer)
  $RegUninstall = $RegBase.OpenSubKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall')
  $apps = $RegUninstall.GetSubKeyNames() | ForEach-Object {
               ($RegBase.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$_")).GetValue('DisplayName')
             } | sort

  return $apps
}

$installed_programs | Out-Default

######################
# Running Processes
######################

$running_procs = Invoke-Command -Session $session -ScriptBlock {
  $running_procs = Get-Process

  return $running_procs
}

$running_procs | Out-Default


######################
# Scheduled Tasks
######################

$scheduled_tasks = Invoke-Command -Session $session -ScriptBlock {
  $schtasks = schtasks

  return $schtasks
}

$scheduled_tasks | Out-Default

######################
# Scheduled Tasks
######################

$environment_variables = Invoke-Command -Session $session -ScriptBlock {
  $environment_variables = Get-ChildItem Env:

  return $environment_variables
}

$environment_variables | Out-Default

######################
# local hosts file
######################

$local_hosts = Invoke-Command -Session $session -ScriptBlock {
  $local_hosts = (Get-Content "${env:SystemRoot}\System32\drivers\etc\hosts") -notmatch '^#|^[ /t]*$'

  return $local_hosts
}

$local_hosts | Out-Default

######################
# Administrators
######################

$local_admins = Invoke-Command -Session $session -ScriptBlock {
  $local_admins = net localgroup Administrators

  return $local_admins
}

$local_admins | Out-Default

######################
# Services
######################

$services = Invoke-Command -Session $session -ScriptBlock {
  $services = Get-Service

  return $services
}

$services | Out-Default

######################
# Drive Mappings
######################

$network_mapped_drives = Invoke-Command -Session $session -ScriptBlock {
  $network_mapped_drives = Get-WmiObject -Class Win32_MappedLogicalDisk | Select Name, ProviderName

  return $network_mapped_drives
}

$network_mapped_drives | Out-Default

######################
# Close (Remove) PSSession
######################

# Finally we want to remove the pssession
$session | Remove-PSSession
