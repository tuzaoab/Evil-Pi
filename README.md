# Evil-Pi
Simulação de Evil Twin feita em Raspberry Pi 



```ini


###
Primeiramente baixe estes seguintes softwares:
apt install hostapd dnsmasq iptables apache2 -y

Crie o arquivo que conterá código principal:
nano evil.sh
CTRL O
CTRL X
```
> **Importante:** Cole aqui o conteúdo do arquivo que está no repositório (evil.sh).
---

Crie a configuração do hostapd

```
nano /etc/hostapd/hostapd.conf
```
adicione as seguintes configurações: (mude o ssid e a sua interface, use "ip -c a" para saber)
```
interface=wlan0
driver=nl80211
ssid=MeuAP
hw_mode=g
channel=6
ieee80211n=1
wmm_enabled=1
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
ctrl_interface=/var/run/hostapd
ctrl_interface_group=0
```
configure o hostapd para usar arquivo de configuração
```
nano /etc/default/hostapd
```
adicione a seguinte linha:
```
DAEMON_CONF="/etc/hostapd/hostapd.conf"
```
dnsmasq x DHCP
```
nano /etc/dnsmasq.conf
```
Adicionar as seguintes configurações, lembrando de adaptar a interface de rede para sua interface em questão
```
interface=wlan0
dhcp-range=192.168.10.10,192.168.10.50,12h
dhcp-option=3,192.168.10.1
dhcp-option=6,192.168.10.1
server=8.8.8.8
log-queries
log-dhcp
```
Agora vamos definir os endereços estaticos para a interface do nosso AP
```
ip addr add 192.168.10.1/24 dev wlan0
```
Agora precisamos habilitar o redirecionamento de IP
```
sysctl -w net.ipv4.ip_forward=1
```
Agora vamos usar o IPTABLES para criar uma regra de NAT para compartilhar internet com nossa interface de rede conectada a rede (no meu caso minha interface cabeada)
```
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```
Agora apenas precisamos iniciar o nosso hostapd e o dnsmasqd
```
systemctl start hostapd
systemctl start dnsmasq
```





---
---
Uma vez configurado nossa pagina WEB e nosso [Fake AP](https://github.com/them3x/tutoriais/blob/main/Tecnica-FakeAP.md)
 usando hostapd, vamos analizar nossa interface de rede para descobrir nosso endereço IP

```
canario@raspberrypi $ ip -c a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute
       valid_lft forever preferred_lft forever
2: eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
    link/ether b8:27:eb:28:32:c4 brd ff:ff:ff:ff:ff:ff
3: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether b8:27:eb:7d:67:91 brd ff:ff:ff:ff:ff:ff
    inet 192.168.15.14/24 brd 192.168.15.255 scope global dynamic noprefixroute wlan0
       valid_lft 12292sec preferred_lft 12292sec
    inet6 2804:7f0:90c1:3992:41fa:c5a8:7534:a618/64 scope global dynamic noprefixroute
       valid_lft 43174sec preferred_lft 43174sec
    inet6 fe80::1fa:3c40:a1de:d335/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
4: tailscale0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1280 qdisc pfifo_fast state UNKNOWN group default qlen 500
    link/none
    inet6 fe80::f5da:f7ab:aa15:f055/64 scope link stable-privacy
       valid_lft forever preferred_lft forever
5: wlan1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether c0:1c:30:49:d4:4d brd ff:ff:ff:ff:ff:ff
    inet 192.168.10.1/24 scope global wlan1
       valid_lft forever preferred_lft forever
```
---
###  Criando o Serviço no Sistema
Para que o processo rode sozinho, você precisa criar um arquivo de serviço:

```bash
sudo nano /etc/systemd/system/eviltwin.service
```

**Copie e cole a configuração abaixo:**
*(Lembre-se de trocar `SEU_USUARIO` pelo seu nome de usuário)*

```ini
[Unit]
Description=Evil Twin Service
After=network.target

[Service]
ExecStart=/bin/bash /home/SEU_USUARIO/Desktop/evil.sh
WorkingDirectory=/home/SEU_USUARIO/Desktop
StandardOutput=inherit
StandardError=inherit
Restart=always
User=root

[Install]
WantedBy=multi-user.target
```

>  caso não souber seu nome de usuário, digite `whoami` no terminal.

---

###  Permissões e Inicialização
Agora, vamos dar vida ao serviço:

1. **Dê permissão de execução ao script:**
   ```bash
   chmod +x /home/SEU_USUARIO/Desktop/evil.sh
   ```

2. **Avise ao Linux sobre o novo serviço:**
   ```bash
   sudo systemctl daemon-reload
   ```

3. **Habilite e inicie o serviço:**
   ```bash
   sudo systemctl enable eviltwin.service
   sudo systemctl start eviltwin.service
   ```

---

###  Comandos de Gerenciamento

| Ação | Comando |
| :--- | :--- |
| **Ver status** | `systemctl status eviltwin.service` |
| **Parar serviço** | `sudo systemctl stop eviltwin.service` |
| **Ver logs de erro** | `journalctl -u eviltwin.service` |

---
**⚠️ Aviso:** Conteúdo estritamente educacional. O uso sem autorização é ilegal.
