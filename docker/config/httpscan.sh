#!/bin/bash

# Configuration
LOG_DIR="/path/to/logs"  # Replace with your log directory
LOG_PATTERN="Http-*.log"
MINUTES=10

# Calculate the timestamp from 10 minutes ago
PAST_TIME=$(date -d "$MINUTES minutes ago" +"%d/%b/%Y:%H:%M:%S")

# Function to convert Apache timestamp to Unix timestamp
apache_to_unix_timestamp() {
    local apache_time=$1
    date -d "${apache_time%% *}" +%s
}

# Get the cutoff timestamp in Unix format
cutoff_timestamp=$(date -d "$MINUTES minutes ago" +%s)

# Process logs and count response codes
{
    # Find and process all matching log files, sorted by modification time
    find "$LOG_DIR" -name "$LOG_PATTERN" -type f -mmin -${MINUTES} -print0 | \
    xargs -0 cat 2>/dev/null | \
    awk -v cutoff="$PAST_TIME" '
    BEGIN {
        # Initialize counters for response codes
        total = 0
    }
    
    {
        # Extract timestamp and response code
        match($0, /\[(.*?)\]/, timestamp)
        match($0, /" ([0-9]{3}) /, response_code)
        
        # Process only if we have both timestamp and response code
        if (timestamp[1] && response_code[1]) {
            # Compare timestamps
            if (timestamp[1] >= cutoff) {
                code = response_code[1]
                codes[code]++
                total++
            }
        }
    }
    
    END {
        # Print summary
        print "\nHTTP Response Code Summary (Last " ENVIRON["MINUTES"] " minutes):"
        print "----------------------------------------"
        print "Total requests processed:", total
        print "\nResponse Code Distribution:"
        for (code in codes) {
            percentage = (codes[code] / total) * 100
            printf "%s: %d (%.1f%%)\n", code, codes[code], percentage
        }
        
        # Alert on high error rates
        error_count = 0
        for (code in codes) {
            if (code >= 500) {
                error_count += codes[code]
            }
        }
        if (error_count > 0) {
            error_rate = (error_count / total) * 100
            if (error_rate > 5) {
                print "\nALERT: High error rate detected!"
                printf "%.1f%% of requests are returning 5xx errors\n", error_rate
            }
        }
    }
    '
} 2>/dev/null

# Check if script executed successfully
if [ $? -ne 0 ]; then
    echo "Error: Failed to process log files. Please check permissions and paths."
    exit 1
fi
