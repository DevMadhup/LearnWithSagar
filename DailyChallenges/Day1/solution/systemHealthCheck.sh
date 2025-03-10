#!/bin/bash

# Check if the user is root or not
if [[ "${UID}" !=  "0" ]]
then
        echo "Error! Switch to root user to run..."
        exit -1
fi

# Variables
REPORT_FILE="/home/ubuntu/REPORT.txt"
EMAIL="devmadhupp@gmail.com"

# Add Debug
#DEBUG=true

#if [[ "${DEBUG}" == "true" ]]
#then
#       set -x
#fi

# Check Disk Usage
disk_usage() {
        echo "================" > "REPORT.txt"
        echo "DISK USAGE" >> "REPORT.txt"
        echo "================" >> "REPORT.txt"
        df -h >> REPORT.txt
        echo "================"

}

# Monitor running service
monitor_service() {
        echo "================" >> "REPORT.txt"
        echo "RUNNING SERVICES" >> "REPORT.txt"
        echo "================" >> "REPORT.txt"
        systemctl list-units --type=service --state=running | awk '{print $1" = " $4 }' >> "REPORT.txt"
}

# Access memory
access_memory() {
        echo "================" >> "REPORT.txt"
        echo "SYSTEM MEMORY DETAILS" >> "REPORT.txt"
        echo "================" >> "REPORT.txt"
        free -h >> "REPORT.txt"
}

# Check CPU Usage
CPU_usage() {
        echo "================" >> "REPORT.txt"
        echo "CPU Usage" >> "REPORT.txt"
        echo "================" >> "REPORT.txt"
        top -b -n 1 | head -10 >> "REPORT.txt"
}

# Send Report via mail
send_mail () {
        if [[ ! -f "${REPORT_FILE}" ]]
        then
                echo "${REPORT_FILE} does not exists.."
                exit -1
        fi

# Create mail content
        local MAIL_CONTENT=$(cat <<EOF
Subject: Instance $hostname system health check
From: DevOps.DevMadhup@gmail.com
To: $EMAIL

$(hostname) system health:
$(cat "$REPORT_FILE")
EOF
)

# Send Mail using ssmtp
echo "${MAIL_CONTENT}" | ssmtp -v "$EMAIL" > /dev/null 2>&1

if [[ "${?}" == "0" ]]
then
        echo "Mail sent successfully"
else
        echo "Mail not sent.."
fi
}

# Create Menu
while true;
do
    echo "================================="
    echo "System Health Check Menu"
    echo "================================="
    echo ""
    echo "1. Check Disk Usage"
    echo "2. Monitor Running Services"
    echo "3. Assess Memory Usage"
    echo "4. Evaluate CPU Usage"
    echo "5. Send Comprehensive Report via Email"
    echo ""
    echo "================================="

echo "Choose one of the above monitoring option (1-6): "
read option

case $option in
        1)
                echo "===================="
                disk_usage
                echo "Successfully stored disk usage details in $REPORT_FILE file"
                echo "===================="
                ;;

        2)
                echo "==================="
                monitor_service
                echo "Successfully stored running services details in $REPORT_FILE file"
                ;;

        3)
                echo "==================="
                access_memory
                echo "Memory details stored in $REPORT_FILE file"
                ;;

        4)
                echo "==================="
                CPU_usage
                echo "CPU usage details stored in $REPORT_FILE file"
                ;;
        5)
                echo "===================="
                send_mail
                echo "===================="
                ;;

        *)
                echo "Invalid Option"
                ;;
esac

# Asking user to continue
echo "Do you want to continue (9) or exit (6): "
read action

if [[ ${action} == "9" ]]
then
        echo ""
elif [[ ${action} == "6" ]]
then
        echo "Exiting.. Good Bye!!"
        exit 0
fi
done
