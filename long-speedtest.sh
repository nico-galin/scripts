#!/bin/bash
#
# Continuous speed test logger using Ookla's speedtest CLI + jq for JSON parsing.
# Runs a test every INTERVAL seconds, logs results to CSV, and prints a live
# summary to the terminal.

LOGFILE=.output/speedtest_log.csv
INTERVAL_SECONDS=60  # 10 minutes

HEADER="Timestamp,Server Name,Ping (ms),Download (Mbps),Upload (Mbps),IP Address"

# Make sure jq is installed
if ! command -v jq &> /dev/null; then
  echo "Error: 'jq' is not installed. Install it with: brew install jq"
  exit 1
fi

# Make sure speedtest is installed
if ! command -v speedtest &> /dev/null; then
  echo "Error: 'speedtest' is not installed or not in PATH."
  exit 1
fi

# Create the log file and write the header only if it doesn't exist / is empty
if [ ! -f "$LOGFILE" ]; then
  touch "$LOGFILE"
  echo "Created $LOGFILE"
fi

if [ ! -s "$LOGFILE" ]; then
  echo "$HEADER" > "$LOGFILE"
fi

echo "=== Logging started at $(date '+%Y-%m-%d %H:%M:%S') ==="
echo "Writing to $LOGFILE, $((INTERVAL_SECONDS / 60)) minute intervals."
echo

while true; do
  TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

  echo "[$TIMESTAMP] Running speed test..."

  JSON=$(speedtest --format=json --accept-license --accept-gdpr 2>/dev/null)
 
  if [ -z "$JSON" ]; then
    echo "[$TIMESTAMP] Speedtest failed, skipping this run."
  else
    SERVER_NAME=$(echo "$JSON" | jq -r '.server.name // ""')
    PING=$(echo "$JSON" | jq -r '.ping.latency')
    DOWNLOAD=$(echo "$JSON" | jq -r '(.download.bandwidth * 8 / 1000000)')
    UPLOAD=$(echo "$JSON" | jq -r '(.upload.bandwidth * 8 / 1000000)')
    IP=$(echo "$JSON" | jq -r '.interface.externalIp // ""')
 
    # Round to 2 decimal places for readability
    PING=$(printf "%.2f" "$PING")
    DOWNLOAD=$(printf "%.2f" "$DOWNLOAD")
    UPLOAD=$(printf "%.2f" "$UPLOAD")
 
    echo "$TIMESTAMP,$SERVER_NAME,$PING,$DOWNLOAD,$UPLOAD,$IP" >> "$LOGFILE"
 
    echo "[$TIMESTAMP] Download: ${DOWNLOAD} Mbps | Upload: ${UPLOAD} Mbps | Ping: ${PING} ms"
  fi
 
  echo
  sleep "$INTERVAL_SECONDS"
done