rpm-ostree upgrade --reboot
rpm-ostree install --allow-inactive --assumeyes --reboot qemu-guest-agent

# Set static IP address and hostname
#!/bin/bash

# Function to list network interfaces excluding the loopback interface
list_interfaces() {
    ip -o link show | awk -F': ' '{print $2}' | grep -v lo
}

# Prompt user to select a network interface
echo "Available network interfaces:"
interfaces=($(list_interfaces))
select interface in "${interfaces[@]}"; do
    if [[ -n "$interface" ]]; then
        echo "You selected interface: $interface"
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

# Prompt user for the desired hostname
read -p "Enter the desired hostname: " hostname

# Prompt user for the static IP configuration
read -p "Enter the desired static IP address (e.g., 192.168.1.100/24): " ip_address
read -p "Enter the gateway IP address (e.g., 192.168.1.1): " gateway
read -p "Enter DNS servers (e.g., 8.8.8.8 8.8.4.4): " dns_servers

# Set the hostname
hostnamectl set-hostname "$hostname"
echo "Hostname set to $hostname"

# Configure the static IP address using nmcli
nmcli connection modify "$interface" ipv4.addresses "$ip_address" ipv4.gateway "$gateway" ipv4.dns "$dns_servers" ipv4.method manual

# Bring the connection down and up to apply changes
nmcli connection down "$interface"
nmcli connection up "$interface"

echo "Network interface $interface configured with static IP $ip_address"

# Configure auto uopdates
echo AutomaticUpdatePolicy=apply | tee -a /etc/rpm-ostreed.conf
rpm-ostree reload
systemctl edit --force --full rpm-ostreed-automatic.timer # Change to however many days
systemctl enable rpm-ostreed-automatic.timer --now
# Disable zezere
rpm-ostree kargs --delete-if-present='$ignition_firstboot' # https://github.com/fedora-iot/iot-distro/issues/14
systemctl disable zezere_ignition.timer --now
