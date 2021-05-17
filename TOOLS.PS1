Start-BitsTransfer -Source https://raw.githubusercontent.com/jermuv/labrat/master/TOOLS.PS1 -Destination "c:\temp\TOOLS.PS1"

#region azure related stuff

# connect azure AD
Connect-AzureAD -TenantId tenant id here

#endregion

#region onprem tools

#region misc download
# Install-Module -Name PowerShellGet -Force

# download latest offline version of edge
# https://www.microsoft.com/fi-fi/edge/business/download

# http://woshub.com/install-rsat-feature-windows-10-powershell/

Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0
Add-WindowsCapability -Online -Name Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0

# visual studio download site:
# https://my.visualstudio.com/downloads

# wsus cab file:
http://go.microsoft.com/fwlink/?linkid=74689

Start-BitsTransfer -Source http://go.microsoft.com/fwlink/?linkid=74689 -Destination "c:\wsusscn2.cab"

# dotnet download
Start-BitsTransfer -Source https://go.microsoft.com/fwlink/?linkid=2088631 -Destination "c:\temp\netframework48_offline.exe"

# edge offline install
start-bitstransfer -source http://go.microsoft.com/fwlink/?LinkID=2093437 -Destination "C:\temp\MicrosoftEdgeEnterpriseX64.msi"
#region mma
# mma agent download
start-bitstransfer -source https://go.microsoft.com/fwlink/?LinkId=828603 -Destination "c:\temp\MMASetup-AMD64.exe"
### https://docs.microsoft.com/en-us/azure/azure-monitor/agents/agent-windows
#endregion

#region vast related stuff

#region laps
#Download files
    #download LAPS install file x64
    Start-BitsTransfer -Source https://download.microsoft.com/download/C/7/A/C7AAD914-A8A6-4904-88A1-29E657445D03/LAPS.x64.msi -Destination "$env:UserProfile\Downloads\LAPS.x64.msi"

    #optional: download documentation
    "LAPS_TechnicalSpecification.docx","LAPS_OperationsGuide.docx" | ForEach-Object {
        Start-BitsTransfer -Source "https://download.microsoft.com/download/C/7/A/C7AAD914-A8A6-4904-88A1-29E657445D03/$_" -Destination "$env:UserProfile\Downloads\$_"
    }
 
 #region schema stuff
 Import-module AdmPwd.PS
 Update-AdmPwdADSchema
 #endregion laps schema

#region laps groups
$OUpath = "ou=t2, OU=admin, dc=jevirtan1,dc=lab"
New-ADGroup -Name LAPS_Readers -GroupScope Global -Path $OUPath
New-ADGroup -Name LAPS_Resetters -GroupScope Global -Path $OUPath
#endregion laps groups

#region blank gpo
New-Gpo -Name 'LAPS' | New-GPLink -Target $OUPath
#endregion blank gpo

#endregion laps

# misc download
#endregion

#region vast related
#Reg Add HKLM\SYSTEM\CurrentControlSet\Services\NTDS\Diagnostics /v "16 LDAP Interface Events" /t REG_DWORD /d 2
#reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL" /v "EventLogging" /t REG_DWORD /d 7 /f
#set-SmbServerConfiguration –AuditSmb1Access $true

start-bitstransfer -source https://go.microsoft.com/fwlink/?LinkId=2116849 -Destination "c:\temp\GatewayInstall.exe"

start-bitstransfer -source https://go.microsoft.com/fwlink/?LinkId=2085155 -Destination "c:\temp\netframework.exe"
start-bitstransfer -source https://go.microsoft.com/fwlink/?linkid=2088631 -Destination "c:\temp\netframework_4.8_offlineinstaller.exe"

# powerbi desktop
# https://aka.ms/pbiSingleInstaller
###start-bitstransfer -source https://www.microsoft.com/en-us/download/confirmation.aspx?id=58494 -Destination "c:\temp\PBIDesktopSetup_x64.exe"
start-bitstransfer -source https://download.microsoft.com/download/8/8/0/880BCA75-79DD-466A-927D-1ABF1F5454B0/PBIDesktopSetup_x64.exe -Destination "c:\temp\PBIDesktopSetup_x64.exe"
#endregion

# vast related
#endregion

#region scheduled tasks stuff

## Get-ScheduledTask | Get-ScheduledTaskInfo

# scheduled tasks
#endregion

#region AD onprem stuff
# ad
# https://docs.microsoft.com/en-us/powershell/module/addsadministration/new-adorganizationalunit?view=win10-ps
# new-adorganizationalunit
# new-adorganizationalunit Admin
# new-adorganizationalunit Admin -path "DC=corp,DC=Contoso,DC=com"
# new-adorganizationalunit T0 -path "OU=Admin, DC=corp,DC=Contoso,DC=com"
# new-adorganizationalunit T1 -path "OU=Admin, DC=corp,DC=Contoso,DC=com"
# new-adorganizationalunit T2 -path "OU=Admin, DC=corp,DC=Contoso,DC=com"

# ad onprem stuff
#endregion

# onprem
#endregion

#region AD content
{
    $root = (Get-ADRootDSE).rootDomainNamingContext
    new-adorganizationalunit "Admin" -Path $root
    new-adorganizationalunit "Devices" -Path $root
    new-adorganizationalunit "T1-Services" -Path $root
    new-adorganizationalunit "UserAccounts" -Path $root

    #region some sample administrative OU structures
    new-adorganizationalunit T0 -path "OU=Admin, $root"
    new-adorganizationalunit T1 -path "OU=Admin, $root"
    new-adorganizationalunit T2 -path "OU=Admin, $root"
    #endregion

    #region some sample servers and services
    new-adorganizationalunit "SQL" -Path "OU=T1-Services, $root"
    new-adorganizationalunit "FILES" -Path "OU=T1-Services, $root"
    new-adorganizationalunit "IIS" -Path "OU=T1-Services, $root"

    #endregion
}
# AD content
#endregion
#region levyn täyttämistä
$destination = "C:\OAISBUudD"
if(!(Test-Path $destination))
{
    New-Item -ItemType Directory -Force -Path $destination | Out-Null
}

#region download rubbish
start-bitstransfer -source https://go.microsoft.com/fwlink/?LinkId=2116849 -Destination "$destination\GatewayInstall.exe"
start-bitstransfer -source https://download.microsoft.com/download/8/8/0/880BCA75-79DD-466A-927D-1ABF1F5454B0/PBIDesktopSetup_x64.exe -Destination "$destination\PBIDesktopSetup_x64.exe"
start-bitstransfer -source https://go.microsoft.com/fwlink/?linkid=2088631 -Destination "$destination\netframework_4.8_offlineinstaller.exe"
start-bitstransfer -source http://go.microsoft.com/fwlink/?LinkID=2093437 -Destination "$destination\MicrosoftEdgeEnterpriseX64.msi"
start-bitstransfer -source https://go.microsoft.com/fwlink/?LinkId=828603 -Destination "$destination\MMASetup-AMD64.exe"
start-bitstransfer -source https://download.microsoft.com/download/8/5/C/85C25433-A1B0-4FFA-9429-7E023E7DA8D8/PolicyAnalyzer.zip -Destination "$destination\PolicyAnalyzer.zip"
start-bitstransfer -source https://download.microsoft.com/download/8/5/C/85C25433-A1B0-4FFA-9429-7E023E7DA8D8/Windows%2010%20Version%2020H2%20and%20Windows%20Server%20Version%2020H2%20Security%20Baseline.zip  -Destination "$destination\Windows 10 Version 20H2 and Windows Server Version 20H2 Security Baseline.zip"
start-bitstransfer -source https://download.microsoft.com/download/8/5/C/85C25433-A1B0-4FFA-9429-7E023E7DA8D8/LGPO.zip -Destination "$destination\LGPO.zip"
start-bitstransfer -source https://download.sysinternals.com/files/BGInfo.zip -Destination "$destination\BGInfo.zip"
$destination = "c:\temp"

#endregion download rubbish
#endregion


#region timezone
tzutil /l
tzutil /s "FLE Standard Time"
#endregion

#region misc dump
get-adcomputer -filter * -Properties description, name, distinguishedname, operatingsystem, lastlogon, lastlogontimestamp, pwdlastset, whencreated, whenchanged, useraccountcontrol | export-csv -path .\dumppi.csv
#endregion

#region background info
$destination = "C:\temp"
if(!(Test-Path $destination))
{
    New-Item -ItemType Directory -Force -Path $destination | Out-Null
}

start-bitstransfer -source https://download.sysinternals.com/files/BGInfo.zip -Destination "$destination\BGInfo.zip"
#endregion