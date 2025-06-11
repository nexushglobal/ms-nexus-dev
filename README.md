# 1. Crear los nuevos Dockerfile.dev en cada proyecto

# (copia el contenido del Dockerfile.dev en ms-nexus-gateway y ms-nexus-user)

# 2. Reemplazar docker-compose.dev.yml con la nueva versión

# 3. Construir una sola vez (solo cuando cambies package.json)

.\dev-docker.ps1 build

# 4. Iniciar con hot reload

.\dev-docker.ps1 up

# 5. Ver logs en tiempo real

.\dev-docker.ps1 logs

# ¡Ahora cualquier cambio en src/ se refleja automáticamente! 🔥

## Dev Local con Hot Reload

# 1. Configurar una sola vez

.\dev-local.ps1 setup

# 2. Iniciar todo (abre 3 terminales automáticamente)

.\dev-local.ps1 all

# Hot reload instantáneo! ⚡
