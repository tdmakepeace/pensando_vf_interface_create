# pensando_vf_interface_create

Example script for the creation of VF interfaces on a Pensando DSC.

vf_interface_create.sh <name of interface> <number of VF> <base mac-address> <output file>
  
\<name of interface> -- the name of the interface you want to enable the VF interfaces on. <br>
\<number of VF> -- number of vf interfaces you want to configure normally 16 <br>
\<base mac-address> -- starting MAC address you want to assing to the VF interfaces (script will increment the last octet<br>
\<output file> -- (optional) output to file if you are running from a central location, or screen is no output defined <br>
  
If set to output, two files are created ".yaml" and ".set". The ".yaml" provides the expected output if you are using netplan to configure the server, ".set" is the output if you want to set within the current session.
 
  <br>

# Useful notes and commands
  
##  building the driver on ubuntu and replacing the inboxed driver
check the version of the driver running, if less than 1.0 you will need to update to support VF interfaces.
  ```
dmesg | grep ionic
``` 

  ### build the driver
upload the driver bundle you get from the support site.
extract, and then run the make 

  <br>
  
###  Dependencies
  <br>
  
```
sudo apt install make
sudo apt install binutils
sudo apt install gcc
 ./build.sh
```


###  copy the new build driver across.
```
cp eth/ionic/ionic.ko /lib/modules/$(uname -r)/kernel/drivers/net/ethernet/pensando/ionic/ionic.ko
depmod
update-initramfs -u
```
  reboot host and validate the driver installed. 
```
dmesg | grep ionic
```
  
### if ubuntu or Debian to fix the interface renaming issue.
  ```
  echo 'SUBSYSTEM=="net", ENV{ID_VENDOR_ID}=="0x1dd8", NAME="$env{ID_NET_NAME_PATH}"' > /etc/udev/rules.d/81-pensando-net.rules
  ```
  
### to create the vf interfaces
  ```
  echo 16 > /sys/class/net/enp20s0/device/sriov_numvfs
  ```

  #### check the vf created.
`ls -l /sys/class/net/enp20s0/device/virtfn*`
```
journalctl -b |  grep enp20s0.2
more /run/systemd/network/10-netplan-enp20s0.2.network
lshw -c network -businfo
networkctl status enp20s0.2
 ```
  
  
 ### enable SRIOV pass through to the VM
```
sudo -i
edit /etc/default/grub
```
add/edit line - GRUB_CMDLINE_LINUX_DEFAULT="intel_iommu=on iommu=pt"
```
update-grub
grub-mkconfig -o /boot/grub/grub.cfg
```
reboot
  
  
#  Disclaimer
This software is provided without support, warranty, or guarantee. Use at your own risk.
  
