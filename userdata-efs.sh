#!/bin/bash
set -euo pipefail

EFS_ID="${efs_id}"
AWS_REGION="${aws_region}"
WP_ROOT="${wp_root}"
WP_CONTENT_DIR="$WP_ROOT/wp-content"
EFS_MNT="/mnt/efs"

# --- Install web stack (Amazon Linux 2) ---
if command -v yum >/dev/null 2>&1; then
  yum update -y
  amazon-linux-extras enable php8.0 || true
  yum clean metadata
  yum install -y httpd php php-mysqlnd wget tar rsync amazon-efs-utils nfs-utils
  systemctl enable --now httpd
elif command -v apt-get >/dev/null 2>&1; then
  apt-get update -y
  apt-get install -y apache2 php php-mysql rsync nfs-common
  systemctl enable --now apache2
fi

# --- Mount EFS ---
mkdir -p "$EFS_MNT"
mkdir -p "$WP_ROOT"
mkdir -p "$WP_CONTENT_DIR"

if command -v mount.efs >/dev/null 2>&1; then
  mount -t efs -o tls "$EFS_ID:/" "$EFS_MNT"
else
  mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 \
    "$EFS_ID.efs.$AWS_REGION.amazonaws.com:/" "$EFS_MNT"
fi

# Persist mount
if ! grep -q "$EFS_MNT" /etc/fstab; then
  if command -v mount.efs >/dev/null 2>&1; then
    echo "$EFS_ID:/ $EFS_MNT efs _netdev,tls 0 0" >> /etc/fstab
  else
    echo "$EFS_ID.efs.$AWS_REGION.amazonaws.com:/ $EFS_MNT nfs4 _netdev,nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0" >> /etc/fstab
  fi
fi

# --- Make wp-content live on EFS ---
# backup existing content then sync to EFS once
if [ -d "$WP_CONTENT_DIR" ] && [ ! -L "$WP_CONTENT_DIR" ]; then
  rsync -a "$WP_CONTENT_DIR/" "$EFS_MNT/" || true
  mv "$WP_CONTENT_DIR" "$WP_CONTENT_DIR.bak.$(date +%s)" || true
fi

ln -sfn "$EFS_MNT" "$WP_CONTENT_DIR"

# Ownership
if id www-data >/dev/null 2>&1; then
  chown -R www-data:www-data "$EFS_MNT" || true
elif id apache >/dev/null 2>&1; then
  chown -R apache:apache "$EFS_MNT" || true
fi

# Quick sanity: ensure port 80 responds (optional)
echo "OK" > /var/www/html/index.html
curl -I http://localhost/ || true