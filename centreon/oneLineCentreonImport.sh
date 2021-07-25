#!/bin/bash

#https://docs.centreon.com/20.04/en/api/clapi.html#hosts

#centreon -u admin -p centreon -e > /tmp/clapi-export.txt
#centreon -u admin -p centreon -o STPL -a show

######## Link Host TEMPLATE with Service Template #####
#centreon -u admin -p centreon -o STPL -a addhosttemplate -v "MyTemplate-Service;generic-active-host-custom"


#echo "STPL;ADD;DISK6;DISK_Linux;" | awk -F";" '/^STPL;ADD;/ { print $0 }' | cut -d ";" -f 3- | while read i ; do centreon -u admin -p centreon -o STPL -a ADD -v "$i" ; done
#cat DISK2.csv|awk -F";" '/^STPL;ADD;/ { print $0 }' | cut -d ";" -f 3-|while read i;do centreon -u admin -p centreon -o STPL -a ADD -v "$i";done
#cat DISK2.csv|awk -F";" '/^STPL;ADD;/ { print $0 }' | cut -d ";" -f 3-|while read i;do echo "$i";done

######### import from clapi #########
#cat clapi-export6.txt|awk -F";" '/^STPL;ADD;DISK2;/ { print $0 }' | cut -d ";" -f 3-|while read i;do centreon -u admin -p centreon -o STPL -a ADD -v "${i}";done
#cat clapi-export6.txt|awk -F";" '/^STPL;setparam;DISK2;/ { print $0 }' | cut -d ";" -f 3-|while read i;do centreon -u admin -p centreon -o STPL -a setparam -v "${i}";done
#cat clapi-export6.txt|awk -F";" '/^STPL;setmacro;DISK2;/ { print $0 }' | cut -d ";" -f 3-|while read i;do centreon -u admin -p centreon -o STPL -a setmacro -v "${i}";done


######### import from clapi #########
# STPL
#centreon -u admin -p centreon -o STPL -a show
#cat clapi-export6.txt|awk -F";" '/^STPL;ADD;DISK2;/ { print $0 }' | cut -d ";" -f 3-|while read i;do centreon -u admin -p centreon -o STPL -a ADD -v "${i}";done
#cat clapi-export6.txt|awk -F";" '/^STPL;setparam;DISK2;/ { print $0 }' | cut -d ";" -f 3-|while read i;do centreon -u admin -p centreon -o STPL -a setparam -v "${i}";done
#cat clapi-export6.txt|awk -F";" '/^STPL;setmacro;DISK2;/ { print $0 }' | cut -d ";" -f 3-|while read i;do centreon -u admin -p centreon -o STPL -a setmacro -v "${i}";done

# CMD
#centreon -u admin -p centreon -o CMD -a show 
#cat clapi-export6.txt|awk -F";" '/^CMD;ADD;check_ssh;/ { print $0 }' | cut -d ";" -f 3-|while read i;do centreon -u admin -p centreon -o CMD -a ADD -v "${i}";done
#cat clapi-export6.txt|awk -F";" '/^CMD;setparam;check_ssh;/ { print $0 }' | cut -d ";" -f 3-|while read i;do centreon -u admin -p centreon -o CMD -a setparam -v "${i}";done
#cat clapi-export6.txt|awk -F";" '/^CMD;setargumentdescr;check_ssh;/ { print $0 }' | cut -d ";" -f 3-|while read i;do centreon -u admin -p centreon -o CMD -a setargumentdescr -v "${i}";done

# HOST
centreon -u admin -p centreon -o HOST -a show
cat cmdb_ci_server.csv| sed 's/\"//g'| cut -d "," -f 1-4|while read i;do echo ${i};done

## import hosts from file
LOG=$(date +%d%m%y_%H%M%S);cat ci_server.csv| sed 's/\"//g'| cut -d "," -f 1-4 | sed 1d |while read -r i; do IFS=',';line=(${i}); col0=${line[0]};col1=${line[1]};col2=${line[2]};col3=${line[3]};
    centreon -u admin -p centreon -o HOST -a ADD -v "${col0};;${col1};;Central;${col3}" >> add_host_$LOG
	centreon -u admin -p centreon -o HOST -a addcontact -v "${col0};user" >> add_host_$LOG;
	centreon -u admin -p centreon -o HOST -a setparam -v "${col0};notes;${col2}" >> add_host_$LOG;
	centreon -u admin -p centreon -o HOST -a setparam -v "${col0};notes_url;ServerMgmt.${OS}.unspecified" >> add_host_$LOG;
	centreon -u admin -p centreon -o HOST -a setparam -v "${col0};notifications_enabled;1" >> add_host_$LOG;
	centreon -u admin -p centreon -o HOST -a setparam -v "${col0};notification_period;24x7" >> add_host_$LOG;
	centreon -u admin -p centreon -o HOST -a setparam -v "${col0};notification_interval;60" >> add_host_$LOG;
	centreon -u admin -p centreon -o HOST -a setparam -v "${col0};host_notification_options;d,u,r" >> add_host_$LOG; done

###########template########
#centreon -u admin -p centreon -o HOST -a ADD -v "test;Test host;127.0.0.1;generic-host;central;Linux"


# IMPORT/EXPORT ^HOST|^HTPL|^STPL|^CMD  
####Example with "nameObject_service" service template name and 'nameObject_host_template' for template name
centreon -u admin -p PASSWORD -e |grep -i nameObject_service | egrep '^HTPL|^STPL|^CMD' > nameObject_service.clapi.txt

## export host
centreon -u admin -p centreon -e |grep -i ubuntu | egrep '^HOST|^HTPL|^STPL|^CMD'|cat -n
centreon -u admin -p centreon -e |grep -i ubuntu | egrep '^HOST|^HTPL|^STPL|^CMD'> ubuntu.clapi.txt

## chaneg value DISK7 to DISK8
sed -i 's/DISK7/DISK8/g' nameObject_service.clapi>cat nameObject_service.clap;cat nameObject_service.clap

##After that, you'll be able to import these /host/service template and command to another Centreon:
## import Object
centreon -u admin -p PASSWORD -i nameObject.clapi.txt


# IMPORT/EXPORT SERVICE by Host
## export serwisu
centreon -u admin -p centreon -e |grep -i DISK_Linux|grep ubuntu
centreon -u admin -p centreon -e |grep -i DISK_Linux|grep ubuntu>DISK_Linux.clapi.txt

## podmiana nazwy serwisu
sed -i 's/DISK_Linux/DISK_Linux2/g' DISK_Linux.clapi.txt

## import servisu
centreon -u admin -p centreon -i DISK_Linux.clapi.txt


##### IMPORT Object ##############
echo "ADD STPL Object"
read -p "Press any key to continue or CTRL-C to abort"
cat $1|awk -F";" '/^STPL;ADD;/ { print $0 }' | cut -d ";" -f 3-|while read i;do centreon -u admin -p centreon -o STPL -a ADD -v "${i}";done
cat $1|awk -F";" '/^STPL;ADD;/ { print $0 }' | cut -d ";" -f 3-|while read i;do centreon -u admin -p centreon -o STPL -a ADD -v "${i}";done

echo "================="
echo "setparam STPL Object"
read -p "Press any key to continue or CTRL-C to abort"
cat $1|awk -F";" '/^STPL;setparam;/ { print $0 }' | cut -d ";" -f 3-|while read i;do centreon -u admin -p centreon -o STPL -a ADD -v "${i}";done

echo "================="
echo "setmacro STPL Object"
read -p "Press any key to continue or CTRL-C to abort"
cat $1|awk -F";" '/^STPL;setmacro;/ { print $0 }' | cut -d ";" -f 3-|while read i;do centreon -u admin -p centreon -o STPL -a ADD -v "${i}";done

echo "END"
