#!/bin/bash

login_page() {
  credentials=$(zenity --forms \
    --title="Login" \
    --text="Enter your credentials" \
    --add-entry="Username" \
    --add-password="Password" \
    --width=300)

  if [ $? -ne 0 ]; then
    exit 0
  fi

  username=$(echo "$credentials" | awk -F'|' '{print $1}')
  password=$(echo "$credentials" | awk -F'|' '{print $2}')

  if [[ "$username" == "admin" && "$password" == "password" ]]; then
    zenity --info --text="Login successful!" --width=300
  else
    zenity --error --text="Invalid credentials. Try again!" --width=300
    login_page # Retry login
  fi
}


choose_mode() {
  mode=$(zenity --list \
    --title="Select Mode" \
    --text="Choose how to interact with the system:" \
    --column="Mode" \
    "GUI" "Console" \
    --width=300 --height=200)

  if [[ "$mode" == "Console" ]]; then
    echo "Console mode selected."
    bash project_os.sh  # Execute the second script
  else
    echo "GUI mode selected."
    main_menu
  fi
}


login_page


display_table() {
  zenity --list \
    --title="$2" \
    --text="$3" \
    --column="Metric" \
    --column="Value" \
    $1 \
    --width=600 \
    --height=400
}


get_cpu_info() {
  cpu_usage=$(mpstat 1 1 | awk '/Average/ {print $3 "%"}' | tee -a /home/abdelrahman2274/Desktop/cpu_gui_record.txt)
  cpu_temp=$(sensors | grep "Core"| awk '{print $3}' | head -n 1 | tee -a /home/abdelrahman2274/Desktop/cpu_gui_record.txt)
  echo "CPU-Usage" "$cpu_usage" "CPU-Temperature" "${cpu_temp:-N/A}"
}


get_memory_info() {
  total_mem=$(free -h | awk '/Mem:/ {print $2}' | tee -a /home/abdelrahman2274/Desktop/memory_gui_record.txt)
  used_mem=$(free -h | awk '/Mem:/ {print $3}' | tee -a /home/abdelrahman2274/Desktop/memory_gui_record.txt)
  free_mem=$(free -h | awk '/Mem:/ {print $4}' | tee -a /home/abdelrahman2274/Desktop/memory_gui_record.txt)
  echo "Total-Memory" "$total_mem" "Used-Memory" "$used_mem" "Free-Memory" "$free_mem"
}


get_disk_info() {
  disk_usage=$(df -h / | awk 'NR==2 {print $5}' | tee -a /home/abdelrahman2274/Desktop/disk_gui_record.txt)
  echo "Disk-Usage" "$disk_usage"
}


get_network_info() {
  interface=$(ip route show default | awk '/default/ {print $5}' | tee -a /home/abdelrahman2274/Desktop/network_gui_record.txt)
  rx_bytes=$(cat /sys/class/net/$interface/statistics/rx_bytes | tee -a /home/abdelrahman2274/Desktop/network_gui_record.txt)
  tx_bytes=$(cat /sys/class/net/$interface/statistics/tx_bytes | tee -a /home/abdelrahman2274/Desktop/network_gui_record.txt)
  echo "Interface" "$interface" "Received-Bytes" "$rx_bytes" "Transmitted-Bytes" "$tx_bytes"
}


get_gpu_info() {
  gpu_info=$(lspci | grep -i vga | awk -F: '{print $3}' | xargs | tee -a /home/abdelrahman2274/Desktop/gpu_gui_record.txt)
  echo "GPU-Info" "${gpu_info:-N/A}"
}

checkDiskUsage() {
    while true; do
        # List available disks using df and present them in a Zenity list
        disks=$(df -h | awk 'NR>1 {print $1}' | sed 's/ /|/g' | tee -a /home/abdelrahman2274/Desktop/disks_gui_record.txt)
        chosen_disk=$(echo "$disks" | zenity --list \
            --title="Disk Usage and SMART Status" \
            --text="Select a disk to view details:" \
            --column="Disk" \
            --width=600 --height=400)

        if [ -z "$chosen_disk" ]; then

            break
        fi

       chosen_disk_name=$(echo "$chosen_disk" | awk -F'|' '{print $1}' | tee -a /home/abdelrahman2274/Desktop/smart_tool_gui_record.txt)

        while true; do
            disk_usage=$(df -h | grep "$chosen_disk_name" | awk '{printf "Disk: %s\nUsed: %s / %s\nAvailable: %s\nUse%%: %s", $1, $3, $2, $4, $5}' | tee -a /home/abdelrahman2274/Desktop/smart_tool_gui_record.txt)

            smart_status=$(sudo smartctl -H "$chosen_disk" | grep -i 'health' | awk '{print $6}' | tee -a /home/abdelrahman2274/Desktop/smart_tool_gui_record.txt)

            smart_message=""
            if [ "$smart_status" == "PASSED" ]; then
                smart_message="SMART Status: Your drive is perfectly fine :D"
            else
                smart_message="SMART Status: Issues detected"
            fi


            zenity --info \
                --title="Disk and SMART Status" \
                --text="${disk_usage}\n${smart_message}" \
                --width=400 --height=300

            choice=$(zenity --question \
                --title="Return to Disk Selection?" \
                --text="Do you want to select another disk?" \
                --ok-label="Yes" --cancel-label="No")

            if [ $? -ne 0 ]; then
                break
            fi
        done
    done
}

get_system_load() {
  choice=$(zenity --list \
    --title="System Load Metrics" \
    --text="Select an option for system load metrics:" \
    --column="Option" \
    "Uptime and Load Averages" "Top Processes" \
    --width=400 --height=300)

  case "$choice" in
    "Uptime and Load Averages")
      uptime  | tee -a /home/abdelrahman2274/Desktop/uptime_and_load_avg_gui_record.txt | zenity --text-info --title="Uptime and Load Averages" --width=600 --height=400
      ;;
    "Top Processes")
      top -b -n 1 | head -15  | tee -a /home/abdelrahman2274/Desktop/ls_top_ps_gui_record.txt | zenity --text-info --title="Top Processes" --width=600 --height=400
      ;;
  esac
}

list_processes() {
  processes=$(ps -eo pid,comm,%mem,%cpu --sort=-%cpu | awk 'NR==1 {printf "%-8s %-20s %-10s %-10s\n", "PID", "COMMAND", "%MEM", "%CPU"} NR>1 {printf "%-8s %-20s %-10s %-10s\n", $1, $2, $3"%", $4"%"}' | tee -a /home/abdelrahman2274/Desktop/ls_ps_gui_record.txt)
  
  selected_process=$(zenity --list \
    --title="Process Manager" \
    --text="Select a process to inspect or terminate (if needed):" \
    --column="PID" --column="Command" --column="%MEM" --column="%CPU" \
    $(ps -eo pid,comm,%mem,%cpu --sort=-%cpu | awk 'NR>1 {print $1, $2, $3"%", $4"%"}') \
    --width=800 --height=600)

  if [ $? -eq 0 ] && [ -n "$selected_process" ]; then
    zenity --question --title="Terminate Process" --text="Do you want to terminate process $selected_process?"
    if [ $? -eq 0 ]; then
      kill -9 "$selected_process" && zenity --info --text="Process $selected_process terminated."
      
    fi
  fi
}

get_all_graph() {
    echo "Generating full system report..."
    python3 /home/abdelrahman2274/Desktop/code_python.py 
    zenity --info --text="Report generated and saved successfully." --width=300
}



main_menu() {
  while true; do
    choice=$(zenity --list \
      --title="System Monitoring" \
      --text="Select an option:" \
      --column="Option" \
      "CPU Info" "Memory Info" "Disk Info" "Network Info" "GPU Info" "SMART Status" "System Load Metrics" "List Processes" "All information" "Graph"  "Exit" \
      --width=400 \
      --height=300)

    case "$choice" in
      "CPU Info")
        cpu_info=$(get_cpu_info)
        display_table "$cpu_info" "CPU Information" "Detailed CPU Metrics"
        ;;
      "Memory Info")
        memory_info=$(get_memory_info)
        display_table "$memory_info" "Memory Information" "Detailed Memory Metrics"
        ;;
      "Disk Info")
        disk_info=$(get_disk_info)
        display_table "$disk_info" "Disk Information" "Detailed Disk Metrics"
        ;;
      "Network Info")
        network_info=$(get_network_info)
        display_table "$network_info" "Network Information" "Detailed Network Metrics"
        ;;
      "GPU Info")
        gpu_info=$(get_gpu_info)
        display_table "$gpu_info" "GPU Information" "Detailed GPU Metrics"
        ;;
      "SMART Status")
        checkDiskUsage
        ;;
      "System Load Metrics")
        get_system_load
        ;;
      "List Processes")
        list_processes
	;;
      "Graph")
    	python3 /home/abdelrahman2274/Desktop/code_python.py | tee -a  /home/abdelrahman2274/Desktop/ls_top_ps_gui_record.txt
    	if [ $? -eq 0 ]; then
        zenity --info --text="Report generated successfully. Check /home/abdelrahman2274/Desktop/report_python.txt." 	--width=400 
    	else
        zenity --error --text="Failed to generate report. Please check the logs." --width=400
    	fi
    	;;    "Exit")
        exit 0
        ;;
      *) 
        continue
        ;;
    esac
  done
}

choose_mode
