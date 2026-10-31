# AWS Health Monitor + S3 Backup Pipeline

An automated bash pipeline that checks a server's health, archives the results to AWS S3, and only backs up its own script when the code actually changes. It runs once a month through cron with no manual steps.

### ▶️ Watch the demo

**[Full video walkthrough on YouTube](YOUR_YOUTUBE_LINK_HERE)**

The video shows the whole pipeline running live on an AWS EC2 instance, from SSH and file transfer through the S3 upload and cron setup.

---

## At a glance

| | |
|---|---|
| **What it does** | Monitors CPU, memory, and disk, then archives timestamped health reports to S3 |
| **Schedule** | Automatically on the 1st of every month at 9am via cron |
| **Smart backups** | MD5 checksum change detection, so the script is only backed up when it is modified |
| **Built with** | Bash, AWS CLI, cron, AWS S3, AWS EC2 |
| **Cost** | $0 within the AWS free tier |

---

## How it works

```
Cron (1st of every month, 9am)
│
▼
s3_backup.sh
│
┌───────────┴────────────┐
▼ ▼
health_monitor.sh Checksum check
CPU · Memory · Disk on health_monitor.sh
│ │
▼ ┌──────┴───────┐
Timestamped log ▼ ▼
uploaded to S3 Changed Unchanged
compress + skip, nothing
back up uploaded
```

---

## Features

**Fully automated.** One cron entry triggers the whole pipeline. After setup there is nothing to run by hand.

**Health monitoring with thresholds.** CPU, memory, and disk usage are each compared against a threshold. The report shows how far above or below the limit each metric sits.

**Historical archive in S3.** Every run uploads a dated health report, which builds a month-by-month record of how the server is performing.

**Change detection with MD5 checksums.** The monitoring script is only compressed and uploaded when its contents change. Unchanged scripts are skipped.

**Two cadences, one pipeline.** Health data uploads every run because it is always new. The script backup only happens when the code changes.

---

## Sample output

```
==============================
Health Monitor + S3 Backup
==============================

Running health monitor...

Disk Usage: 1%
OK: Disk Usage is 1%, which is 79% below the threshold.

Memory Usage: 11%
OK: Memory Usage is 11%, which is 64% below the threshold.

CPU Usage: 0%
OK: CPU Usage is 0%, which is 80% below the threshold.

Uploading health log to S3...
OK: health log uploaded to s3://<bucket>/health-reports/

Checking if health_monitor.sh changed...
health_monitor.sh unchanged — skipping S3 backup

==============================
Pipeline Complete
==============================
```

---

## What ends up in S3

```
your-bucket/
├── health-reports/
│ ├── health_2026-09-29.log
│ ├── health_2026-10-01.log
│ └── health_2026-11-01.log
└── scripts/
└── health_monitor_<date>.tar.gz ← only written when the script changes
```

---

## Deployment

**Demonstrated on AWS EC2.** The pipeline was deployed to a fresh Ubuntu instance over SSH, with scripts transferred via SCP and the AWS CLI configured on the instance. It ran end to end and its output was confirmed in S3. This is the part covered in the video.

**Runs for free on WSL2.** After the demo the EC2 instance was terminated. The same scripts now run on a local WSL2 environment with the same S3 integration, so ongoing use costs nothing.

---

## Skills demonstrated

- Bash scripting with functions, conditionals, and exit-code handling
- Cron job scheduling
- AWS CLI automation against S3
- File integrity checking with checksums
- Deploying to and managing an EC2 instance over SSH/SCP
- Cost-conscious cloud practices: free tier usage and tearing down unused resources

---

## Related project

**[AWS Cloud Security Audit](https://github.com/Vishwa09132006/aws-security-audit)** is an automated security scanner for AWS accounts, with GitHub Actions scheduling and SNS email alerts.

---

## Roadmap

- [ ] SNS email alert when a health metric crosses its threshold
- [ ] Automatic cleanup of old local logs
- [ ] Containerize the pipeline with Docker
- [ ] Rebuild the infrastructure with Terraform

---

## Feedback

Found a bug or have a suggestion? Open an issue in this repo.

**Connect with me:** [Vishwa Patel on LinkedIn](https://www.linkedin.com/in/vishwa-patel-31a237355)

---

*Built by Vishwa Patel, CS student at CUNY Queens College, as part of a self-directed cloud engineering roadmap.*
