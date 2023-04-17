# TODO:
- Information about the purpose of the folders :D
- Rakenteellista buutable usb stick
- USB stick windows natiivityökaluilla

# AJATUKSEN VIRTAA

Making bootable windows server usb stick

- uefi

- split install.wim to smaller files (fat32 requirement)
dism /split-image /imagefile:c:\msdn\win2022pr\sources\install.wim /swmfile:c:\msdn\win2022pr\sources\install.swm /filesize:4096