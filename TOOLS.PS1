#region azure related stuff

# connect azure AD
Connect-AzureAD -TenantId <tenant id here>

#endregion

#region onprem tools

#region misc download
# Install-Module -Name PowerShellGet -Force

# download latest offline version of edge
# https://www.microsoft.com/fi-fi/edge/business/download

# http://woshub.com/install-rsat-feature-windows-10-powershell/

Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0
Add-WindowsCapability -Online -Name Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0

# wsus cab file:
http://go.microsoft.com/fwlink/?linkid=74689

Start-BitsTransfer -Source http://go.microsoft.com/fwlink/?linkid=74689 -Destination "c:\wsusscn2.cab"

# edge offline install
start-bitstransfer -source http://go.microsoft.com/fwlink/?LinkID=2093437 -Destination "C:\temp\MicrosoftEdgeEnterpriseX64.msi"

# mma agent download
start-bitstransfer -source https://go.microsoft.com/fwlink/?LinkId=828603 -Destination "c:\temp\MMASetup-AMD64.exe"
### https://docs.microsoft.com/en-us/azure/azure-monitor/agents/agent-windows

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
new-adorganizationalunit Admin
new-adorganizationalunit Devices
new-adorganizationalunit T1-Services
new-adorganizationalunit UserAccounts

new-adorganizationalunit T0 -path "OU=Admin, DC=corp,DC=Contoso,DC=com"
new-adorganizationalunit T1 -path "OU=Admin, DC=corp,DC=Contoso,DC=com"
new-adorganizationalunit T2 -path "OU=Admin, DC=corp,DC=Contoso,DC=com"
}
# AD content
#endregion