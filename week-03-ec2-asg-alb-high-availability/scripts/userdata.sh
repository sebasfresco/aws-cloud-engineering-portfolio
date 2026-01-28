#!/bin/bash
set -eux

dnf -y update
dnf -y install httpd
systemctl enable --now httpd

TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/placement/availability-zone)

cat > /var/www/html/index.html <<EOF
<h1>EC2 Web Server (Amazon Linux 2023)</h1>
<p><b>Instance ID:</b> ${INSTANCE_ID}</p>
<p><b>Availability Zone:</b> ${AZ}</p>
EOF
