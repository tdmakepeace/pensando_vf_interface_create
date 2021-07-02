#!/bin/bash
#
# This script will create the output needed to create the VF interfaces on a Linux server.
# PLEASE NOTE: 
# This has only been create for test environments.

# To use the script provide the interface name and the number of VF and the base MAC-address
# vf_interface_create.sh <name of interface> <number of VF> <base mac-address> <output file>

inter_name=$1
number_vf=$2
base_mac=$3
out_file=$4


if [ "${inter_name}" == "" ]; then
    echo Syntax:
    echo $0 \<name of interface\> \<number of VF\> \<base mac-address\> \<output file \(optional\)\>

    exit 1
fi


if [ "${out_file}" != "" ]; then
    if [ -f "${out_file}.sh" ] || [ -f "${out_file}.yaml" ] || [ -d "${out_file}" ]; then
        echo Error:
        echo "Filename: ${out_file} already exists"
        exit 1
    fi
    
fi


drivercheck() {
    echo "Confirm with your SE the driver version number required to support vf interfaces"
    echo "Version 1.28.0-93 or above for enterprise release"
    echo ""
    echo ""
    driverv=$(dmesg | grep ionic | grep Pensando)
    echo "$driverv"
}

interfacecheck() {
    inter_name=$1
    inet_check=$(lshw -businfo -class network |grep ${inter_name})
    echo ${inet_check}

}

dectohex() {
    x=$( printf "%x" $((10#$1))) ; echo $x
}

hextodec() {
    x=$( printf "%d" $((16#$1))) ; echo $x
}



# check if interface exist.
resultint=$(interfacecheck "${inter_name}")

if [ "${resultint}" == "" ] ;then
    echo "Interface: ${inter_name} does not exist"
    echo ""
    int_out=$(lshw -businfo -class network |egrep -i "Bus|====|DSC|Pensando")
    echo "$int_out"
    exit 1
fi

if [ "${resultint}" != "" ] ;then
    echo "Interface: ${inter_name} exists"
    echo ""
    driver_out=$(drivercheck)
    echo "$driver_out"
    echo ""

    # for the while loop for the VF interface creation. 
    x=1

    echo "The following command must be run as root, once the driver loaded"
    echo "and the SRIOV enabled on PSM, "
    echo "\"echo ${number_vf} > /sys/class/net/${inter_name}/device/sriov_numvfs\""
    echo "To set persistent use the yaml example output"
    echo "Note: investigating why the yaml sets the VF and Mac-address, but not presented to the DSC."
    # seperate on the 6th octet of the mac-address
    echo "Base Mac-address: ${base_mac}"
    echo ""
    pre=$(echo "${base_mac}" | rev | cut -d":" -f2-  | rev)
    post=$(echo "${base_mac}" | rev | cut -d":" -f1  | rev)

    #convrt the last octet to dec
    hex="$post"
    hextodeccon=$(hextodec "${hex}")

    if [ "${out_file}" != "" ]; then
        echo "    ${inter_name}:" > ${out_file}.yaml
        echo "      virtual-function-count: ${number_vf}" >> ${out_file}.yaml
	echo "#!/bin/bash" > ${out_file}.sh
    fi

    
    while [ $x -le ${number_vf} ]
        do
            dec=$(expr $hextodeccon + $x - 1)
            dectohexcon=$(dectohex "${dec}")
            #      echo "$dectohexcon"


            if [ ${#dectohexcon} -le 1 ]; then  
                if [[ $dectohexcon =~ [0-9] ]]; then 
	            dectohexcon=$( printf '%02d' $dectohexcon)
        #            echo "$dectohexcon"
                else 
                    dectohexcon="0$dectohexcon"
        #            echo "$dectohexcon"
                fi 
            fi

            if [ "${out_file}" != "" ]; then
               # echo "ip link set ens1 vf 0 mac $pre:$dectohexcon" >> ${out_file}
                echo "ip link set ${inter_name} vf $(( $x - 1 )) mac $pre:$dectohexcon" >> ${out_file}.sh
                echo "ip link set ${inter_name} vf $(( $x - 1 )) trust on" >> ${out_file}.sh
                echo "ip link set ${inter_name} vf $(( $x - 1 )) state auto" >> ${out_file}.sh

                echo "    ${inter_name}v$(( $x - 1 )):" >> ${out_file}.yaml
                echo "      link: ${inter_name}" >> ${out_file}.yaml
                echo "      macaddress: $pre:$dectohexcon" >> ${out_file}.yaml
            else
                echo "ip link set ${inter_name} vf $(( $x - 1 )) mac $pre:$dectohexcon" 
                echo "ip link set ${inter_name} vf $(( $x - 1 )) trust on" 
                echo "ip link set ${inter_name} vf $(( $x - 1 )) state auto" 

            fi



            x=$(( $x + 1 ))
        done

fi
exit 0

