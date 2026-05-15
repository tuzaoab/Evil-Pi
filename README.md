# Evil-Pi
Simulação de Evil Twin feita em **Raspberry Pi**

<div align="center">
  <img src="https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fcdn-reichelt.de%2Fbilder%2Fweb%2Fxxl_ws%2FA300%2FRASPBERRY_PI_3B_PLUS_001.png&f=1&nofb=1&ipt=567bb225a6fa9ea30cb3b1ca715bb3dae57a9daff5e4e81e1a374f3a2d5ebe24" width="400">
</div>





**É NECESSÁRIO UM ADAPTADOR QUE SUPORTE MODO DE INJEÇÃO/MONITOR!!**
```ini



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
adicione as seguintes configurações, lembrando de adaptar a interface de rede para sua interface em questão
```
interface=wlan0
dhcp-range=192.168.10.10,192.168.10.50,12h
dhcp-option=3,192.168.10.1
dhcp-option=6,192.168.10.1
server=8.8.8.8
log-queries
log-dhcp
```
definir os endereços estaticos para a interface do AP
```
ip addr add 192.168.10.1/24 dev wlan0
```
habilite o redirecionamento de IP
```
sysctl -w net.ipv4.ip_forward=1
```
use o IPTABLES para criar uma regra de NAT para compartilhar internet com nossa interface de rede conectada a rede
```
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```
inicie o hostapd e o dnsmasqd
```
systemctl start hostapd
systemctl start dnsmasq
```





---
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
