#!/bin/bash

# ─── Health Monitor ───────────────────────────────────────
# Checks disk, memory, and CPU usage and alerts if too high
# Logs every report to a log file
# ──────────────────────────────────────────────────────────

# Thresholds
DISK_WARN=80
MEMORY_WARN=75
CPU_WARN=80

# Log file
LOG_FILE=~/projects/aws-health-monitor-s3-backup/logs/health.log

echo "==================================="
echo "      System Health Monitor        "
echo "           $(date)                 "
echo "==================================="

# 1. Disk Usage
disk=$(df / | tail -1 | awk '{print $5}' | tr -d '%')

echo -e "\nDisk Usage: ${disk}%"
if [[ $disk -ge $DISK_WARN ]]; then
  echo "WARNING: Disk Usage is ${disk}%, which is $((disk - DISK_WARN))% above the threshold."
else
  echo "OK: Disk Usage is ${disk}%, which is $((DISK_WARN - disk))% below the threshold."
fi

# 2. Memory Usage
mem=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100}')

echo -e "\nMemory Usage: ${mem}%"
if [[ $mem -ge $MEMORY_WARN ]]; then
  echo "WARNING: Memory Usage is ${mem}%, which is $((mem - MEMORY_WARN))% above the threshold."
else
  echo "OK: Memory Usage is ${mem}%, which is $((MEMORY_WARN - mem))% below the threshold."
fi

# 3. CPU Usage
cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)

echo -e "\nCPU Usage: ${cpu}%"
if [[ $cpu -ge $CPU_WARN ]]; then
  echo "WARNING: CPU Usage is ${cpu}%, which is $((cpu - CPU_WARN))% above the threshold."
else
  echo "OK: CPU Usage is ${cpu}%, which is $((CPU_WARN - cpu))% below the threshold."
fi

echo -e "\n==================================="
echo ""
echo "===================================="
echo "            End of Report           "
echo "===================================="

# Save to log
echo "$(date) | Disk=${disk}% | Mem=${mem}% | CPU=${cpu}%" >> $LOG_FILE