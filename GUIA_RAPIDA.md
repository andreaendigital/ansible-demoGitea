# 🚀 Guía Rápida: Configuración Automática de Gitea

## TL;DR

```bash
ansible-playbook playbook.yml
```

✅ Gitea configurado y listo para usar  
✅ Sin instalador web  
✅ Base de datos MySQL RDS conectada  
✅ Secrets generados automáticamente  
✅ Servicio systemd habilitado

---

## 📋 Checklist Pre-Deploy

- [ ] Terraform ha creado la infraestructura
- [ ] RDS MySQL está disponible
- [ ] Variables de BD están en `group_vars/all.yml` o secrets manager
- [ ] SSH key está configurado en `ansible.cfg`
- [ ] Inventory está actualizado (`./generate_inventory.sh`)

---

## 🎯 Configurar Usuario Admin (Opcional)

### Opción 1: Sin Admin Predefinido (Default)

```yaml
# group_vars/all.yml - NO agregues estas variables
# El primer usuario que se registre será admin
```

### Opción 2: Con Admin Predefinido

```yaml
# group_vars/all.yml
gitea_admin_username: "admin"
gitea_admin_password: "SecurePassword123!"
gitea_admin_email: "admin@company.com"
```

---

## 🚀 Deploy

```bash
# 1. Generar inventory
./generate_inventory.sh

# 2. Verificar conectividad
ansible all -m ping

# 3. Deploy (dry-run)
ansible-playbook playbook.yml --check

# 4. Deploy real
ansible-playbook playbook.yml
```

---

## ✅ Verificación Post-Deploy

```bash
# Ver estado
ansible all -m shell -a "systemctl status gitea"

# Ver logs
ansible all -m shell -a "journalctl -u gitea -n 50"

# Probar HTTP
curl http://<EC2_IP>:3000

# Verificar config
ansible all -m shell -a "cat /etc/gitea/app.ini | grep INSTALL_LOCK"
# Debe mostrar: INSTALL_LOCK = true
```

---

## 🔍 Qué Esperar

### ✅ Deploy Exitoso:

- Puerto 3000 responde
- Página de login (NO instalador)
- Sin errores en logs
- Service status: `active (running)`

### ❌ Deploy Fallido:

1. Revisar logs: `journalctl -u gitea -f`
2. Verificar BD: `nc -zv <RDS_HOST> 3306`
3. Verificar permisos: `ls -la /var/lib/gitea`

---

## 🎯 Acceso a Gitea

### Si configuraste admin:

```
URL: http://<EC2_IP>:3000
Usuario: <gitea_admin_username>
Password: <gitea_admin_password>
```

### Si NO configuraste admin:

```
URL: http://<EC2_IP>:3000
1. Click "Register"
2. Crea tu usuario
3. Automáticamente serás admin
```

---

## 🛠️ Comandos Útiles Post-Deploy

```bash
# Reiniciar Gitea
sudo systemctl restart gitea

# Ver estado
sudo systemctl status gitea

# Logs en tiempo real
sudo journalctl -u gitea -f

# Verificar configuración
cat /etc/gitea/app.ini

# Ver permisos
ls -la /var/lib/gitea
ls -la /etc/gitea

# Crear usuario admin adicional (si es necesario)
sudo -u git /usr/local/bin/gitea admin user create \
  --username admin2 \
  --password pass123 \
  --email admin2@example.com \
  --admin \
  -c /etc/gitea/app.ini

# Listar usuarios
sudo -u git /usr/local/bin/gitea admin user list -c /etc/gitea/app.ini
```

---

## 🔒 Variables Sensibles

### Opción 1: Ansible Vault (Recomendado)

```bash
# Encriptar variables
ansible-vault encrypt group_vars/all.yml

# Deploy con vault
ansible-playbook playbook.yml --ask-vault-pass
```

### Opción 2: Variables de Entorno

```bash
# Pasar al momento del deploy
ansible-playbook playbook.yml \
  -e "mysql_password=$DB_PASSWORD" \
  -e "gitea_admin_password=$ADMIN_PASS"
```

### Opción 3: AWS Secrets Manager

```yaml
# En el playbook
- name: Get DB password from Secrets Manager
  set_fact:
    mysql_password: "{{ lookup('aws_secret', 'gitea/db/password') }}"
```

---

## 📊 Verificar Características Automáticas

### 1. Install Lock

```bash
curl -s http://localhost:3000 | grep -i "install"
# No debe aparecer nada de "install" o "setup"
```

### 2. Database Connection

```bash
sudo -u git /usr/local/bin/gitea doctor check \
  --config /etc/gitea/app.ini
```

### 3. Secrets Generados

```bash
sudo grep -E "SECRET_KEY|INTERNAL_TOKEN" /etc/gitea/app.ini
# Deben ser strings largos y únicos
```

### 4. Auto-Restart

```bash
# Matar proceso Gitea
sudo pkill gitea

# Esperar 2 segundos
sleep 3

# Verificar que systemd lo reinició
systemctl status gitea
# Debe mostrar "active (running)"
```

---

## 🎓 Referencias Rápidas

| Archivo                               | Propósito                         |
| ------------------------------------- | --------------------------------- |
| `group_vars/all.yml`                  | Variables de configuración        |
| `/etc/gitea/app.ini`                  | Configuración de Gitea (generada) |
| `/var/lib/gitea/`                     | Datos, logs, repositorios         |
| `/etc/systemd/system/gitea.service`   | Service definition                |
| `CONFIGURACION_AUTOMATICA.md`         | Documentación completa            |
| `COMPARACION_MANUAL_VS_AUTOMATICO.md` | Comparación detallada             |

---

## ⚡ Troubleshooting Rápido

| Problema                | Solución                           |
| ----------------------- | ---------------------------------- |
| Puerto 3000 no responde | `journalctl -u gitea -f`           |
| Error de BD             | Verificar RDS security group       |
| Permission denied       | `ls -la /var/lib/gitea` y corregir |
| Service no inicia       | `systemctl status gitea` + logs    |
| Instalador web aparece  | Verificar `INSTALL_LOCK = true`    |

---

## 🎯 Próximos Pasos

Después del deploy exitoso:

1. ✅ Acceder a Gitea vía navegador
2. ✅ Login con admin (o crear primer usuario)
3. ✅ Crear organización
4. ✅ Crear primer repositorio
5. ✅ Configurar SSH keys
6. ✅ Invitar usuarios del equipo

---

## 📞 Soporte

**Documentación completa**: Ver `CONFIGURACION_AUTOMATICA.md`  
**Comparación**: Ver `COMPARACION_MANUAL_VS_AUTOMATICO.md`  
**Ejemplo de config**: Ver `group_vars/all.yml.example`  
**Documentación oficial**: https://docs.gitea.com/

---

**Última actualización**: Diciembre 2025  
**Versión de Gitea**: 1.25.2
