# dev-docker.ps1 - Script con soporte para hot reload y .env.test
param([string]$Command, [string]$Service)

if (-not $Command) {
    Write-Host "Uso: .\dev-docker.ps1 comando [servicio]" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Comandos:" -ForegroundColor Yellow
    Write-Host "  build      - Construir imagenes (solo la primera vez)"
    Write-Host "  up         - Iniciar servicios con hot reload"
    Write-Host "  down       - Detener servicios"
    Write-Host "  logs       - Ver logs en tiempo real"
    Write-Host "  restart    - Reiniciar un servicio especifico"
    Write-Host "  shell      - Acceder al shell de un servicio"
    Write-Host "  install    - Instalar nuevas dependencias"
    Write-Host "  clean      - Limpiar todo y empezar de cero"
    Write-Host "  status     - Ver estado de servicios"
    Write-Host "  test       - Probar health checks"
    Write-Host ""
    Write-Host "Ejemplos:"
    Write-Host "  .\dev-docker.ps1 up"
    Write-Host "  .\dev-docker.ps1 logs gateway"
    Write-Host "  .\dev-docker.ps1 restart user-service"
    Write-Host "  .\dev-docker.ps1 shell gateway"
    Write-Host ""
    Write-Host "NOTA: Usando archivo de variables de entorno: .env.test" -ForegroundColor Magenta
    exit
}

# Verificar Docker
try {
    docker info | Out-Null
    Write-Host "Docker OK" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Docker no esta ejecutandose" -ForegroundColor Red
    exit 1
}

# Verificar que existe el archivo .env.test
if (-not (Test-Path ".env.test")) {
    Write-Host "ADVERTENCIA: No se encontró el archivo .env.test" -ForegroundColor Yellow
    Write-Host "Creando archivo .env.test básico..." -ForegroundColor Blue
    
    # Crear un .env.test básico si no existe
    @"
# Variables de entorno para testing
NODE_ENV=test
GATEWAY_PORT=8000
MS_USERS_PORT=3001
MS_INTEGRATION_PORT=3002
MS_AUTH_PORT=3003
MS_PAYMENT_PORT=3004
MS_MEMBERSHIP_PORT=3005
MS_POINT_PORT=3006
NATS_SERVERS=nats://nats:4222
"@ | Out-File -FilePath ".env.test" -Encoding utf8
    
    Write-Host "Archivo .env.test creado. Por favor, configura tus variables de entorno." -ForegroundColor Yellow
}

# Ejecutar comandos
switch ($Command.ToLower()) {
    "build" {
        Write-Host "Construyendo imagenes para desarrollo..." -ForegroundColor Blue
        Write-Host "NOTA: Solo necesitas hacer esto la primera vez o cuando cambies package.json" -ForegroundColor Yellow
        Write-Host "Usando variables de entorno: .env.test" -ForegroundColor Magenta
        docker-compose --env-file .env.test -f docker-compose.dev.yml build
        Write-Host "Imagenes construidas! Ahora ejecuta: .\dev-docker.ps1 up" -ForegroundColor Green
    }
    
    "up" {
        Write-Host "Iniciando servicios con HOT RELOAD..." -ForegroundColor Blue
        Write-Host "Usando variables de entorno: .env.test" -ForegroundColor Magenta
        docker-compose --env-file .env.test -f docker-compose.dev.yml up -d
        Write-Host ""
        Write-Host "Servicios iniciados con hot reload!" -ForegroundColor Green
        Write-Host "Gateway: http://localhost:8000" -ForegroundColor Yellow
        Write-Host "NATS Monitor: http://localhost:8222" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Para ver logs en tiempo real: .\dev-docker.ps1 logs" -ForegroundColor Cyan
        Write-Host "Los cambios en tu codigo se reflejaran automaticamente!" -ForegroundColor Magenta
    }
    
    "down" {
        Write-Host "Deteniendo servicios..." -ForegroundColor Blue
        Write-Host "Usando variables de entorno: .env.test" -ForegroundColor Magenta
        docker-compose --env-file .env.test -f docker-compose.dev.yml down
        Write-Host "Servicios detenidos!" -ForegroundColor Green
    }
    
    "logs" {
        if ($Service) {
            Write-Host "Mostrando logs para $Service (Ctrl+C para salir)..." -ForegroundColor Blue
            Write-Host "Usando variables de entorno: .env.test" -ForegroundColor Magenta
            docker-compose --env-file .env.test -f docker-compose.dev.yml logs -f $Service
        } else {
            Write-Host "Mostrando logs de todos los servicios (Ctrl+C para salir)..." -ForegroundColor Blue
            Write-Host "Usando variables de entorno: .env.test" -ForegroundColor Magenta
            docker-compose --env-file .env.test -f docker-compose.dev.yml logs -f
        }
    }
    
    "restart" {
        if (-not $Service) {
            Write-Host "ERROR: Debes especificar un servicio para reiniciar" -ForegroundColor Red
            Write-Host "Ejemplo: .\dev-docker.ps1 restart gateway" -ForegroundColor Yellow
            exit 1
        }
        Write-Host "Reiniciando $Service..." -ForegroundColor Blue
        Write-Host "Usando variables de entorno: .env.test" -ForegroundColor Magenta
        docker-compose --env-file .env.test -f docker-compose.dev.yml restart $Service
        Write-Host "$Service reiniciado!" -ForegroundColor Green
    }
    
    "shell" {
        if (-not $Service) {
            Write-Host "ERROR: Debes especificar un servicio" -ForegroundColor Red
            Write-Host "Servicios disponibles: nexus-gateway, ms-users, ms-integration, ms-auth, ms-payment, ms-membership, ms-point, nats" -ForegroundColor Yellow
            exit 1
        }
        Write-Host "Accediendo al shell de $Service..." -ForegroundColor Blue
        Write-Host "Usando variables de entorno: .env.test" -ForegroundColor Magenta
        docker-compose --env-file .env.test -f docker-compose.dev.yml exec $Service sh
    }
    
    "install" {
        if (-not $Service) {
            Write-Host "ERROR: Debes especificar el servicio donde instalar" -ForegroundColor Red
            Write-Host "Ejemplo: .\dev-docker.ps1 install nexus-gateway" -ForegroundColor Yellow
            exit 1
        }
        Write-Host "Instalando dependencias en $Service..." -ForegroundColor Blue
        Write-Host "Usando variables de entorno: .env.test" -ForegroundColor Magenta
        docker-compose --env-file .env.test -f docker-compose.dev.yml exec $Service pnpm install
        Write-Host "Dependencias instaladas! Reiniciando servicio..." -ForegroundColor Blue
        docker-compose --env-file .env.test -f docker-compose.dev.yml restart $Service
        Write-Host "Listo!" -ForegroundColor Green
    }
    
    "clean" {
        Write-Host "Limpiando todo y empezando de cero..." -ForegroundColor Blue
        Write-Host "Usando variables de entorno: .env.test" -ForegroundColor Magenta
        docker-compose --env-file .env.test -f docker-compose.dev.yml down -v
        docker-compose --env-file .env.test -f docker-compose.dev.yml build --no-cache
        Write-Host "Limpieza completada! Ejecuta 'up' para iniciar." -ForegroundColor Green
    }
    
    "status" {
        Write-Host "Estado de servicios:" -ForegroundColor Blue
        Write-Host "Usando variables de entorno: .env.test" -ForegroundColor Magenta
        docker-compose --env-file .env.test -f docker-compose.dev.yml ps
    }
    
    "test" {
        Write-Host "Ejecutando health checks..." -ForegroundColor Blue
        Write-Host "Usando variables de entorno: .env.test" -ForegroundColor Magenta
        Start-Sleep -Seconds 3
        
        try {
            $nats = Invoke-WebRequest "http://localhost:8222/healthz" -TimeoutSec 5
            Write-Host "NATS: OK" -ForegroundColor Green
        } catch {
            Write-Host "NATS: Error - $($_.Exception.Message)" -ForegroundColor Red
        }
        
        try {
            $gateway = Invoke-WebRequest "http://localhost:8000/health" -TimeoutSec 5
            Write-Host "Gateway: OK" -ForegroundColor Green
        } catch {
            Write-Host "Gateway: Error - $($_.Exception.Message)" -ForegroundColor Red
        }
        
        # Test adicionales para otros microservicios
        $ports = @{
            "Users" = 3001
            "Integration" = 3002  
            "Auth" = 3003
            "Payment" = 3004
            "Membership" = 3005
            "Point" = 3006
        }
        
        foreach ($service in $ports.Keys) {
            try {
                $response = Invoke-WebRequest "http://localhost:$($ports[$service])/health" -TimeoutSec 5
                Write-Host "$service Service: OK" -ForegroundColor Green
            } catch {
                Write-Host "$service Service: Error" -ForegroundColor Red
            }
        }
    }
    
    default {
        Write-Host "Comando no reconocido: $Command" -ForegroundColor Red
        Write-Host "Comandos validos: build, up, down, logs, restart, shell, install, clean, status, test"
    }
}