#!/bin/bash

GHOSTUSER=ghostly
GHOSTUSER_PASS=password
MYSQL_ROOT_PASS=password
NODE_MAJOR=20
INSTALL_DIR=/var/www/ghost

set -e

# Install PreReq Packages
apt update && apt install -y ca-certificates curl gnupg

# Create Ghost User
useradd -m -s /bin/bash "$GHOSTUSER"
echo "$GHOSTUSER:$GHOSTUSER_PASS" | chpasswd
usermod -aG sudo $GHOSTUSER

# Add Nodejs Repo
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

# Install Packages
apt update && apt install -y nginx mariadb-server nodejs

# Setup Ghost Root Directory
mkdir -p $INSTALL_DIR
chown $GHOSTUSER:$GHOSTUSER $INSTALL_DIR
chmod 755 $INSTALL_DIR

# Set MYSQL Root Password
mysql -fsu root <<EOF
USE mysql;
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASS';
FLUSH PRIVILEGES;
EOF

# Install Ghost-CLI with npm
npm install ghost-cli@latest -g

echo "Install complete. Login as user then move to $INSTALL_DIR and run following: ghost install"
echo "You will complete the install from cmdline there"
