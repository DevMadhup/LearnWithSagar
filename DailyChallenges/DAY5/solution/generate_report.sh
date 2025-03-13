#!/bin/bash

# Initialize variables
LOG_FILE="user_activity.log"

# Check if user is root
if [[ "${UID}" != "0" ]]
then
        echo "Error! Run as a root user"
        exit -1
fi

# Extract Unique IP Addresses
echo "Extracting Unique IP Addresses..."
awk '{
   for(i=1;i<=NF;i++){
           if($i ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/){
                   split($i, octets, ".")
                   if (octets[1] <= 255 && octets[2] <= 255 && octets[3] <= 255 && octets[4] <= 255){
                        print "IPv4 address: "$i
                   }
           }
          else if($i ~ /^[0-9a-fA-F:]+$/){
            if(gsub(/:/, ":", $i) >=2){
                 print "IPv6 address: "$i
            }
          }
   }
  }' "${LOG_FILE}" | sort -u > unique_ips.txt

echo "Unique IPs saved to unique_ips.txt."

# Extract Usernames 
echo "Extracting Usernames..."
awk '{
        for(i=1;i<=NF;i++){
                if($i ~ /^user[0-9]+$/){
                  print $i
                }
        }
}' "${LOG_FILE}" | sort -u > usernames.txt

echo "Usernames saved to usernames.txt."

# Count HTTP Status Codes
echo "Counting HTTP status codes..."
awk '{
        if($(NF) ~ /^[0-9]+$/){
                status[$(NF)]++
        }
        } END {
          for(code in status){
            print code, status[code]
          }

}' "${LOG_FILE}" | sort -n > http_counts.txt

echo "http counts saved to http_counts.txt"

# Identify Failed Login Attempts
echo "Identify failed login attempts"
awk '{
        if($(NF) == "403"){
        for(i=1;i<=NF;i++){
           if($i ~ /\[.*\]/){
            timestamp = $i
            break
          }
         }
        print timestamp, $0
        }
}' "$LOG_FILE" | sort -n > failed_login.txt

echo "failed login attempts saved to failed_login.txt"


# Generate a Summary Report
