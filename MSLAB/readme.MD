# TODO:
- Information about the purpose of the folders :D
- update patching os image
- windows hyper-v serverin rakennus
  - Rakenteellista buutable usb stick
  - USB stick windows natiivityökaluilla

# PATCHING OS IMAGE (PARENT DISK)

You potentially have following files somewhere:

- Win2022_G2.vhdx
- Win2022Core_G2.vhdx

To update latest Windows patches for those images, proceed this way:
- .\DownloadLatestCUs.ps1
  - this will download latest cumulative updates
  - you potentially want to collect all MSU packages under same folder structure
  - note: this does not download EVERYTHING - you might need to download some additional msu files later
- .\PatchParentDisks.ps1
  - that will ask vhdx files (above)
  - and that will ask .msu files (patch information)

# AJATUKSEN VIRTAA

Making bootable windows server usb stick

- uefi

- split install.wim to smaller files (fat32 requirement)
dism /split-image /imagefile:c:\msdn\win2022pr\sources\install.wim /swmfile:c:\msdn\win2022pr\sources\install.swm /filesize:4096