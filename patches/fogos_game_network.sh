#!/system/bin/sh
# ==============================================================================
# FogOS Elite Gaming Edition - Dynamic Background Network Restrictor
# Developer : Prince · VirgoYT (VirgoYT707)
# Purpose   : Silences background network drain to guarantee minimal in-game ping
# ==============================================================================

ACTION="$1"

case "$ACTION" in
    1|enable|start)
        # Enable Android NetworkPolicy restriction for all background UID buckets
        cmd netpolicy set-restrict-background true 2>/dev/null || true
        # Prioritize foreground interactive packet delivery
        iptables -t mangle -F FOGOS_GAMING 2>/dev/null || iptables -t mangle -N FOGOS_GAMING 2>/dev/null || true
        iptables -t mangle -C POSTROUTING -j FOGOS_GAMING 2>/dev/null || iptables -t mangle -A POSTROUTING -j FOGOS_GAMING 2>/dev/null || true
        iptables -t mangle -A FOGOS_GAMING -p udp -j TOS --set-tos 0x10 2>/dev/null || true
        iptables -t mangle -A FOGOS_GAMING -p tcp --dport 80 -j TOS --set-tos 0x10 2>/dev/null || true
        iptables -t mangle -A FOGOS_GAMING -p tcp --dport 443 -j TOS --set-tos 0x10 2>/dev/null || true
        setprop persist.fogos.net_restricted 1
        ;;
    0|disable|stop)
        # Re-enable standard background data syncing
        cmd netpolicy set-restrict-background false 2>/dev/null || true
        iptables -t mangle -F FOGOS_GAMING 2>/dev/null || true
        setprop persist.fogos.net_restricted 0
        ;;
    *)
        echo "Usage: $0 {enable|disable|1|0}"
        ;;
esac
