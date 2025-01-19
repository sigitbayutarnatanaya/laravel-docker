#!/bin/bash

# Create a new chain for SSH protection
iptables -N SSH_PROTECTION

# Move SSH traffic to the new chain
iptables -A INPUT -p tcp --dport 22 -j SSH_PROTECTION

# Allow established connections
iptables -A SSH_PROTECTION -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Block IPs with more than 5 attempts within 60 seconds
iptables -A SSH_PROTECTION -m recent --name SSH --set
iptables -A SSH_PROTECTION -m recent --name SSH --update --seconds 60 --hitcount 5 -j DROP

# Return to the INPUT chain
iptables -A SSH_PROTECTION -j ACCEPT

# Log blocked attempts
iptables -A SSH_PROTECTION -j LOG --log-prefix "SSH_BRUTE_FORCE_ATTEMPT: " --log-level 7

# Save iptables rules
iptables-save > /etc/iptables/rules.v4

# Create a monitoring script
cat > /usr/local/bin/monitor_ssh.sh << 'EOF'
#!/bin/bash

tail -f /var/log/auth.log | while read line; do
    if echo "$line" | grep "Failed password" > /dev/null; then
        ip=$(echo "$line" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
        echo "$(date): Failed SSH attempt from $ip" >> /var/log/ssh_attempts.log
    fi
done
EOF

chmod +x /usr/local/bin/monitor_ssh.sh

# Add to system startup
echo "@reboot /usr/local/bin/monitor_ssh.sh" | crontab -