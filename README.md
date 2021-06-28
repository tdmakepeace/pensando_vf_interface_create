# pensando_vf_interface_create

Example script for the creation of VF interfaces on a Pensando DSC.

vf_interface_create.sh <name of interface> <number of VF> <base mac-address> <output file>
  
<name of interface> -- the name of the interface you want to enable the VF interfaces on.
<number of VF> -- number of vf interfaces you want to configure normally 16
<base mac-address> -- starting MAC address you want to assing to the VF interfaces (script will increment the last octet
<output file> -- (optional) output to file if you are running from a central location, or screen is no output defined.
  
