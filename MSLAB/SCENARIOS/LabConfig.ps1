#basic config for Windows Server 2022, that creates VMs for S2D Hyperconverged scenario https://github.com/Microsoft/MSLab/tree/master/Scenarios/S2D%20Hyperconverged

$LabConfig=@{ DomainAdminName='LabAdmin'; AdminPassword='LS1setup!'; Prefix = 'MSLab-' ; DCEdition='4'; Internet=$true ; AdditionalNetworksConfig=@(); VMs=@()}
# Windows Server 2022
1..4 | ForEach-Object {$VMNames="S2D"; $LABConfig.VMs += @{ VMName = "$VMNames$_" ; Configuration = 'S2D' ; ParentVHD = 'Win2022Core_G2.vhdx'; SSDNumber = 0; SSDSize=800GB ; HDDNumber = 12; HDDSize= 4TB ; MemoryStartupBytes= 512MB }}
# Or Azure Stack HCI 21H2
#1..4 | ForEach-Object {$VMNames="AzSHCI"; $LABConfig.VMs += @{ VMName = "$VMNames$_" ; Configuration = 'S2D' ; ParentVHD = 'AzSHCI21H2_G2.vhdx'; SSDNumber = 0; SSDSize=800GB ; HDDNumber = 12; HDDSize= 4TB ; MemoryStartupBytes= 1GB }}
# Or Windows Server 2019
#1..4 | ForEach-Object {$VMNames="S2D"; $LABConfig.VMs += @{ VMName = "$VMNames$_" ; Configuration = 'S2D' ; ParentVHD = 'Win2019Core_G2.vhdx'; SSDNumber = 0; SSDSize=800GB ; HDDNumber = 12; HDDSize= 4TB ; MemoryStartupBytes= 512MB }}

### HELP ###

#If you need more help or different configuration options, ping us at jaromir.kaspar@dell.com or vlmach@microsoft.com

#region Same as above, but with more explanation
    <#
    $LabConfig=@{
        DomainAdminName="LabAdmin";                  # Used during 2_CreateParentDisks (no affect if changed after this step)
        AdminPassword="LS1setup!";                   # Used during 2_CreateParentDisks. If changed after, it will break the functionality of 3_Deploy.ps1
        Prefix = "MSLab-";                           # (Optional) All VMs and vSwitch are created with this prefix, so you can identify the lab. If not specified, Lab folder name is used
        SwitchName = "LabSwitch";                    # (Optional) Name of vSwitch
        SwitchNICs = "";                             # (Optional) Adds these NICs to vSwitch (without connecting hostOS). (example "NIC1","NIC2")
        SecureBoot=$true;                            # (Optional) Useful when testing unsigned builds (Useful for MS developers for daily builds)
        DCEdition="4";                               # 4 for DataCenter or 3 for DataCenterCore
        InstallSCVMM="No";                           # (Optional) Yes/Prereqs/SQL/ADK/No
        AdditionalNetworksInDC=$false;               # (Optional) If Additional networks should be added also to DC
        DomainNetbiosName="Corp";                    # (Optional) If set, custom domain NetBios name will be used. if not specified, Default "corp" will be used
        DomainName="Corp.contoso.com";               # (Optional) If set, custom DomainName will be used. If not specified, Default "Corp.contoso.com" will be used
        DefaultOUName="Workshop";                    # (Optional) If set, custom OU for all machines and account will be used. If not specified, default "Workshop" is created
        AllowedVLANs="1-10";                         # (Optional) Sets the list of VLANs that can be used on Management vNICs. If not specified, default "1-10" is set.
        Internet=$false;                             # (Optional) If $true, it will add external vSwitch and configure NAT in DC to provide internet (Logic explained below)
        UseHostDnsAsForwarder=$false;                # (Optional) If $true, local DNS servers will be used as DNS forwarders in DC
        CustomDnsForwarders=@("8.8.8.8","1.1.1.1");  # (Optional) If configured, script will use those servers as DNS fordwarders in DC (Defaults to 8.8.8.8 and 1.1.1.1)
        PullServerDC=$true;                          # (Optional) If $false, then DSC Pull Server will not be configured on DC
        ServerISOFolder="";                          # (Optional) If configured, script will use ISO located in this folder for Windows Server hydration (if more ISOs are present, then out-grid view is called)
        ServerMSUsFolder="";                         # (Optional) If configured, script will inject all MSU files found into server OS
        EnableGuestServiceInterface=$false;          # (Optional) If True, then Guest Services integration component will be enabled on all VMs.
        DCVMProcessorCount=2;                        # (Optional) 2 is default. If specified more/less, processorcount will be modified.
        DHCPscope="10.0.0.0";                        # (Optional) 10.0.0.0 is configured if nothing is specified. Scope has to end with .0 (like 10.10.10.0). It's always /24       
        DCVMVersion="9.0";                           # (Optional) Latest is used if nothing is specified. Make sure you use values like "8.0","8.3","9.0"
        TelemetryLevel="";                           # (Optional) If configured, script will stop prompting you for telemetry. Values are "None","Basic","Full"
        TelemetryNickname="";                        # (Optional) If configured, telemetry will be sent with NickName to correlate data to specified NickName. So when leaderboards will be published, MSLab users will be able to see their own stats
        AutoStartAfterDeploy=$false;                 # (Optional) If $false, no VM will be started; if $true or 'All' all lab VMs will be started after Deploy script; if 'DeployedOnly' only newly created VMs will be started.
        InternetVLAN="";                             # (Optional) If set, it will apply VLAN on Interent adapter connected to DC
        ManagementSubnetIDs="";                      # (Optional) If set, it will add another dhcp-enable management networks.
        Linux=$false;                                # (Optional) If set to $true, required prerequisities for building Linux images with Packer will be configured.
        LinuxAdminName="linuxadmin";                 # (Optional) If set, local user account with that name will be created in Linux image. If not, DomainAdminName will be used as a local account.
        SshKeyPath="$($env:USERPROFILE)\.ssh\id_rsa" # (Optional) If set, specified SSH key will be used to build and access Linux images.
        AutoClosePSWindows=$false;                   # (Optional) If set, the PowerShell console windows will automatically close once the script has completed successfully. Best suited for use in automated deployments.
        AutoCleanUp=$false;                          # (Optional) If set, after creating initial parent disks, files that are no longer necessary will be cleaned up. Best suited for use in automated deployments.
        AdditionalNetworksConfig=@();                # Just empty array for config below
        VMs=@();                                     # Just empty array for config below
    }

    # Specifying LabVMs
    1..4 | ForEach-Object { 
        $VMNames="S2D";                                # Here you can bulk edit name of 4 VMs created. In this case will be s2d1,s2d2,s2d3,s2d4 created
        $LABConfig.VMs += @{
            VMName = "$VMNames$_" ;
            Configuration = 'S2D' ;                    # Simple/S2D/Shared/Replica
            ParentVHD = 'Win2022Core_G2.vhdx';         # VHD Name from .\ParentDisks folder
            SSDNumber = 0;                             # Number of "SSDs" (its just simulation of SSD-like sized HDD, just bunch of smaller disks)
            SSDSize=800GB ;                            # Size of "SSDs"
            HDDNumber = 12;                            # Number of "HDDs"
            HDDSize= 4TB ;                             # Size of "HDDs"
            MemoryStartupBytes= 512MB;                 # Startup memory size
        }
    }

    #optional: (only if AdditionalNetworks are configured in $LabConfig.VMs) this is just an example. In this configuration its not needed.
    $LABConfig.AdditionalNetworksConfig += @{ 
        NetName = 'Storage1';                        # Network Name
        NetAddress='172.16.1.';                      # Network Addresses prefix. (starts with 1), therefore first VM with Additional network config will have IP 172.16.1.1
        NetVLAN='1';                                 # VLAN tagging
        Subnet='255.255.255.0'                       # Subnet Mask
    }
    $LABConfig.AdditionalNetworksConfig += @{ NetName = 'Storage2'; NetAddress='172.16.2.'; NetVLAN='2'; Subnet='255.255.255.0'}
    $LABConfig.AdditionalNetworksConfig += @{ NetName = 'Storage3'; NetAddress='172.16.3.'; NetVLAN='3'; Subnet='255.255.255.0'}

    #>
#endregion

#region $Labconfig
    <#
    DomainAdminName (Mandatory)
        Additional Domain Admin.

    Password (Mandatory)
        Specifies password for your lab. This password is used for domain admin, vmm account, sqlservice account and additional DomainAdmin... Define before running 2_CreateParentImages

    Prefix (Optional)
        Prefix for your lab. Each VM and switch will have this prefix.
        If not specified, labfolder name will be used

    SwitchName (Optional)
        If not specified, LabSwitch will be used as switch name

    Secureboot (Optional)
        $True/$False
        This enables or disables secure boot. In Microsoft we can test unsigned test builds with Secureboot off.

    DCEdition (Mandatory)
        'ServerDataCenter'/'ServerDataCenterCore'
        If you dont like GUI and you have management VM, you can select Core edition.

    InstallSCVMM * (Optional)
        'Yes'         - installs ADK, SQL and VMM
        'ADK'         - installs just ADK
        'SQL'         - installs just SQL
        'Prereqs'     - installs ADK and SQL
        'No'          - No, or anything else, nothing is installed.
            
            *requires install files in toolsVHD\SCVMM\, or it will fail. You can download all tools here:
                SQL: http://www.microsoft.com/en-us/evalcenter/evaluate-sql-server-2016
                SCVMM: http://www.microsoft.com/en-us/evalcenter/evaluate-system-center-technical-preview
                ADK: https://msdn.microsoft.com/en-us/windows/hardware/dn913721.aspx (you need to run setup and download the content. 2Meg file is not enough)

    AdditionalNetworksInDC (optional)
        If $True, networks specified in $LABConfig.AdditionalNetworksConfig will be added.

    MGMTNICsInDC (Optional)
        If nothing specified, then just 1 NIC is added in DC.
        Can be 1-8

    DomainNetbiosName (Optional)
        Domain NetBios Name. If nothing is specified, default "Corp" will be used

    DomainName (Optional)
        Domain Name. If nothing is specified, default "Corp.contoso.com" will be used

    DefaultOUName (Optional)
        Default Organization Unit Name for all computers and accounts. If nothing is specified, default "Workshop" will be used

    AllowedVLANs (Optional)
        Allowed VLANs configured on all management adapters. Accepts "1-10" or "1,2,3,4,5,6,7,8,9,10"

    Internet (Optional)
        If $True, it will configure vSwitch based on following Logic (designed to not ask you anything most of the times):
            If no vSwitch exists:
                If only one connected adapter exists, then it will create vSwitch from it.
                If more connected adapters exists, it will ask for only one
            If vSwitch named "$($labconfig.Prefix)$($labconfig.Switchname)-External" exists, it will be used (in case lab already exists)
            If only one vSwitch exists, then it will be used
            If more vSwitches exists, you will be prompted for what to use.
        It will add vNIC to DC and configure NAT with some Open DNS servers in DNS forwarder

    UseHostDnsAsForwarder (Optional)
        If $true, local DNS servers will be used as DNS forwarders in DC when Internet is enabled. 
        By default local host's DNS servers will be used as forwarders.

    CustomDnsForwarders (Optional)
        If configured, DNS servers listed will be appended to DNS forwaders list on DC's DNS server.
        If not defined at all, commonly known DNS servers will be used as a fallback:
             - Google DNS: 8.8.8.8
             - Cloudfare: 1.1.1.1
    
    DHCPscope (Optional)
        If configured, a custom DHCP scope will be used. Will always use a '/24'.
        Specify input like '10.1.0.0' or '192.168.0.0'
        If not defined at all, DHCP scope 10.0.0.0 will be used.

    PullServerDC (optional)
        If $False, Pull Server will not be setup.

    ServerISOFolder
        Example: ServerISOFolder="d:\ISO\Server2016"
        Script will try to find ISO in this folder and subfolders. If more ISOs are present, then out-grid view is called and you will be promted to select only one

    ServerMSUsFolder
        Example: ServerMSUsFolder="d:\Updates\Server2016"
        If ServerISOFolder is specified, then updates are being grabbed from ServerMSUsFolder.
        If ServerMSUsFolder is not specified, or empty, you are not asked for providing MSU files and no MSUs are applied.

    DCVMProcessorCount (optional)
        Example: DCVMProcessorCount=4
        Number of CPUs in DC.
        If not specified, 2 vCPUs will be set. If specified more/less, processorcount will be modified. If more vCPUs specified than available in host, the maximum possible number will be configured.

    EnableGuestServiceInterface (optional)
        Example: EnableGuestServiceInterface=$true
        If True, then Guest Services integration component will be enabled on all VMs. This allows simple file copy from host to guests.

    DCVMVersion
        Example: DCVMVersion="8.0" (optional)
        If set, version for DC will be used. It is useful if you want to keep DC older to be able to use it on previous versions of OS.

    TelemetryLevel (optional)
        Example: TelemetryLevel="Full"
        If set, scripts will not prompt for telemetry. Can be "None","Basic","Full"
        For more info see https://aka.ms/mslab/telemetry

    TelemetryNickname (optional)
        Example: TelemetryNickname="Jaromirk"
        If configured, telemetry will be sent with NickName to correlate data to specified NickName. So when leaderboards will be published, MSLab users will be able to see their own stats

    ManagementSubnetIDs
        Example: ManagementSubnetIDs=0..3
        If configured, it will add another management subnet. For example if configured 0..3, it will add 3 more subnets 10.0.1.0/24 to 10.0.3.0/24 on VLANs that 11,12, and 13. (Because allowed VLANs are 1-10)
    
    Linux (optional)
        Example: Linux=$true
        If set to $true, additional prerequisities (SSH Client, SSH Key, Packer, Packer templates) required for building Linux images will be downloaded and configured.
    
    LinuxAdminName (optional)
        Example: LinuxAdminName="linuxadmin"
        If set, local user account with that name will be created in Linux image. If not, DomainAdminName will be used as a local account.

    SshKeyPath (optional)
        Example: SshKeyPath="$($env:USERPROFILE)\.ssh\id_rsa"
        If configured, existing SSH key will be used for building and connecting to Linux images. If not, 0_Prereq.ps1 will generate a new SSH key pair and store it locally in LAB folder.

    AutoStartAfterDeploy (optional)
        Example: AutoClosePSWindows=$true
        If set to true, the PowerShell console windows will automatically close once the script has completed successfully. Best suited for use in automated deployments.

    AutoCleanup (optional)
        Example: AutoCleanUp=$true
        If set to true, after creating initial parent disks, files that are no longer necessary will be cleaned up. Best suited for use in automated deployments.

    #>
#endregion

#region $LabConfig.VMs
    <#
    Example
        Single:
        $LABConfig.VMs += @{ VMName = 'Management' ; Configuration = 'Simple'   ; ParentVHD = 'Win10_G2.vhdx'    ; MemoryStartupBytes= 1GB ; AddToolsVHD=$True }
        Multiple:
        1..2 | ForEach-Object { $VMNames="Replica" ; $LABConfig.VMs += @{ VMName = "$VMNames$_" ; Configuration = 'Replica'  ; ParentVHD = 'Win2016NanoHV_G2.vhdx'   ; ReplicaHDDSize = 20GB ; ReplicaLogSize = 10GB ; MemoryStartupBytes= 2GB ; VMSet= 'ReplicaSet1' ; AdditionalNetworks = $True} }
    
    VMName (Mandatory)
        Can be whatever. This name will be used as name to djoin VM.

    Configuration (Mandatory)
        'Simple' - No local storage. Just VM
        'S2D' - locally attached SSDS and HDDs. For Storage Spaces Direct. You can specify 0 for SSDnumber or HDD number if you want only one tier.
        'Shared' - Shared VHDS attached to all nodes. Simulates traditional approach with shared space/shared storage. Requires Shared VHD->Requires Clustering Components
        'Replica' - 2 Shared disks, first for Data, second for Log. Simulates traditional storage. Requires Shared VHD->Requires Clustering Components

    VMSet (Mandatory for Shared and Replica configuration)
        This is unique name for your set of VMs. You need to specify it for Spaces and Replica scenario, so script will connect shared disks to the same VMSet.

    ParentVHD (Mandatory)
        'Win2016Core_G2.vhdx'     - Windows Server 2016 Core
        'Win2016NanoHV_G2.vhdx'    - Windows Server 2016 Nano with these packages: DSC, Failover Cluster, Guest, Storage, SCVMM
        'Win2016NanoHV_G2.vhdx'   - Windows Server 2016 Nano with these packages: DSC, Failover Cluster, Guest, Storage, SCVMM, Compute, SCVMM Compute
        'Win10_G2.vhdx'        - Windows 10 if you selected to hydrate it with create client parent.

    AdditionalNetworks (Optional)
        $True - Additional networks (configured in AdditonalNetworkConfig) are added 

    AdditionalNetworkAdapters (Optional) - Hashtable or array if multiple network adapters should be connected to this virtual machine
        @{
            VirtualSwitchName  (Mandatory) - Name of the Hyper-V Switch to witch the adapter will be connected
            Mac                (Optional)  - Static MAC address of the interface otherwise default will be generated
            VlanId             (Optional)  - VLAN ID for this adapter
            IpConfiguration    (Optional)  - DHCP or hastable with specific IP configuration
            @{
                IpAddress      (Mandatory) - Static IP Address that would be injected to the OS
                Subnet         (Mandatory) 
            }
        }

    DSCMode (Optional)
        If 'Pull', VMs will be configured to Pull config from DC.

    Config
        You can specify random Config names to identify configuration that should be pulled from pull server

    NestedVirt (Optional)
        If $True, nested virt is enabled
        Enables -ExposeVirtualizationExtensions $true

    MemoryStartupBytes (Mandatory)
        Example: 512MB
        Startup memory bytes

    MemoryMinimumBytes (Optional)
        Example: 1GB
        Minimum memory bytes, must be less or equal to MemoryStartupBytes
        If not set, default is used.    

    StaticMemory (Optional)
        if $True, then static memory is configured

    AddToolsVHD (Optional)
        If $True, then ToolsVHD will be added

    Unattend
        Example: Unattend="DjoinCred"
        Possible values: "DjoinBlob", "DjoinCred", "NoDjoin", "None"
        Default "DjoinBlob"
        "DjoinBlob" uses blob, can be consumed only by Windows Server 2016+
        "DjoinCred" uses credentials. Can be used in 2008+
        "NoDjoin" inserts just local admin. For win10 use also AdditionalLocalAdmin
        "None" does not inject any unattend.

    LinuxDomainJoin
        Example: LinuxDomainJoin="No"
        Possible values: "No", "SSSD"
        Default: SSSD
          "No" VM will be just renamed, but not joined to Active Directory
          "SSSD" VM will be joined to domain online using SSSD tool

    SkipDjoin (Optional,Deprecated)
        If $True, VM will not be djoined. Default unattend used.
        Note: you might want to use AdditionalLocalAdmin variable with Windows 10 as local administrator account is by default disabled there.

    Win2012Djoin (Optional,Deprecated)
        If $True, older way to domain join will be used (Username and Password in Answer File instead of blob) as Djoin Blob works only in Win 2016

    vTPM (Optional)
        if $true, vTPM will be enabled for virtual machine. Gen2 only.

    MGMTNICs (Optional)
        Number of management NIC.
        Default is 2, maximum 8.

    DisableWCF (Optional)
        If $True, then Disable Windows Consumer Features registry is added= no consumer apps in start menu.

    AdditionalLocalAdmin (Optional, only applies if Unattend="NoDjoin")
        Example AdditionalLocalAdmin='Ned'
        Works only with SkipDjoin as you usually don't need additional local account
        When you skipDjoin on Windows10 and local administrator is disabled. Then AdditionalLocalAdmin is useful

    VMProcessorCount (Optional)
        Example VMProcessorCount=8
        Number of Processors in VM. If specified more than available in host, maximum possible number will be used.
        If "Max" is specified, maximum number of VCPUs will be used (determined from host where mslab is running)

    Generation (Optional)
        Example Generation=1
        If not specified, then it's 2. If 1, then its 1. Easy.

    EnableWinRM (Optional)
        Example EnableWinRM=$True
        If $true, then synchronous command winrm quickconfig -force -q will be run
        Only useful for 2008 and Win10

    CustomPowerShellCommands (Optional)
        Example (single command) CustomPowerShellCommands="New-Item -Name Temp -Path c:\ -ItemType Directory"
        Example (multiple commands) CustomPowerShellCommands="New-Item -Name Temp -Path c:\ -ItemType Directory","New-Item -Name Temp1 -Path c:\ -ItemType Directory"

    ManagementSubnetID (Optional)
        This will set Management NICs to defined subnet id by configuring native VLAN ID. Default is 0. If configured to 1, it will increase highest allowed VLAN by one and configure.
        For example ManagementSubnetID=1, AllowedVlans=10, then ManagementSubnetID VLAN will be configured 11. 

    #DisableTimeIC (Optional)
        Example DisableTimeIC=$true
        if $true, time Hyper-V Time Synchronization Integration Service (VMICTimeProvider) will be disabled
    #>
#endregion

#region $LabConfig.AdditionalNetworksConfig
    <#
    Example: $LABConfig.AdditionalNetworksConfig += @{ NetName = 'Storage1'; NetAddress='172.16.1.'; NetVLAN='1'; Subnet='255.255.255.0'}

    NetName
        Name of network adapter (visible from host)

    NetAddress
        Network prefix of IP address thats injected into the VM. IP Starts with 1.

    NetVLAN
        Will tag VLAN. If 0, vlan tagging will be skipped.

    Subnet
        Subnet of network.
    #>
#endregion

#region $LabConfig.VMs Examples
    <#
    Just some VMs
        $LabConfig.VMs = @(
            @{ VMName = 'Simple1'  ; Configuration = 'Simple'   ; ParentVHD = 'Win2016NanoHV_G2.vhdx'     ; MemoryStartupBytes= 512MB }, 
            @{ VMName = 'Simple2'  ; Configuration = 'Simple'   ; ParentVHD = 'Win2016NanoHV_G2.vhdx'     ; MemoryStartupBytes= 512MB }, 
            @{ VMName = 'Simple3'  ; Configuration = 'Simple'   ; ParentVHD = 'Win2016NanoHV_G2.vhdx'     ; MemoryStartupBytes= 512MB }, 
            @{ VMName = 'Simple4'  ; Configuration = 'Simple'   ; ParentVHD = 'Win2016NanoHV_G2.vhdx'     ; MemoryStartupBytes= 512MB }
        )

    or you can use this to deploy 100 simple VMs with name NanoServer1, NanoServer2...
        1..100 | ForEach-Object {"NanoServer$_"}  | ForEach-Object { $LabConfig.VMs += @{ VMName = $_ ; Configuration = 'Simple'   ; ParentVHD = 'Win2016NanoHV_G2.vhdx'    ; MemoryStartupBytes= 512MB } }

    or you can use this to deploy 100 server VMs with 1 Client OS with name Windows10
        1..100 | ForEach-Object {"NanoServer$_"}  | ForEach-Object { $LabConfig.VMs += @{ VMName = $_ ; Configuration = 'Simple'   ; ParentVHD = 'Win2016NanoHV_G2.vhdx'    ; MemoryStartupBytes= 512MB } }
        $LabConfig.VMs += @{ VMName = 'Windows10' ; Configuration = 'Simple'  ; ParentVHD = 'Win10_G2.vhdx'    ; MemoryStartupBytes= 512MB ; AddToolsVHD=$True ; DisableWCF=$True}

    or you can use this to deploy 100 nanoservers and 100 Windows 10 machines named Windows10_..
        1..100 | ForEach-Object {"NanoServer$_"}  | ForEach-Object { $LabConfig.VMs += @{ VMName = $_ ; Configuration = 'Simple'   ; ParentVHD = 'Win2016NanoHV_G2.vhdx'    ; MemoryStartupBytes= 512MB } }
        1..100 | ForEach-Object {"Windows10_$_"}  | ForEach-Object { $LabConfig.VMs += @{ VMName = $_ ; Configuration = 'Simple'   ; ParentVHD = 'Win10_G2.vhdx'          ; MemoryStartupBytes= 512MB ;   AddToolsVHD=$True ; DisableWCF=$True } }

    or Several different VMs 
        * you need to provide your GPT VHD for win 2012 (like created with convertwindowsimage script)
        $LabConfig.VMs += @{ VMName = 'Win10'            ; Configuration = 'Simple'   ; ParentVHD = 'Win10_G2.vhdx'            ; MemoryStartupBytes= 512MB ; DisableWCF=$True ; vTPM=$True ; EnableWinRM=$True }
        $LabConfig.VMs += @{ VMName = 'Win10_OOBE'       ; Configuration = 'Simple'   ; ParentVHD = 'Win10_G2.vhdx'            ; MemoryStartupBytes= 512MB ; DisableWCF=$True ; vTPM=$True ; Unattend="None" }
        $LabConfig.VMs += @{ VMName = 'Win10_NotInDomain'; Configuration = 'Simple'   ; ParentVHD = 'Win10_G2.vhdx'            ; MemoryStartupBytes= 512MB ; DisableWCF=$True ; vTPM=$True ; Unattend="NoDjoin" ; AdditionalLocalAdmin="Ned" }
        $LabConfig.VMs += @{ VMName = 'Win2016'          ; Configuration = 'Simple'   ; ParentVHD = 'Win2016_G2.vhdx'          ; MemoryStartupBytes= 512MB ; Unattend="NoDjoin" }
        $LabConfig.VMs += @{ VMName = 'Win2016_Core'     ; Configuration = 'Simple'   ; ParentVHD = 'Win2016Core_G2.vhdx'      ; MemoryStartupBytes= 512MB }
        $LabConfig.VMs += @{ VMName = 'Win2016_Nano'     ; Configuration = 'Simple'   ; ParentVHD = 'Win2016NanoHV_G2.vhdx'    ; MemoryStartupBytes= 256MB }
        $LabConfig.VMs += @{ VMName = 'Win2012R2'        ; Configuration = 'Simple'   ; ParentVHD = 'Win2012r2_G2.vhdx'        ; MemoryStartupBytes= 512MB ; Unattend="DjoinCred" }
        $LabConfig.VMs += @{ VMName = 'Win2012R2_Core'   ; Configuration = 'Simple'   ; ParentVHD = 'Win2012r2Core_G2.vhdx'    ; MemoryStartupBytes= 512MB ; Unattend="DjoinCred" }
        $LabConfig.VMs += @{ VMName = 'Win2008R2_Core'   ; Configuration = 'Simple'   ; ParentVHD = 'Win2008R2.vhdx'           ; MemoryStartupBytes= 512MB ; Unattend="DjoinCred" ; Generation = 1}

    Example with sets of different DSC Configs
        1..2 | ForEach-Object {"Nano$_"} | ForEach-Object { $LABConfig.VMs += @{ VMName = $_ ; Configuration = 'Simple'    ; ParentVHD =Â 'Win2016NanoHV_G2.vhdx'    ; MemoryStartupBytes= 256MB ; DSCMode='Pull'; DSCConfig=@('LAPS_Nano_Install','LAPSConfig1')} }
        3..4 | ForEach-Object {"Nano$_"} | ForEach-Object { $LABConfig.VMs += @{ VMName =Â $_ ; Configuration = 'Simple'    ; ParentVHD =Â 'Win2016NanoHV_G2.vhdx'    ; MemoryStartupBytes= 256MB ; DSCMode='Pull'; DSCConfig=@('LAPS_Nano_Install','LAPSConfig2')} }
        1..6 | ForEach-Object {"DSC$_"}  | ForEach-Object { $LabConfig.VMs += @{ VMName = $_ ; Configuration = 'Simple'    ; ParentVHD = 'Win2016NanoHV_G2.vhdx' ; MemoryStartupBytes= 512MB ; DSCMode='Pull'; DSCConfig=@('Config1','Config2')} }
        7..12| ForEach-Object {"DSC$_"}  | ForEach-Object { $LabConfig.VMs += @{ VMName = $_ ; Configuration = 'Simple'    ; ParentVHD = 'Win2016NanoHV_G2.vhdx' ; MemoryStartupBytes= 512MB ; DSCMode='Pull'; DSCConfig='Config3'} }

    Hyperconverged S2D with nano and nested virtualization (see https://msdn.microsoft.com/en-us/virtualization/hyperv_on_windows/user_guide/nesting for more info)
        1..4 | ForEach-Object {"S2D$_"}  | ForEach-Object { $LabConfig.VMs += @{ VMName = $_ ; Configuration = 'S2D'       ; ParentVHD = 'Win2016NanoHV_G2.vhdx'   ; SSDNumber = 4; SSDSize=800GB ; HDDNumber = 12 ; HDDSize= 4TB ; MemoryStartupBytes= 4GB ; NestedVirt=$True} }

    HyperConverged Storage Spaces Direct with Nano Server
        1..4 | ForEach-Object {"S2D$_"}  | ForEach-Object { $LabConfig.VMs += @{ VMName = $_ ; Configuration = 'S2D'       ; ParentVHD = 'Win2016NanoHV_G2.vhdx'   ; SSDNumber = 4; SSDSize=800GB ; HDDNumber = 12 ; HDDSize= 4TB ; MemoryStartupBytes= 512MB } }

    Disaggregated Storage Spaces Direct with Nano Server
        1..4 | ForEach-Object {"Compute$_"}  | ForEach-Object { $LabConfig.VMs += @{ VMName = $_ ; Configuration = 'Simple'   ; ParentVHD = 'Win2016NanoHV_G2.vhdx'     ; MemoryStartupBytes= 512MB } }
        1..4 | ForEach-Object {"SOFS$_"}     | ForEach-Object { $LabConfig.VMs += @{ VMName = $_ ; Configuration = 'S2D'      ; ParentVHD = 'Win2016NanoHV_G2.vhdx'     ; SSDNumber = 12; SSDSize=800GB ; HDDNumber = 0 ; HDDSize= 4TB ; MemoryStartupBytes= 512MB } }

    "traditional" stretch cluster (like with traditional SAN)
        1..2 | ForEach-Object {"Replica$_"} | ForEach-Object { $LabConfig.VMs += @{ VMName = $_ ; Configuration = 'Replica'  ; ParentVHD = 'Win2016NanoHV_G2.vhdx' ; ReplicaHDDSize = 20GB ; ReplicaLogSize = 10GB ; MemoryStartupBytes= 2GB ; VMSet= 'ReplicaSet1' ; AdditionalNetworks = $True} }
        3..4 | ForEach-Object {"Replica$_"} | ForEach-Object { $LabConfig.VMs += @{ VMName = $_ ; Configuration = 'Replica'  ; ParentVHD = 'Win2016NanoHV_G2.vhdx' ; ReplicaHDDSize = 20GB ; ReplicaLogSize = 10GB ; MemoryStartupBytes= 2GB ; VMSet= 'ReplicaSet2' ; AdditionalNetworks = $True} }

    HyperConverged Storage Spaces with Shared Storage
        1..4 | ForEach-Object {"Compute$_"}  | ForEach-Object { $LabConfig.VMs += @{ VMName = $_ ; Configuration = 'Simple'   ; ParentVHD = 'Win2016NanoHV_G2.vhdx'     ; MemoryStartupBytes= 512MB } }
        1..4 | ForEach-Object {"SOFS$_"}     | ForEach-Object { $LabConfig.VMs += @{ VMName = $_ ; Configuration = 'Shared'   ; ParentVHD = 'Win2016NanoHV_G2.vhdx'     ; SSDNumber = 4; SSDSize=800GB ; HDDNumber = 8  ; HDDSize= 4TB ; MemoryStartupBytes= 512MB ; VMSet= 'SharedLab1'} }

    ShieldedVMs lab
        $LABConfig.VMs += @{ VMName = 'HGS' ; Configuration = 'Simple'   ; ParentVHD = 'Win2016Core_G2.vhdx'    ; MemoryStartupBytes= 512MB ; Unattend="NoDjoin" }
        1..2 | ForEach-Object { $VMNames="Compute" ; $LABConfig.VMs += @{ VMName = "$VMNames$_" ; Configuration = 'Simple'   ; ParentVHD = 'Win2016NanoHV_G2.vhdx'   ; MemoryStartupBytes= 2GB ; NestedVirt=$True ; vTPM=$True  } }

    Windows Server 2012R2 Hyper-V (8x4TB CSV + 1 1G Witness)
        1..8 | ForEach-Object {"Node$_"} | ForEach-Object { $LABConfig.VMs += @{ VMName = $_ ; Configuration = 'Shared'   ; ParentVHD = 'win2012r2Core_G2.vhdx'   ; SSDNumber = 1; SSDSize=1GB ; HDDNumber = 8  ; HDDSize= 4TB ; MemoryStartupBytes= 512MB ; VMSet= 'HyperV2012R2Lab' ;Unattend="DjoinCred" } }

    Windows Server 2012R2 Storage Spaces
        1..2 | ForEach-Object {"2012r2Spaces$_"} | ForEach-Object { $LabConfig.VMs += @{ VMName = $_ ; Configuration = 'Shared'   ; ParentVHD = 'win2012r2Core_G2.vhdx'     ; SSDNumber = 4; SSDSize=800GB ; HDDNumber = 8  ; HDDSize= 4TB ; MemoryStartupBytes= 512MB ; VMSet= '2012R2SpacesLab';Unattend="DjoinCred" } }

    #>
#endregion

# SIG # Begin signature block
# MIInrQYJKoZIhvcNAQcCoIInnjCCJ5oCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDTMdnQREsovuXI
# JT6zSvlmZnfcWUbEky5YPrJt7wsmNaCCDYEwggX/MIID56ADAgECAhMzAAACzI61
# lqa90clOAAAAAALMMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjIwNTEyMjA0NjAxWhcNMjMwNTExMjA0NjAxWjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQCiTbHs68bADvNud97NzcdP0zh0mRr4VpDv68KobjQFybVAuVgiINf9aG2zQtWK
# No6+2X2Ix65KGcBXuZyEi0oBUAAGnIe5O5q/Y0Ij0WwDyMWaVad2Te4r1Eic3HWH
# UfiiNjF0ETHKg3qa7DCyUqwsR9q5SaXuHlYCwM+m59Nl3jKnYnKLLfzhl13wImV9
# DF8N76ANkRyK6BYoc9I6hHF2MCTQYWbQ4fXgzKhgzj4zeabWgfu+ZJCiFLkogvc0
# RVb0x3DtyxMbl/3e45Eu+sn/x6EVwbJZVvtQYcmdGF1yAYht+JnNmWwAxL8MgHMz
# xEcoY1Q1JtstiY3+u3ulGMvhAgMBAAGjggF+MIIBejAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUiLhHjTKWzIqVIp+sM2rOHH11rfQw
# UAYDVR0RBEkwR6RFMEMxKTAnBgNVBAsTIE1pY3Jvc29mdCBPcGVyYXRpb25zIFB1
# ZXJ0byBSaWNvMRYwFAYDVQQFEw0yMzAwMTIrNDcwNTI5MB8GA1UdIwQYMBaAFEhu
# ZOVQBdOCqhc3NyK1bajKdQKVMFQGA1UdHwRNMEswSaBHoEWGQ2h0dHA6Ly93d3cu
# bWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY0NvZFNpZ1BDQTIwMTFfMjAxMS0w
# Ny0wOC5jcmwwYQYIKwYBBQUHAQEEVTBTMFEGCCsGAQUFBzAChkVodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY0NvZFNpZ1BDQTIwMTFfMjAx
# MS0wNy0wOC5jcnQwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQsFAAOCAgEAeA8D
# sOAHS53MTIHYu8bbXrO6yQtRD6JfyMWeXaLu3Nc8PDnFc1efYq/F3MGx/aiwNbcs
# J2MU7BKNWTP5JQVBA2GNIeR3mScXqnOsv1XqXPvZeISDVWLaBQzceItdIwgo6B13
# vxlkkSYMvB0Dr3Yw7/W9U4Wk5K/RDOnIGvmKqKi3AwyxlV1mpefy729FKaWT7edB
# d3I4+hldMY8sdfDPjWRtJzjMjXZs41OUOwtHccPazjjC7KndzvZHx/0VWL8n0NT/
# 404vftnXKifMZkS4p2sB3oK+6kCcsyWsgS/3eYGw1Fe4MOnin1RhgrW1rHPODJTG
# AUOmW4wc3Q6KKr2zve7sMDZe9tfylonPwhk971rX8qGw6LkrGFv31IJeJSe/aUbG
# dUDPkbrABbVvPElgoj5eP3REqx5jdfkQw7tOdWkhn0jDUh2uQen9Atj3RkJyHuR0
# GUsJVMWFJdkIO/gFwzoOGlHNsmxvpANV86/1qgb1oZXdrURpzJp53MsDaBY/pxOc
# J0Cvg6uWs3kQWgKk5aBzvsX95BzdItHTpVMtVPW4q41XEvbFmUP1n6oL5rdNdrTM
# j/HXMRk1KCksax1Vxo3qv+13cCsZAaQNaIAvt5LvkshZkDZIP//0Hnq7NnWeYR3z
# 4oFiw9N2n3bb9baQWuWPswG0Dq9YT9kb+Cs4qIIwggd6MIIFYqADAgECAgphDpDS
# AAAAAAADMA0GCSqGSIb3DQEBCwUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0
# ZSBBdXRob3JpdHkgMjAxMTAeFw0xMTA3MDgyMDU5MDlaFw0yNjA3MDgyMTA5MDla
# MH4xCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdS
# ZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMT
# H01pY3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTEwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQCr8PpyEBwurdhuqoIQTTS68rZYIZ9CGypr6VpQqrgG
# OBoESbp/wwwe3TdrxhLYC/A4wpkGsMg51QEUMULTiQ15ZId+lGAkbK+eSZzpaF7S
# 35tTsgosw6/ZqSuuegmv15ZZymAaBelmdugyUiYSL+erCFDPs0S3XdjELgN1q2jz
# y23zOlyhFvRGuuA4ZKxuZDV4pqBjDy3TQJP4494HDdVceaVJKecNvqATd76UPe/7
# 4ytaEB9NViiienLgEjq3SV7Y7e1DkYPZe7J7hhvZPrGMXeiJT4Qa8qEvWeSQOy2u
# M1jFtz7+MtOzAz2xsq+SOH7SnYAs9U5WkSE1JcM5bmR/U7qcD60ZI4TL9LoDho33
# X/DQUr+MlIe8wCF0JV8YKLbMJyg4JZg5SjbPfLGSrhwjp6lm7GEfauEoSZ1fiOIl
# XdMhSz5SxLVXPyQD8NF6Wy/VI+NwXQ9RRnez+ADhvKwCgl/bwBWzvRvUVUvnOaEP
# 6SNJvBi4RHxF5MHDcnrgcuck379GmcXvwhxX24ON7E1JMKerjt/sW5+v/N2wZuLB
# l4F77dbtS+dJKacTKKanfWeA5opieF+yL4TXV5xcv3coKPHtbcMojyyPQDdPweGF
# RInECUzF1KVDL3SV9274eCBYLBNdYJWaPk8zhNqwiBfenk70lrC8RqBsmNLg1oiM
# CwIDAQABo4IB7TCCAekwEAYJKwYBBAGCNxUBBAMCAQAwHQYDVR0OBBYEFEhuZOVQ
# BdOCqhc3NyK1bajKdQKVMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1Ud
# DwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFHItOgIxkEO5FAVO
# 4eqnxzHRI4k0MFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwubWljcm9zb2Z0
# LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18y
# Mi5jcmwwXgYIKwYBBQUHAQEEUjBQME4GCCsGAQUFBzAChkJodHRwOi8vd3d3Lm1p
# Y3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18y
# Mi5jcnQwgZ8GA1UdIASBlzCBlDCBkQYJKwYBBAGCNy4DMIGDMD8GCCsGAQUFBwIB
# FjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2RvY3MvcHJpbWFyeWNw
# cy5odG0wQAYIKwYBBQUHAgIwNB4yIB0ATABlAGcAYQBsAF8AcABvAGwAaQBjAHkA
# XwBzAHQAYQB0AGUAbQBlAG4AdAAuIB0wDQYJKoZIhvcNAQELBQADggIBAGfyhqWY
# 4FR5Gi7T2HRnIpsLlhHhY5KZQpZ90nkMkMFlXy4sPvjDctFtg/6+P+gKyju/R6mj
# 82nbY78iNaWXXWWEkH2LRlBV2AySfNIaSxzzPEKLUtCw/WvjPgcuKZvmPRul1LUd
# d5Q54ulkyUQ9eHoj8xN9ppB0g430yyYCRirCihC7pKkFDJvtaPpoLpWgKj8qa1hJ
# Yx8JaW5amJbkg/TAj/NGK978O9C9Ne9uJa7lryft0N3zDq+ZKJeYTQ49C/IIidYf
# wzIY4vDFLc5bnrRJOQrGCsLGra7lstnbFYhRRVg4MnEnGn+x9Cf43iw6IGmYslmJ
# aG5vp7d0w0AFBqYBKig+gj8TTWYLwLNN9eGPfxxvFX1Fp3blQCplo8NdUmKGwx1j
# NpeG39rz+PIWoZon4c2ll9DuXWNB41sHnIc+BncG0QaxdR8UvmFhtfDcxhsEvt9B
# xw4o7t5lL+yX9qFcltgA1qFGvVnzl6UJS0gQmYAf0AApxbGbpT9Fdx41xtKiop96
# eiL6SJUfq/tHI4D1nvi/a7dLl+LrdXga7Oo3mXkYS//WsyNodeav+vyL6wuA6mk7
# r/ww7QRMjt/fdW1jkT3RnVZOT7+AVyKheBEyIXrvQQqxP/uozKRdwaGIm1dxVk5I
# RcBCyZt2WwqASGv9eZ/BvW1taslScxMNelDNMYIZgjCCGX4CAQEwgZUwfjELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEoMCYGA1UEAxMfTWljcm9z
# b2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMQITMwAAAsyOtZamvdHJTgAAAAACzDAN
# BglghkgBZQMEAgEFAKCBrjAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQgVk5oJ411
# 2bC5+1ou5s9qwcEvBBLXo6bhURvqpJBvrQowQgYKKwYBBAGCNwIBDDE0MDKgFIAS
# AE0AaQBjAHIAbwBzAG8AZgB0oRqAGGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbTAN
# BgkqhkiG9w0BAQEFAASCAQBvZQL/tPkCpfqHCqioDm35ZMoaawpW/xykk5JXfz3r
# 7KWSDq3T+soGvJzRhmFL9FZSKUS9X/Uyrgr4FwI0GARJU8snvhmp21pHSrRjvR7i
# 1sBwrH0bdmtkt5JpNe/iOd3xwUtIDdHsqmef26UYUvGfA8WB27dZDa9ZRFEyLDpf
# lIghIXOMr17LTXVHZ7HLbYMO1k6pJROHpHbXx8GBVy/kccRc4FSbeomgK6OSJeic
# AM98+BJd65GfS5XNgmwLOEe5AAERtN1B2lMLAgokrA3qhlPtSmtLwRbuhIQEF8rc
# 7er94Sd8SMh2pd442JrA0PC29EaOOuVm4R0rExEkxFo3oYIXDDCCFwgGCisGAQQB
# gjcDAwExghb4MIIW9AYJKoZIhvcNAQcCoIIW5TCCFuECAQMxDzANBglghkgBZQME
# AgEFADCCAVUGCyqGSIb3DQEJEAEEoIIBRASCAUAwggE8AgEBBgorBgEEAYRZCgMB
# MDEwDQYJYIZIAWUDBAIBBQAEIDV88EEwIlL7GBJubr4sEfNqCSHIDFSpp+RJu1MZ
# +YWJAgZjxoqLy90YEzIwMjMwMTE5MTMzOTQyLjgxN1owBIACAfSggdSkgdEwgc4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKTAnBgNVBAsTIE1p
# Y3Jvc29mdCBPcGVyYXRpb25zIFB1ZXJ0byBSaWNvMSYwJAYDVQQLEx1UaGFsZXMg
# VFNTIEVTTjo0NjJGLUUzMTktM0YyMDElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUt
# U3RhbXAgU2VydmljZaCCEV8wggcQMIIE+KADAgECAhMzAAABpAfP44+jum/WAAEA
# AAGkMA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
# aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
# cG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEw
# MB4XDTIyMDMwMjE4NTExOFoXDTIzMDUxMTE4NTExOFowgc4xCzAJBgNVBAYTAlVT
# MRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKTAnBgNVBAsTIE1pY3Jvc29mdCBPcGVy
# YXRpb25zIFB1ZXJ0byBSaWNvMSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVTTjo0NjJG
# LUUzMTktM0YyMDElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2Vydmlj
# ZTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAMBHjgD6FPy81PUhcOIV
# Gh4bOSaq634Y+TjW2hNF9BlnWxLJCEuMiV6YF5x6YTM7T1ZLM6NnH0whPypiz3bV
# ZRmwgGyTURKfVyPJ89R3WaZ/HMvcAJZnCMgL+mOpxE94gwQJD/qo8UquOrCKCY/f
# cjchxV8yMkfIqP69HnWfW0ratk+I2GZF2ISFyRtvEuxJvacIFDFkQXj3H+Xy9IHz
# Nqqi+g54iQjOAN6s3s68mi6rqv6+D9DPVPg1ev6worI3FlYzrPLCIunsbtYt3Xw3
# aHKMfA+SH8CV4iqJ/eEZUP1uFJT50MAPNQlIwWERa6cccSVB5mN2YgHf8zDUqQU4
# k2/DWw+14iLkwrgNlfdZ38V3xmxC9mZc9YnwFc32xi0czPzN15C8wiZEIqCddxbw
# imc+0LtPKandRXk2hMfwg0XpZaJxDfLTgvYjVU5PXTgB10mhWAA/YosgbB8KzvAx
# XPnrEnYg3XLWkgBZ+lOrHvqiszlFCGQC9rKPVFPCCsey356VhfcXlvwAJauAk7V0
# nLVTgwi/5ILyHffEuZYDnrx6a+snqDTHL/ZqRsB5HHq0XBo/i7BVuMXnSSXlFCo3
# On8IOl8JOKQ4CrIlri9qWJYMxsSICscotgODoYOO4lmXltKOB0l0IAhEXwSSKID5
# QAa9wTpIagea2hzjI6SUY1W/AgMBAAGjggE2MIIBMjAdBgNVHQ4EFgQU4tATn6z4
# CBL2xZQd0jjN6SnjJMIwHwYDVR0jBBgwFoAUn6cVXQBeYl2D9OXSZacbUzUZ6XIw
# XwYDVR0fBFgwVjBUoFKgUIZOaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9w
# cy9jcmwvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3Js
# MGwGCCsGAQUFBwEBBGAwXjBcBggrBgEFBQcwAoZQaHR0cDovL3d3dy5taWNyb3Nv
# ZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENB
# JTIwMjAxMCgxKS5jcnQwDAYDVR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcD
# CDANBgkqhkiG9w0BAQsFAAOCAgEACVYcUNEMlyTuPDBGhiZ1U548ssF6J2g9QElW
# Eb2cZ4dL0+5G8721/giRtTPvgxQhDF5rJCjHGj8nFSqOE8fnYz9vgb2YclYHvkoK
# WUJODxjhWS+S06ZLR/nDS85HeDAD0FGduAA80Q7vGzknKW2jxoNHTb74KQEMWiUK
# 1M2PDN+eISPXPhPudGVGLbIEAk1Goj5VjzbQuLKhm2Tk4a22rkXkeE98gyNojHlB
# hHbb7nex3zGBTBGkVtwt2ud7qN2rcpuJhsJ/vL/0XYLtyOk7eSQZdfye0TT1/qj1
# 8iSXHsIXDhHOuTKqBiiatoo4Unwk7uGyM0lv38Ztr+YpajSP+p0PEMRH9RdfrKRm
# 4bHV5CmOTIzAmc49YZt40hhlVwlClFA4M+zn3cyLmEGwfNqD693hD5W3vcpnhf3x
# hZbVWTVpJH1CPGTmR4y5U9kxwysK8VlfCFRwYUa5640KsgIv1tJhF9LXemWIPEnu
# w9JnzHZ3iSw5dbTSXp9HmdOJIzsO+/tjQwZWBSFqnayaGv3Y8w1KYiQJS8cKJhwn
# hGgBPbyan+E5D9TyY9dKlZ3FikstwM4hKYGEUlg3tqaWEilWwa9SaNetNxjSfgah
# 782qzbjTQhwDgc6Jf07F2ak0YMnNJFHsBb1NPw77dhmo9ki8vrLOB++d6Gm2Z/jD
# pDOSst8wggdxMIIFWaADAgECAhMzAAAAFcXna54Cm0mZAAAAAAAVMA0GCSqGSIb3
# DQEBCwUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
# A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIw
# MAYDVQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkgMjAx
# MDAeFw0yMTA5MzAxODIyMjVaFw0zMDA5MzAxODMyMjVaMHwxCzAJBgNVBAYTAlVT
# MRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1l
# LVN0YW1wIFBDQSAyMDEwMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA
# 5OGmTOe0ciELeaLL1yR5vQ7VgtP97pwHB9KpbE51yMo1V/YBf2xK4OK9uT4XYDP/
# XE/HZveVU3Fa4n5KWv64NmeFRiMMtY0Tz3cywBAY6GB9alKDRLemjkZrBxTzxXb1
# hlDcwUTIcVxRMTegCjhuje3XD9gmU3w5YQJ6xKr9cmmvHaus9ja+NSZk2pg7uhp7
# M62AW36MEBydUv626GIl3GoPz130/o5Tz9bshVZN7928jaTjkY+yOSxRnOlwaQ3K
# Ni1wjjHINSi947SHJMPgyY9+tVSP3PoFVZhtaDuaRr3tpK56KTesy+uDRedGbsoy
# 1cCGMFxPLOJiss254o2I5JasAUq7vnGpF1tnYN74kpEeHT39IM9zfUGaRnXNxF80
# 3RKJ1v2lIH1+/NmeRd+2ci/bfV+AutuqfjbsNkz2K26oElHovwUDo9Fzpk03dJQc
# NIIP8BDyt0cY7afomXw/TNuvXsLz1dhzPUNOwTM5TI4CvEJoLhDqhFFG4tG9ahha
# YQFzymeiXtcodgLiMxhy16cg8ML6EgrXY28MyTZki1ugpoMhXV8wdJGUlNi5UPkL
# iWHzNgY1GIRH29wb0f2y1BzFa/ZcUlFdEtsluq9QBXpsxREdcu+N+VLEhReTwDwV
# 2xo3xwgVGD94q0W29R6HXtqPnhZyacaue7e3PmriLq0CAwEAAaOCAd0wggHZMBIG
# CSsGAQQBgjcVAQQFAgMBAAEwIwYJKwYBBAGCNxUCBBYEFCqnUv5kxJq+gpE8RjUp
# zxD/LwTuMB0GA1UdDgQWBBSfpxVdAF5iXYP05dJlpxtTNRnpcjBcBgNVHSAEVTBT
# MFEGDCsGAQQBgjdMg30BATBBMD8GCCsGAQUFBwIBFjNodHRwOi8vd3d3Lm1pY3Jv
# c29mdC5jb20vcGtpb3BzL0RvY3MvUmVwb3NpdG9yeS5odG0wEwYDVR0lBAwwCgYI
# KwYBBQUHAwgwGQYJKwYBBAGCNxQCBAweCgBTAHUAYgBDAEEwCwYDVR0PBAQDAgGG
# MA8GA1UdEwEB/wQFMAMBAf8wHwYDVR0jBBgwFoAU1fZWy4/oolxiaNE9lJBb186a
# GMQwVgYDVR0fBE8wTTBLoEmgR4ZFaHR0cDovL2NybC5taWNyb3NvZnQuY29tL3Br
# aS9jcmwvcHJvZHVjdHMvTWljUm9vQ2VyQXV0XzIwMTAtMDYtMjMuY3JsMFoGCCsG
# AQUFBwEBBE4wTDBKBggrBgEFBQcwAoY+aHR0cDovL3d3dy5taWNyb3NvZnQuY29t
# L3BraS9jZXJ0cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcnQwDQYJKoZIhvcN
# AQELBQADggIBAJ1VffwqreEsH2cBMSRb4Z5yS/ypb+pcFLY+TkdkeLEGk5c9MTO1
# OdfCcTY/2mRsfNB1OW27DzHkwo/7bNGhlBgi7ulmZzpTTd2YurYeeNg2LpypglYA
# A7AFvonoaeC6Ce5732pvvinLbtg/SHUB2RjebYIM9W0jVOR4U3UkV7ndn/OOPcbz
# aN9l9qRWqveVtihVJ9AkvUCgvxm2EhIRXT0n4ECWOKz3+SmJw7wXsFSFQrP8DJ6L
# GYnn8AtqgcKBGUIZUnWKNsIdw2FzLixre24/LAl4FOmRsqlb30mjdAy87JGA0j3m
# Sj5mO0+7hvoyGtmW9I/2kQH2zsZ0/fZMcm8Qq3UwxTSwethQ/gpY3UA8x1RtnWN0
# SCyxTkctwRQEcb9k+SS+c23Kjgm9swFXSVRk2XPXfx5bRAGOWhmRaw2fpCjcZxko
# JLo4S5pu+yFUa2pFEUep8beuyOiJXk+d0tBMdrVXVAmxaQFEfnyhYWxz/gq77EFm
# PWn9y8FBSX5+k77L+DvktxW/tM4+pTFRhLy/AsGConsXHRWJjXD+57XQKBqJC482
# 2rpM+Zv/Cuk0+CQ1ZyvgDbjmjJnW4SLq8CdCPSWU5nR0W2rRnj7tfqAxM328y+l7
# vzhwRNGQ8cirOoo6CGJ/2XBjU02N7oJtpQUQwXEGahC0HVUzWLOhcGbyoYIC0jCC
# AjsCAQEwgfyhgdSkgdEwgc4xCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5n
# dG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9y
# YXRpb24xKTAnBgNVBAsTIE1pY3Jvc29mdCBPcGVyYXRpb25zIFB1ZXJ0byBSaWNv
# MSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVTTjo0NjJGLUUzMTktM0YyMDElMCMGA1UE
# AxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZaIjCgEBMAcGBSsOAwIaAxUA
# NBwo4pNrfEL6DVo+tw96vGJvLp+ggYMwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEG
# A1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWlj
# cm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFt
# cCBQQ0EgMjAxMDANBgkqhkiG9w0BAQUFAAIFAOdzrA4wIhgPMjAyMzAxMTkxNTQ2
# MjJaGA8yMDIzMDEyMDE1NDYyMlowdzA9BgorBgEEAYRZCgQBMS8wLTAKAgUA53Os
# DgIBADAKAgEAAgIk/AIB/zAHAgEAAgIRETAKAgUA53T9jgIBADA2BgorBgEEAYRZ
# CgQCMSgwJjAMBgorBgEEAYRZCgMCoAowCAIBAAIDB6EgoQowCAIBAAIDAYagMA0G
# CSqGSIb3DQEBBQUAA4GBAHfx6YQboB73fEaaLE3CAnm9ZBYwnU6x//sNQnwSR18F
# ZpzKarzVDy2d58CkXnWxPc+YqsqyQ9w9zdHwE/kYGkUUNGd23PbK2UvXt4roviIF
# xmJWrrdQrzok7c1B751ofGVcqTtVpAFhdzErbTjBRmfBopbzIUxdDJuUVf9An04L
# MYIEDTCCBAkCAQEwgZMwfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0
# b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3Jh
# dGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMA
# AAGkB8/jj6O6b9YAAQAAAaQwDQYJYIZIAWUDBAIBBQCgggFKMBoGCSqGSIb3DQEJ
# AzENBgsqhkiG9w0BCRABBDAvBgkqhkiG9w0BCQQxIgQgFW3GiqD2/p0aIsn07Idr
# 8VRCT1CyxSP6dtfzbU7bjlEwgfoGCyqGSIb3DQEJEAIvMYHqMIHnMIHkMIG9BCAF
# /OCjISZwpMBJ8MJ3WwMCF3qOa5YHFG6J4uHjaup5+DCBmDCBgKR+MHwxCzAJBgNV
# BAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4w
# HAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29m
# dCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAABpAfP44+jum/WAAEAAAGkMCIEID9O
# /YwX0uzbbv87tCAKh0eKxd4D4n/700H750WFRp2HMA0GCSqGSIb3DQEBCwUABIIC
# AKZQtPyefGES5SaISaWcGXDcrF5WqjbYcik3zejFCJgXq8YU7tkvcPUSgJo8fgjC
# Rfx/naQE8+TfeJTajqVXyx1qeyPCFRmD1tHOLUhPyUjGOAJEINYmx/ZwRn0Y47U7
# n+JvbHVZHuD6hXWoGBclG8DaM1fYYqdY3Mx96ac96gj8t/wC1eTSoTR8q/LDsMl9
# ndQAJh5EbhwCu7TxYSSTqwKJKs+WcoWrl44t5s8pQqv5X3xfV4DDLxPPffE9SQgv
# 8mOyE84eE3RsLvyDywf/pLfb3jEGLhcmSidfIQ0diXueMiwa0EmJnIYeBjP8aVzq
# EhKy53s8pg+PvbvU6XWaDoVdvrT66z/wKJ8c2OJCtQhoN9CxrEAXZaQQEAUj4EAN
# vv5aFGF8MHc2eRcWJLCFULaraQcuGkTX97PM/AHISFKxi7vsYb6V4mY9aeh2bnjP
# VjqSIXTWNE6BtqfKgy19VhmxskxaMwdckWFvWPkmI72x+os/InusEAxEGHyKGvsL
# eilr7/vfh1lMMmHl/v6i1nS+ZCSXOui3jx7rruos6/20ffA88HGGnPuCMmaeZx/5
# UrrBo/AvTXaHvH4gfikzK0BSFTXIf7f59rJ8zymDWomh+fe64mFvQAX+PDRPU4V/
# g9AtPZ8XJVlPpJuKH1t0YjbhA8UFPNBDCgRmDsxOCZA9
# SIG # End signature block
