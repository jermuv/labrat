
### tools

# Install-Module -Name PowerShellGet -Force

# download latest offline version of edge
# https://www.microsoft.com/fi-fi/edge/business/download

# http://woshub.com/install-rsat-feature-windows-10-powershell/
#region for the management tools
Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0
Add-WindowsCapability -Online -Name Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0

#########################
### region downloads ####

# wsus cab file:
# 
http://go.microsoft.com/fwlink/?linkid=74689

Start-BitsTransfer -Source http://go.microsoft.com/fwlink/?linkid=74689 -Destination "c:\wsusscn2.cab"

# edge offline install
start-bitstransfer -source http://go.microsoft.com/fwlink/?LinkID=2093437 -Destination "C:\VM\SANDBOX\INBOX\MicrosoftEdgeEnterpriseX64.msi"

#########################
### /end of region downloads ####



# ad
# https://docs.microsoft.com/en-us/powershell/module/addsadministration/new-adorganizationalunit?view=win10-ps
# new-adorganizationalunit
# new-adorganizationalunit Admin
# new-adorganizationalunit Admin -path "DC=corp,DC=Contoso,DC=com"
# new-adorganizationalunit T0 -path "OU=Admin, DC=corp,DC=Contoso,DC=com"
# new-adorganizationalunit T1 -path "OU=Admin, DC=corp,DC=Contoso,DC=com"
# new-adorganizationalunit T2 -path "OU=Admin, DC=corp,DC=Contoso,DC=com"

#region for the OU structures
{
new-adorganizationalunit Admin
new-adorganizationalunit Devices
new-adorganizationalunit T1-Services
new-adorganizationalunit UserAccounts

new-adorganizationalunit T0 -path "OU=Admin, DC=corp,DC=Contoso,DC=com"
new-adorganizationalunit T1 -path "OU=Admin, DC=corp,DC=Contoso,DC=com"
new-adorganizationalunit T2 -path "OU=Admin, DC=corp,DC=Contoso,DC=com"
}