# dev-docker.ps1 - Script con soporte para hot reload
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

# Ejecutar comandos
switch ($Command.ToLower()) {
    "build" {
        Write-Host "Construyendo imagenes para desarrollo..." -ForegroundColor Blue
        Write-Host "NOTA: Solo necesitas hacer esto la primera vez o cuando cambies package.json" -ForegroundColor Yellow
        docker-compose -f docker-compose.dev.yml build
        Write-Host "Imagenes construidas! Ahora ejecuta: .\dev-docker.ps1 up" -ForegroundColor Green
    }
    
    "up" {
        Write-Host "Iniciando servicios con HOT RELOAD..." -ForegroundColor Blue
        docker-compose -f docker-compose.dev.yml up -d
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
        docker-compose -f docker-compose.dev.yml down
        Write-Host "Servicios detenidos!" -ForegroundColor Green
    }
    
    "logs" {
        if ($Service) {
            Write-Host "Mostrando logs para $Service (Ctrl+C para salir)..." -ForegroundColor Blue
            docker-compose -f docker-compose.dev.yml logs -f $Service
        } else {
            Write-Host "Mostrando logs de todos los servicios (Ctrl+C para salir)..." -ForegroundColor Blue
            docker-compose -f docker-compose.dev.yml logs -f
        }
    }
    
    "restart" {
        if (-not $Service) {
            Write-Host "ERROR: Debes especificar un servicio para reiniciar" -ForegroundColor Red
            Write-Host "Ejemplo: .\dev-docker.ps1 restart gateway" -ForegroundColor Yellow
            exit 1
        }
        Write-Host "Reiniciando $Service..." -ForegroundColor Blue
        docker-compose -f docker-compose.dev.yml restart $Service
        Write-Host "$Service reiniciado!" -ForegroundColor Green
    }
    
    "shell" {
        if (-not $Service) {
            Write-Host "ERROR: Debes especificar un servicio" -ForegroundColor Red
            Write-Host "Servicios disponibles: gateway, user-service, nats" -ForegroundColor Yellow
            exit 1
        }
        Write-Host "Accediendo al shell de $Service..." -ForegroundColor Blue
        docker-compose -f docker-compose.dev.yml exec $Service sh
    }
    
    "install" {
        if (-not $Service) {
            Write-Host "ERROR: Debes especificar el servicio donde instalar" -ForegroundColor Red
            Write-Host "Ejemplo: .\dev-docker.ps1 install gateway" -ForegroundColor Yellow
            exit 1
        }
        Write-Host "Instalando dependencias en $Service..." -ForegroundColor Blue
        docker-compose -f docker-compose.dev.yml exec $Service pnpm install
        Write-Host "Dependencias instaladas! Reiniciando servicio..." -ForegroundColor Blue
        docker-compose -f docker-compose.dev.yml restart $Service
        Write-Host "Listo!" -ForegroundColor Green
    }
    
    "clean" {
        Write-Host "Limpiando todo y empezando de cero..." -ForegroundColor Blue
        docker-compose -f docker-compose.dev.yml down -v
        docker-compose -f docker-compose.dev.yml build --no-cache
        Write-Host "Limpieza completada! Ejecuta 'up' para iniciar." -ForegroundColor Green
    }
    
    "status" {
        Write-Host "Estado de servicios:" -ForegroundColor Blue
        docker-compose -f docker-compose.dev.yml ps
    }
    
    "test" {
        Write-Host "Ejecutando health checks..." -ForegroundColor Blue
        Start-Sleep -Seconds 3
        
        try {
            $nats = Invoke-WebRequest "http://localhost:8222/healthz" -TimeoutSec 5
            Write-Host "NATS: OK" -ForegroundColor Green
        } catch {
            Write-Host "NATS: Error" -ForegroundColor Red
        }
        
        try {
            $gateway = Invoke-WebRequest "http://localhost:8000/api/users/health" -TimeoutSec 5
            Write-Host "Gateway: OK" -ForegroundColor Green
        } catch {
            Write-Host "Gateway: Error" -ForegroundColor Red
        }
    }
    
    default {
        Write-Host "Comando no reconocido: $Command" -ForegroundColor Red
        Write-Host "Comandos validos: build, up, down, logs, restart, shell, install, clean, status, test"
    }
}