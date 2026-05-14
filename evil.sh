sudo rfkill unblock wlan

sudo nmcli device set wlan1 managed no

ip link set wlan1 down
ip addr flush dev wlan1
ip addr add 192.168.10.1/24 dev wlan1
ip link set wlan1 up

sysctl -w net.ipv4.ip_forward=1

iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE


iptables -t nat -A PREROUTING -i wlan1 -p tcp --dport 80 -j DNAT --to-destination 192.168.10.1:80
iptables -t nat -A PREROUTING -i wlan1 -p tcp --dport 443 -j DNAT --to-destination 192.168.10.1:80


systemctl start apache2
systemctl start hostapd
systemctl start dnsmasq
systemctl restart hostapd
systemctl restart dnsmasq

ip addr show wlan1
