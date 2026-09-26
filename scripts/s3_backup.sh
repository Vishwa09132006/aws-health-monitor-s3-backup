#!/bin/bash

# ─── S3 Backup Script ─────────────────────────────────────
# Compresses health_monitor.sh and uploads it to S3
# Also uploads the health log to S3
# ──────────────────────────────────────────────────────────

# Config
HEALTH_SCRIPT=~/bash_scripts/health_monitor.sh
HEALTH_LOG=~/bash_scripts/logs/health.log
BUCKET="vp-cloud-backups-2026"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
BACKUP_FILE="/tmp/health_monitor_$TIMESTAMP.tar.gz"
LOG_FILE=~/bash_scripts/logs/s3_backup.log

mkdir -p ~/bash_scripts/logs

echo "=============================="
echo " S3 Backup Script"
echo " $(date)"
echo "=============================="

# ── Step 1: Compress health_monitor.sh ──
echo ""
echo "Compressing health_monitor.sh..."
tar -czf $BACKUP_FILE $HEALTH_SCRIPT 2>/dev/null

if [ $? -eq 0 ]; then
  size=$(du -sh $BACKUP_FILE | awk '{print $1}')
  echo "  OK: Compressed — $BACKUP_FILE ($size)"
else
  echo "  ERROR: Compression failed"
  echo "$(date) | ERROR | Compression failed" >> $LOG_FILE
  exit 1
fi

# ── Step 2: Upload compressed script to S3 ──
echo ""
echo "Uploading health_monitor.sh to S3..."
aws s3 cp $BACKUP_FILE s3://$BUCKET/backups/

if [ $? -eq 0 ]; then
  echo "  OK: Uploaded to s3://$BUCKET/backups/"
  echo "$(date) | OK | Uploaded $BACKUP_FILE to s3://$BUCKET/backups/" >> $LOG_FILE
else
  echo "  ERROR: Upload failed"
  echo "$(date) | ERROR | Upload failed for $BACKUP_FILE" >> $LOG_FILE
  exit 1
fi

# ── Step 3: Upload health log to S3 ──
echo ""
echo "Uploading health.log to S3..."
aws s3 cp $HEALTH_LOG s3://$BUCKET/logs/health.log

if [ $? -eq 0 ]; then
  echo "  OK: health.log uploaded to s3://$BUCKET/logs/"
  echo "$(date) | OK | Uploaded health.log to s3://$BUCKET/logs/" >> $LOG_FILE
else
  echo "  ERROR: Log upload failed"
  echo "$(date) | ERROR | health.log upload failed" >> $LOG_FILE
  exit 1
fi

# ── Step 4: Clean up local temp file ──
rm $BACKUP_FILE
echo ""
echo "  Cleaned up local temp file"

# ── Step 5: Show current S3 contents ──
echo ""
echo "Current backups in S3:"
aws s3 ls s3://$BUCKET/backups/
echo ""
echo "Current logs in S3:"
aws s3 ls s3://$BUCKET/logs/

echo ""
echo "=============================="
echo " Backup Complete"
echo "=============================="
