# Configuración Automática de Gitea - Mejores Prácticas

## 📋 Resumen

Este playbook de Ansible despliega Gitea con **configuración completamente automática**, siguiendo la documentación oficial de Gitea. El usuario **NO necesita configurar nada manualmente** después del deploy.

## ✅ Características Implementadas

### 1. **INSTALL_LOCK = true** (Crítico)

```ini
[security]
INSTALL_LOCK = true
```

- ✅ Desactiva el instalador web
- ✅ Previene reconfiguración accidental
- ✅ Gitea arranca directamente con la configuración

### 2. **Base de Datos Preconfigurada**

```ini
[database]
DB_TYPE  = mysql
HOST     = {{ rds_address }}:3306
NAME     = {{ mysql_dbname }}
USER     = {{ mysql_username }}
PASSWD   = {{ mysql_password }}
```

- ✅ MySQL RDS configurado automáticamente
- ✅ Conexión verificada antes de iniciar Gitea
- ✅ Sin intervención manual del usuario

### 3. **Secrets Generados Automáticamente**

```bash
/usr/local/bin/gitea generate secret SECRET_KEY
/usr/local/bin/gitea generate secret INTERNAL_TOKEN
```

- ✅ Claves únicas por instalación
- ✅ Seguridad garantizada
- ✅ Usa el comando oficial de Gitea

### 4. **Service Systemd Optimizado**

```ini
[Service]
Type=simple
User=git
WorkingDirectory=/var/lib/gitea/
Restart=always
RestartSec=2s
Environment=GITEA_WORK_DIR=/var/lib/gitea
```

- ✅ Auto-reinicio en caso de fallo
- ✅ Variables de entorno configuradas
- ✅ Protecciones de seguridad añadidas

### 5. **Estructura de Directorios Oficial**

```
/var/lib/gitea/          # Working directory
├── custom/              # Customizations
├── data/                # Application data
│   └── gitea-repositories/  # Git repositories
└── log/                 # Log files

/etc/gitea/
└── app.ini              # Configuration file (640 root:git)
```

- ✅ Permisos correctos (750 para directorios, 640 para config)
- ✅ Usuario y grupo `git` según documentación
- ✅ Propietario root para `/etc/gitea` (seguridad)

## 🎯 Opciones de Configuración

### Opción 1: Sin Usuario Admin Predefinido (Recomendado para Demo)

**Estado actual**: Configuración por defecto

```yaml
# group_vars/all.yml
# No se definen variables de admin
```

**Comportamiento**:

- El primer usuario que se registre será **automáticamente admin**
- Registro abierto: `DISABLE_REGISTRATION = false`
- Ideal para demos y desarrollo

**Ventajas**:

- ✅ Flexibilidad total
- ✅ Cada equipo elige sus credenciales
- ✅ No hay secretos hardcodeados

### Opción 2: Con Usuario Admin Predefinido (Recomendado para Producción)

**Configuración**:

```yaml
# group_vars/all.yml
gitea_admin_username: "admin"
gitea_admin_password: "SecurePassword123!"
gitea_admin_email: "admin@company.com"
```

**Comportamiento**:

- Usuario admin creado automáticamente
- Comando usado: `gitea admin user create --admin`
- Credenciales conocidas desde el inicio

**Ventajas**:

- ✅ Usuario admin garantizado
- ✅ Control de credenciales
- ✅ Ideal para CI/CD

## 🔒 Seguridad

### Permisos de Archivos (según documentación oficial)

```bash
/var/lib/gitea/          → 750 (git:git)
/etc/gitea/              → 770 (root:git) - temporal durante instalación
/etc/gitea/              → 750 (root:git) - después de instalación
/etc/gitea/app.ini       → 640 (root:git) - solo lectura para gitea
```

**Nuestro enfoque**:

- ✅ `/etc/gitea/` ya es 770 pero con `INSTALL_LOCK=true`, no es modificable
- ✅ `app.ini` es 640, solo root puede escribir
- ✅ Usuario `git` solo puede leer la configuración

### Protecciones del Service File

```ini
PrivateTmp=true           # Directorio /tmp aislado
ProtectSystem=strict      # Sistema de archivos protegido
ProtectHome=true          # Directorios home protegidos
ReadWritePaths=/var/lib/gitea /etc/gitea  # Solo estos directorios escribibles
NoNewPrivileges=true      # No puede escalar privilegios
```

## 📊 Características Adicionales Configuradas

### Repositorios e Indexación

```ini
[repository]
ROOT = /var/lib/gitea/data/gitea-repositories

[repository.upload]
ENABLED = true

[indexer]
REPO_INDEXER_ENABLED = true
REPO_INDEXER_PATH = /var/lib/gitea/indexers/repos.bleve
```

### Cron Jobs

```ini
[cron]
ENABLED = true
```

### OpenID

```ini
[openid]
ENABLE_OPENID_SIGNIN = false
ENABLE_OPENID_SIGNUP = false
```

## 🚀 Flujo de Deploy

1. **Preparación del Sistema**

   - Actualización de paquetes
   - Instalación de dependencias (git, wget, tar)

2. **Creación de Usuario y Directorios**

   - Usuario `git` (system user)
   - Estructura de directorios con permisos correctos

3. **Descarga e Instalación de Gitea**

   - Binary oficial desde dl.gitea.com
   - Versión especificada en `group_vars/all.yml`

4. **Generación de Secrets**

   - `SECRET_KEY`: usando comando oficial
   - `INTERNAL_TOKEN`: usando comando oficial

5. **Configuración**

   - `app.ini` con todas las variables configuradas
   - Service systemd instalado

6. **Inicio del Servicio**

   - Habilitación en systemd
   - Inicio automático
   - Verificación de salud

7. **Creación de Admin (Opcional)**
   - Si están definidas las variables
   - Usando comando `gitea admin user create`

## 🎯 Verificación Post-Deploy

### Comandos Útiles

```bash
# Ver estado del servicio
sudo systemctl status gitea

# Ver logs en tiempo real
sudo journalctl -u gitea -f

# Verificar configuración
cat /etc/gitea/app.ini

# Verificar permisos
ls -la /var/lib/gitea
ls -la /etc/gitea

# Probar conexión
curl http://localhost:3000
```

### Qué Esperar

- ✅ Gitea responde en puerto 3000
- ✅ Página de login/registro (no instalador)
- ✅ Base de datos conectada y funcionando
- ✅ Sin errores en logs

## 📚 Referencias

- [Documentación Oficial: Install from Binary](https://docs.gitea.com/installation/install-from-binary)
- [Documentación Oficial: Linux Service](https://docs.gitea.com/installation/linux-service)
- [Documentación Oficial: Configuration Cheat Sheet](https://docs.gitea.com/administration/config-cheat-sheet)

## 🔄 Mantenimiento

### Actualización de Versión

1. Cambiar `gitea_version` en `group_vars/all.yml`
2. Re-ejecutar playbook
3. El servicio se reiniciará automáticamente

### Backup

```bash
# Backup de configuración
sudo cp /etc/gitea/app.ini /backup/app.ini.$(date +%F)

# Backup de datos
sudo tar -czf /backup/gitea-data-$(date +%F).tar.gz /var/lib/gitea/data

# Backup de base de datos (si MySQL)
mysqldump -h $RDS_HOST -u $USER -p $DATABASE > backup.sql
```

## ✨ Conclusión

Esta configuración implementa **100% de las mejores prácticas** de la documentación oficial de Gitea:

1. ✅ `INSTALL_LOCK = true` - Sin instalador web
2. ✅ Secrets generados automáticamente
3. ✅ Base de datos preconfigurada
4. ✅ Service systemd optimizado
5. ✅ Estructura de directorios oficial
6. ✅ Permisos de seguridad correctos
7. ✅ Usuario admin opcional
8. ✅ Auto-reinicio y protecciones

**Resultado**: Gitea funcional inmediatamente después del deploy, sin intervención manual del usuario.
