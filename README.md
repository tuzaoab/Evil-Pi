# Evil-Pi
Simulação de Evil Twin feita em Raspberry Pi 



```ini


###
Crie o arquivo que conterá código principal:
nano evil.sh
CTRL O
CTRL X
```
> **Importante:** Cole aqui o conteúdo do arquivo que está no repositório (evil.sh).

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
