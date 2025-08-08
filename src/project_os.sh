#!/bin/bash

#console


#echo -e "\t\tWelcome to Resources System !!"
#echo -e "\t\t===========login page==========="
#echo -e "\t===========Please enter your User name and password===========\n" 
#read -p "Please enter your username : " username
#read -sp "Please enter your password : " password

#correct_us="abdo"
#correct_pass="password"

#if [[ "$correct_us" == "$username" && "$correct_pass" == "$password" ]]; then
echo -e "\t\tyou have 9 options to show\n\t1-Cpu Usage\n\t2-Memory Managment\n\t3-Disk Usage\n\t4-Network Usage\n\t5-Gpu information\n\t6-Smart status\n\t7-System load metrics\n\t8-Listing processes\n\t9-Cpu and Gpu Temperature\n\t10-All\n"

echo -e "\tIf you input 1 >> Cpu Usage" 
echo -e "\tIf you input 2 >> Memory Managment" 
echo -e "\tIf you input 3 >> Disk Usage" 
echo -e "\tIf you input 4 >> Network Usage" 
echo -e "\tIf you input 5 >> Gpu information"
echo -e "\tIf you input 6 >> Smart status"
echo -e "\tIf you input 7 >> System load metrics"
echo -e "\tIf you input 8 >> Listing processes"
echo -e "\tIf you input 9 >> Cpu and Gpu Temperature"
echo -e "\tIf you input 10 >> All"
echo -e "\tIf you input Q >> Quit" 



	checkDiskUsage(){
    #clear
    echo "Disk Usage and SMART Status"
        echo "---------------------------"
        number_of_disks=$(($(df -h | wc -l)-1))
        echo "Disks available on machine: "
        disks=($(df -h | awk '{print $1}' | tail -$number_of_disks))
        for i in "${!disks[@]}"; do
            echo $(($i+1))-${disks[$i]}
        done
        echo "---------------------------"
        echo "Please choose a disk (1-$number_of_disks)"
        read chosen_disk_number
        chosen_disk=${disks[$(($chosen_disk_number-1))]}
        

    while true; do
        clear
        df -h | grep -m 1 "$chosen_disk" | awk '{print "Disk: " $1 "\nUsed: " $3 " / " $2 "\nAvailable: " $4 "\nUse%: " $5}'

        SMART_STATUS=$(sudo smartctl -H "$chosen_disk" | grep -i 'health' | awk '{print $6}')

        if [[ "$SMART_STATUS" == "PASSED" ]]; then
            echo "SMART Status: Your drive is perfectly fine :D"
        else
            echo "SMART Status: Issues detected"
        fi
        
        echo -e "\nPress 'p' to go back to the main menu"
        read -t 1 -n 1 input
        if [[ $input == "p" ]]; then
            clear
            break
        fi
        sleep 2
    done
}

running=true
while $running
do
read -p "Please input number: " option

case $option in
1)
echo -e "Cpu usage and utilization : \n"
mpstat 1 1 | tee -a /home/abdelrahman2274/Desktop/cpu_record.txt
;;
2)
echo "Memory Managment : "
free -h | tee -a /home/abdelrahman2274/Desktop/memory_record.txt
;;
3)
echo "Disk Usage : "
df -h | tee -a /home/abdelrahman2274/Desktop/disk_record.txt
;;
4)
echo "Network Usage : "
echo -e "\t\nIp , Mask , Mac Address , etc ....\n"
iftop | tee -a /home/abdelrahman2274/Desktop/network_record.txt
sleep 1
echo -e "\t\nTraffic History ...\n"
vnstat | tee -a /home/abdelrahman2274/Desktop/network_record.txt
sleep 1
echo -e "\t\nReal time monitoring ...\n"
nload | tee -a /home/abdelrahman2274/Desktop/network_record.txt
sleep 1
;;

5)
	 echo -e  "inforamtion :\n"
	 lshw -C display | tee -a /home/abdelrahman2274/Desktop/gpu_record.txt
	 ;;
6)	
		checkDiskUsage | tee -a /home/abdelrahman2274/Desktop/smart_record.txt
;;

7)
		echo -e "System load metrics...\n"
		echo -e "\t1-Up time and current load averages\n\t2-top processes"
		read -p "Please enter your choice: " metricsoption
		case $metricsoption in
		1)
		echo -e "\tUptime"
		uptime | tee -a /home/abdelrahman2274/Desktop/system_load_metrics_record.txt
		;;
	2)
		echo -e "\tReal time stats(CPU usage, running processes, and load averages) the top processes !!!\n"
		top | tee -a /home/abdelrahman2274/Desktop/top_processes_record.txt
	;;
	*)
	echo "Invalid..."	
	;;
	esac
	;;

8)
	echo -e "\tlisting processes ..."
	ps aux | tee -a /home/abdelrahman2274/Desktop/listing_processes_record.txt
	;;

9)
	echo -e "Cpu Temperature : \n"
	lm-sensors | grep 'Cpu' | tee -a /home/abdelrahman2274/Desktop/cpu_temp.txt
	echo -e "Gpu Temperature : \n"
	lm-sensors | grep 'Gpu' | tee -a /home/abdelrahman2274/Desktop/gpu_temp.txt
	;;

10)
	echo -e "Cpu usage and utilization : \n"
	mpstat | tee -a /home/abdelrahman2274/Desktop/cpu_record.txt

	echo "Memory Managment : "
	free -h | tee -a /home/abdelrahman2274/Desktop/memory_record.txt

	echo "Disk Usage : "
	df -h | tee -a /home/abdelrahman2274/Desktop/disk_record.txt

	echo "Network Usage : "
	echo -e "\t\nIp , Mask , Mac Address , etc ....\n"
	iftop | tee -a /home/abdelrahman2274/Desktop/network_record.txt
	echo -e "\t\nTraffic History ...\n"
	vnstat | tee -a /home/abdelrahman2274/Desktop/network_record.txt
	echo -e "\t\nReal time monitoring ...\n"
	nload | tee -a /home/abdelrahman2274/Desktop/network_record.txt
	
	echo "Gpu information : "
	lshw -C display | tee -a /home/abdelrahman2274/Desktop/gpu_record.txt

	echo "System load metrics"
	uptime | tee -a /home/abdelrahman2274/Desktop/system_load_metrics_record.txt
    	top | tee -a /home/abdelrahman2274/Desktop/top_processes_record.txt

	echo -e "\tlisting processes ..."
    	ps aux | tee -a /home/abdelrahman2274/Desktop/listing_processes_record.txt

	echo -e "Cpu Temperature : \n"
    lm-sensors | grep 'Cpu' | tee -a /home/abdelrahman2274/Desktop/cpu_temp.txt
    echo -e "Gpu Temperature : \n"
    lm-sensors | grep 'Gpu' | tee -a /home/abdelrahman2274/Desktop/gpu_temp.txt

;;
[Qq])
	echo "quitting ...."
	exit 1
	;;
*)
	echo "Invalid input"
	;;

esac
done
done
else

#	echo -e "\nInvalid username or password ...."
#	exit 1
#fi
