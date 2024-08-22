#!/bin/bash
set -e

OS=$1
VER=$2

# Function to install packages
install_packages() {
    case $OS in
        Ubuntu|Debian)
            apt-get update && apt-get install -y "$@"
            ;;
        CentOS|Red\ Hat*)
            yum update -y && yum install -y "$@"
            ;;
        Amazon*)
            yum update -y && amazon-linux-extras install -y "$@"
            ;;
        *)
            echo "Unsupported distribution: $OS"
            exit 1
            ;;
    esac
}

# Install common tools
install_packages curl wget unzip htop tmux vim

# Set up a basic firewall
case $OS in
    Ubuntu|Debian)
        install_packages ufw
        ufw allow OpenSSH
        ufw --force enable
        ;;
    CentOS|Red\ Hat*|Amazon*)
        install_packages firewalld
        systemctl start firewalld
        systemctl enable firewalld
        firewall-cmd --permanent --add-service=ssh
        firewall-cmd --reload
        ;;
esac

# Configure automatic security updates
case $OS in
    Ubuntu|Debian)
        install_packages unattended-upgrades
        echo 'APT::Periodic::Update-Package-Lists "1";' > /etc/apt/apt.conf.d/20auto-upgrades
        echo 'APT::Periodic::Unattended-Upgrade "1";' >> /etc/apt/apt.conf.d/20auto-upgrades
        ;;
    CentOS|Red\ Hat*|Amazon*)
        install_packages yum-cron
        systemctl enable yum-cron
        systemctl start yum-cron
        ;;
esac

# Any other common setup tasks...

echo "Main setup complete!"
