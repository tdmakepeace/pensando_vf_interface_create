# pensando_vf_interface_create

Example script for the creation of VF interfaces on a Pensando DSC.

vf_interface_create.sh <name of interface> <number of VF> <base mac-address> <output file>
  
\<name of interface> -- the name of the interface you want to enable the VF interfaces on. <br>
\<number of VF> -- number of vf interfaces you want to configure normally 16 <br>
\<base mac-address> -- starting MAC address you want to assing to the VF interfaces (script will increment the last octet<br>
\<output file> -- (optional) output to file if you are running from a central location, or screen is no output defined <br>
 
  <br>

# Useful commands
  
  building the driver on ubuntu and replacing the inboxed driver
```
dmesg | grep ionic
``` 
### build the driver
upload the driver bundle.
extract, and then run the make from the 


### copy the new build driver across.
```
cp eth/ionic/ionic.ko /lib/modules/$(uname -r)/kernel/drivers/net/ethernet/pensando/ionic/ionic.ko
depmod
update-initramfs -u
```

  #### check the vf created.
`ls -l /sys/class/net/enp20s0/device/virtfn*`
```
journalctl -b |  grep enp20s0.2
more /run/systemd/network/10-netplan-enp20s0.2.network
lshw -c network -businfo
networkctl status enp20s0.2
 ```
  
#  Disclaimer
This software is provided without support, warranty, or guarantee. Use at your own risk.
  
