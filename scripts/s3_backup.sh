#!/bin/bash

# ─── Health Monitor + S3 Backup Pipeline ─────────────────
# 1. Runs health monitor and uploads log to S3 every run
# 2. Only backs up health_monitor.sh to S3 if it changed
# Scheduled monthly with cron
# ──────────────────────────────────────────────────────

# Config
SCRIPT_DIR=~/projects/aws-health-monitor-s3-backup/scripts
LOG_DIR=~/projects/aws-health-monitor-s3-backup/logs
BUCKET="vp-cloud-backups-2026"
TIMESTAMP=$(date +"%Y-%m-%d")
CHECKSUM_FILE=$LOG_DIR/health_monitor.md5
LOG_FILE=$LOG_DIR/health.log

mkdir -p $LOG_DIR

echo "=============================="
echo " Health Monitor + S3 Backup"
echo " $(date)"
echo "=============================="

# ── Step 1: Run health monitor ──
echo ""
echo "Running health monitor..."
bash $SCRIPT_DIR/health_monitor.sh
echo "Health monitor complete"

# ── Step 2: Upload health log to S3 ──
echo ""
echo "Uploading health log to S3..."
aws s3 cp $LOG_FILE s3://$BUCKET/health-reports/health_$TIMESTAMP.log

if [ $? -eq 0 ]; then
  echo "  OK: health log uploaded to s3://$BUCKET/health-reports/"
else
  echo "  ERROR: health log upload failed"
fi

# ── Step 3: Check if health_monitor.sh changed ──
echo ""
echo "Checking if health_monitor.sh changed..."

current_checksum=$(md5sum $SCRIPT_DIR/health_monitor.sh | awk '{print $1}')
last_checksum=$(cat $CHECKSUM_FILE 2>/dev/null)

if [ "$current_checksum" == "$last_checksum" ]; then
  echo "  health_monitor.sh unchanged — skipping S3 backup"
else
  echo "  health_monitor.sh changed — backing up to S3..."
  BACKUP_FILE="/tmp/health_monitor_$TIMESTAMP.tar.gz"
  tar -czf $BACKUP_FILE $SCRIPT_DIR/health_monitor.sh 2>/dev/null

  aws s3 cp $BACKUP_FILE s3://$BUCKET/scripts/

  if [ $? -eq 0 ]; then
    echo "  OK: health_monitor.sh backed up to s3://$BUCKET/scripts/"
    echo $current_checksum > $CHECKSUM_FILE
    echo "  Checksum updated"
  else
    echo "  ERROR: script backup failed"
  fi

  rm -f $BACKUP_FILE
fi

echo ""
echo "=============================="
echo " Pipeline Complete"
echo " $(date)"
echo "=============================="