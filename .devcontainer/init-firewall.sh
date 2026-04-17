#!/bin/bash
set -euo pipefail

CONF="/etc/claude-sandbox/allowed-domains.conf"

echo "=== Initializing container firewall ==="

# hash:net supports both single IPs and CIDR ranges (GitHub)
ipset create allowed-domains hash:net -exist
ipset flush allowed-domains

# Resolve domains from config
if [[ -f "$CONF" ]]; then
    while IFS= read -r domain; do
        [[ -z "$domain" || "$domain" =~ ^# ]] && continue
        domain=$(echo "$domain" | xargs)
        ips=$(dig +short "$domain" 2>/dev/null | grep -E '^[0-9]+\.' || true)
        for ip in $ips; do
            ipset add allowed-domains "$ip" -exist
        done
    done < "$CONF"
fi

# GitHub (dynamic CIDR ranges from API)
GITHUB_META=$(curl -sf https://api.github.com/meta 2>/dev/null || echo '{}')
for key in web git api; do
    echo "$GITHUB_META" | jq -r ".${key}[]? // empty" 2>/dev/null | while read -r cidr; do
        ipset add allowed-domains "$cidr" -exist 2>/dev/null || true
    done
done

iptables -F OUTPUT 2>/dev/null || true
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT
iptables -A OUTPUT -d 172.16.0.0/12 -j ACCEPT
iptables -A OUTPUT -d 192.168.0.0/16 -j ACCEPT
iptables -A OUTPUT -d 10.0.0.0/8 -j ACCEPT
iptables -A OUTPUT -d 100.64.0.0/10 -j ACCEPT
iptables -A OUTPUT -m set --match-set allowed-domains dst -j ACCEPT
iptables -P OUTPUT DROP

echo "=== Firewall active ==="
grep -v '^#' "$CONF" 2>/dev/null | grep -v '^$' | sed 's/^/  ✓ /'
echo "  ✓ GitHub (CIDR ranges)"
echo "  ✓ Docker internal networks"
echo "  ✓ Tailscale network"
iptables -L OUTPUT -n --line-numbers
