#!/bin/bash

#centreon -u admin -p centreon -e > /tmp/clapi-export.txt

#cut -f3- -d";" clapi-export5.txt |grep "DISK;"|less
#cut -f1- -d";" clapi-export5.txt |grep "DISK;"|less >STDL_DISK.txt

#cut -f1- -d";" clapi-export5.txt |grep "check_nrpe3_disk;">CMD_check_nrpe3_disk.txt
#sed -i 's/;check_nrpe3_disk2.3;/;check_nrpe3_disk2;/g' cmd.csv|cat cmd.csv
#sed -i 's/;DISK;/;DISK2;/g' stpl.csv;cat stpl.csv
#awk  -F";" '/^STPL;ADD;/ { print $0 }' clapi-export5.txt|cat -n

######## Link Host TEMPLATE with Service Template #####
#centreon -u admin -p centreon -o STPL -a addhosttemplate -v "MyTemplate-Service;generic-active-host-custom"

function show_menu() {
    date
    echo "==========="
    echo "Main menu"
    echo "==========="
    echo "1. ADD CMD Object"
    echo "2. ADD STPL Object"
    echo "3. ADD HTPL Object"
    echo "4. ADD HOST Object"
    echo "5. MAKE FILE WITH INTREST Object FROM CLAPI-EXPORT"
    echo "6. Exit"

}

function read_input(){
    read -p "Enter your choice [ 1 - 6 ] " choice
    case $choice in
        1) add_cmd ;;
        2) add_stpl ;;
        3) add_htpl ;;
        4) add_host ;;
        5) make_file ;;
        6) exit 0 ;;
        *)
            echo "Please select number [ 1 - 6 ]"
    esac
}

function make_file(){
    echo "Write input Fullname of clapi-export file"
    read fromFile
    echo "Write output Fullname csv file to import"
    read makeFile
    echo "Write a Object from input file e.g. STPL;ADD;<Object>; or CMD;ADD;<Object>; please use format like: ;<Object>; "
    read grepWord
    #clapi-export5.txt
    cut -f1- -d";" $fromFile |grep "$grepWord" > $makeFile
    cat -n $makeFile|less
}


function add_stpl(){
    #'name","ip_address","u_number","u_os_family"
LOG_STPL=$(date +%d%m%y_%H%M%S)
echo "write input stplFile with stpl data"
read stplFile
#echo "write STPL;ADD;<Object>"
#read stplObject
#cut -f3- -d"," $stplFile
#sed 1d $hostFile|  while read i; do
count=0

cat -n $stplFile
read -p "Press any key to continue or CTRL-C to abort"
cat $stplFile|  while read i; do
        count=$((a+1))
        #i=$(echo $i | sed 's/\"//g')
        date >> $LOG_STPL-STPL.txt
       
        echo $i >> $LOG_STPL-STPL.txt
     
        add="$(echo $i | awk  -F";" '/^STPL;ADD;/ { print $0 }' | cut -d ";" -f 3-)"
        #add="$(echo $i | awk  -F";" '/^STPL;ADD;'$stplObject'/ { print $0 }' | cut -d ";" -f 3-)"
        setparam="$(echo $i | awk  -F";" '/^STPL;setparam;/ { print $0 }' | cut -d ";" -f 3-)"
        #setparam="$(echo $i | awk  -F";" '/^STPL;setparam;'$stplObject'/ { print $0 }' | cut -d ";" -f 3-)"
        echo "=================ADDING STPL $count==============================="
        centreon -u admin -p centreon -o STPL -a ADD -v "$add" >> $LOG_STPL-STPL.txt
        echo "=====================setparam==========================="
        centreon -u admin -p centreon -o STPL -a setparam -v "$setparam" >> $LOG_STPL-STPL.txt
        echo "=========================ENDING ADD=======================" #>> $LOG_STPL-STPL.txt
done
echo "===============END CMD========="
cat -n $LOG_STPL-STPL.txt|less
}



function add_htpl(){
    echo "text"
}


function add_host(){
#'name","ip_address","u_number","u_os_family"
LOG_HOST=$(date +%d%m%y_%H%M%S)
echo "write input hostFile with hosts data"
read hostFile
cut -f1-4 -d"," $hostFile >auto_hosts_generated_file.csv
hostFile=auto_hosts_generated_file.csv

cat -n $hostFile
read -p "Press any key to continue or CTRL-C to abort"
sed 1d $hostFile|  while read i; do
        i=$(echo $i | sed 's/\"//g')
        date >> $LOG_HOST-hosts.csv
        echo $i | cut -d "," -f 1 >> $LOG_HOST-hosts.csv
        HOSTNAME=$(echo $i | cut -d "," -f 1)
        IP=$(echo $i | cut -d "," -f 2)
        SNOWID=$(echo $i | cut -d "," -f 3)
        OS=$(echo $i | cut -d "," -f 4)
        echo "=================ADDING HOSTS==============================="
        centreon -u admin -p centreon -o HOST -a ADD -v "${HOSTNAME};;${IP};;Central;${OS}" >> $LOG_HOST-hosts.csv
        centreon -u admin -p centreon -o HOST -a addcontact -v "${HOSTNAME};user" >> $LOG_HOST-hosts.csv
        centreon -u admin -p centreon -o HOST -a setparam -v "${HOSTNAME};notes;${SNOWID}" >> $LOG_HOST-hosts.csv
        centreon -u admin -p centreon -o HOST -a setparam -v "${HOSTNAME};notes_url;ServerMgmt.${OS}.unspecified" >> $LOG_HOST-hosts.csv
        centreon -u admin -p centreon -o HOST -a setparam -v "${HOSTNAME};notifications_enabled;1" >> $LOG_HOST-hosts.csv            
        centreon -u admin -p centreon -o HOST -a setparam -v "${HOSTNAME};notification_period;24x7" >> $LOG_HOST-hosts.csv 
        centreon -u admin -p centreon -o HOST -a setparam -v "${HOSTNAME};notification_interval;60" >> $LOG_HOST-hosts.csv
        centreon -u admin -p centreon -o HOST -a setparam -v "${HOSTNAME};host_notification_options;d,u,r" >> $LOG_HOST-hosts.csv
        #centreon -u admin -p centreon -o HOST -a applytpl -v $(echo $i | cut -d \; -f 1) >> $LOG_HOST-hosts.csv
        #if [[ $ACTION =~ Object\ already\ exists\ \(.*\) ]]; then
        #                HOST=$(echo $i | cut -d \; -f 1)
        #                TEMPLATES=$(echo $i | cut -d \; -f 4)
        #                GROUP=$(echo $i | cut -d \; -f 6)
        #                centreon -u admin -p password -o HOST -a addtemplate -v $(echo $HOST\;$TEMPLATES) >> $LOG_HOST-hosts.csv
        #                centreon -u admin -p password -o HOST -a addhostgroup -v $(echo $HOST\;$GROUP) >> $LOG_HOST-hosts.csv
        #                centreon -u admin -p password -o HOST -a applytpl -v $(echo $i | cut -d \; -f 1) >> $LOG_HOST-hosts.csv
        #fi
done
echo "=================END HOSTS==============================="
cat -n $LOG_HOST-hosts.csv|less

}


function add_cmd(){
#'name","ip_address","u_number","u_os_family"
LOG_CMD=$(date +%d%m%y_%H%M%S)
echo "write input cmdFile with cmd data"
read cmdFile
#cut -f3- -d"," $cmdFile
#sed 1d $hostFile|  while read i; do
cat -n $cmdFile
read -p "Press any key to continue or CTRL-C to abort"
cat $cmdFile|  while read i; do
        #i=$(echo $i | sed 's/\"//g')
        date >> $LOG_CMD-cmd.txt
        #echo $i | cut -d "," -f 1 >> $LOG_CMD-cmd.txt
        echo $i >> $LOG_CMD-cmd.txt
        
        #HOSTNAME=$(echo $i | cut -d "," -f 1)
        #IP=$(echo $i | cut -d "," -f 2)
        #SNOWID=$(echo $i | cut -d "," -f 3)
        #OS=$(echo $i | cut -d "," -f 4)
        add="$(echo $i | awk  -F";" '/^CMD;ADD;/ { print $0 }' | cut -d ";" -f 3-)"
        setparam="$(echo $i | awk  -F";" '/^CMD;setparam;/ { print $0 }' | cut -d ";" -f 3-)"
        setargumentdescr="$(echo $i | awk  -F";" '/^CMD;setargumentdescr;/ { print $0 }' | cut -d ";" -f 3-)"
        echo "=================ADDING CMD==============================="
        centreon -u admin -p centreon -o CMD -a ADD -v "$add" >> $LOG_CMD-cmd.txt
          echo "=====================setparam==========================="
        centreon -u admin -p centreon -o CMD -a setparam -v "$setparam" >> $LOG_CMD-cmd.txt
          echo "=======================setargumentdescr========================="
        centreon -u admin -p centreon -o CMD -a setargumentdescr -v "$setargumentdescr" >> $LOG_CMD-cmd.txt
          echo "=========================ENDING ADD=======================" >> $LOG_CMD-cmd.txt
done
echo "===============END CMD========="
cat -n $LOG_CMD-cmd.txt|less

}



show_menu
read_input