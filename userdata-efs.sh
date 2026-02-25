#!/bin/bash
set -euo pipefail

EFS_ID="${efs_id}"
AWS_REGION="${aws_region}"
WP_ROOT="${wp_root}"
WP_CONTENT_DIR="$WP_ROOT/wp-content"
EFS_MNT="/mnt/efs"

if command -v yum >/dev/null 2>&1; then
  yum -y install amazon-efs-utils || true
  yum -y install nfs-utils || true
elif command -v apt-get >/dev/null 2>&1; then
  apt-get update -y || true
  apt-get install -y nfs-common || true
fi

mkdir -p "$EFS_MNT"
mkdir -p "$WP_CONTENT_DIR"

if command -v mount.efs >/dev/null 2>&1; then
  mount -t efs -o tls "$EFS_ID:/" "$EFS_MNT" || true
else
  mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 "$EFS_ID.efs.$AWS_REGION.amazonaws.com:/" "$EFS_MNT" || true
fi

if ! grep -q "$EFS_ID:" /etc/fstab; then
  if command -v mount.efs >/dev/null 2>&1; then
    echo "$EFS_ID:/ $EFS_MNT efs _netdev,tls 0 0" >> /etc/fstab
  else
    echo "$EFS_ID.efs.$AWS_REGION.amazonaws.com:/ $EFS_MNT nfs4 _netdev,nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0" >> /etc/fstab
  fi
fi

rsync -a "$WP_CONTENT_DIR/" "$EFS_MNT/" || true

if [ -d "$WP_CONTENT_DIR" ] && [ ! -L "$WP_CONTENT_DIR" ]; then
  mv "$WP_CONTENT_DIR" "$WP_CONTENT_DIR.bak.$(date +%s)" || true
fi

ln -sfn "$EFS_MNT" "$WP_CONTENT_DIR"

if id www-data >/dev/null 2>&1; then
  chown -R www-data:www-data "$EFS_MNT" || true
elif id apache >/dev/null 2>&1; then
  chown -R apache:apache "$EFS_MNT" || true
fi