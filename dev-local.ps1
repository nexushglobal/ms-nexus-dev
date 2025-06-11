# dev-local.ps1 - Desarrollo local sin Docker (más rápido)
param([string]$Command)

if (-not $Command) {
    Write-Host "Uso: .\dev-local.ps1 comando" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Comandos:" -ForegroundColor Yellow
    Write-Host "  setup      - Configurar entorno local"
    Write-Host "  nats       - Solo iniciar NATS en Docker"
    Write-Host "  user       - Iniciar User Service localmente"
    Write-Host "  gateway    - Iniciar Gateway localmente"
    Write-Host "  all        - Iniciar todo (3 terminales)"
    Write-Host "  stop       - Detener NATS"
    Write-Host ""
    Write-Host "Ventajas: Hot reload instantaneo, debugging nativo"
    exit
}

switch ($Command.ToLower()) {
    "setup" {
        Write-Host "Configurando entorno local..." -ForegroundColor Blue
        
        # Instalar dependencias en cada proyecto
        Write-Host "Instalando dependencias en Gateway..." -ForegroundColor Yellow
        Set-Location ms-nexus-gateway
        pnpm install
        Set-Location ..
        
        Write-Host "Instalando dependencias en User Service..." -ForegroundColor Yellow
        Set-Location ms-nexus-user
        pnpm install
        Set-Location ..
        
        Write-Host "Entorno configurado!" -ForegroundColor Green
        Write-Host "Ahora ejecuta: .\dev-local.ps1 all" -ForegroundColor Cyan
    }
    
    "nats" {
        Write-Host "Iniciando solo NATS en Docker..." -ForegroundColor Blue
        docker run -d --name nexus-nats-local `
            -p 4222:4222 -p 6222:6222 -p 8222:8222 `
            nats:2.10-alpine `
            --js --sd /data --http_port 8222
        Write-Host "NATS iniciado en http://localhost:8222" -ForegroundColor Green
    }
    
    "user" {
        Write-Host "Iniciando User Service localmente..." -ForegroundColor Blue
        Set-Location ms-nexus-user
        $env:NATS_SERVERS = "nats://localhost:4222"
        $env:PORT = "3001"
        pnpm run start:dev
    }
    
    "gateway" {
        Write-Host "Iniciando Gateway localmente..." -ForegroundColor Blue
        Set-Location ms-nexus-gateway
        $env:NATS_SERVERS = "nats://localhost:4222"
        $env:PORT = "8000"
        pnpm run start:dev
    }
    
    "all" {
        Write-Host "Iniciando todo el entorno..." -ForegroundColor Blue
        
        # Iniciar NATS
        Write-Host "1. Iniciando NATS..." -ForegroundColor Yellow
        docker run -d --name nexus-nats-local `
            -p 4222:4222 -p 6222:6222 -p 8222:8222 `
            nats:2.10-alpine `
            --js --sd /data --http_port 8222
        
        Start-Sleep -Seconds 3
        
        # Abrir terminales para cada servicio
        Write-Host "2. Abriendo terminal para User Service..." -ForegroundColor Yellow
        Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd ms-nexus-user; `$env:NATS_SERVERS='nats://localhost:4222'; `$env:PORT='3001'; pnpm run start:dev"
        
        Start-Sleep -Seconds 2
        
        Write-Host "3. Abriendo terminal para Gateway..." -ForegroundColor Yellow
        Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd ms-nexus-gateway; `$env:NATS_SERVERS='nats://localhost:4222'; `$env:PORT='8000'; pnpm run start:dev"
        
        Write-Host ""
        Write-Host "Entorno iniciado!" -ForegroundColor Green
        Write-Host "Gateway: http://localhost:8000" -ForegroundColor Yellow
        Write-Host "NATS Monitor: http://localhost:8222" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Hot reload activado! Los cambios se reflejan instantaneamente." -ForegroundColor Magenta
    }
    
    "stop" {
        Write-Host "Deteniendo NATS..." -ForegroundColor Blue
        docker stop nexus-nats-local 2>$null
        docker rm nexus-nats-local 2>$null
        Write-Host "NATS detenido!" -ForegroundColor Green
        Write-Host "Cierra manualmente las terminales de los servicios." -ForegroundColor Yellow
    }
    
    default {
        Write-Host "Comando no reconocido: $Command" -ForegroundColor Red
    }
}