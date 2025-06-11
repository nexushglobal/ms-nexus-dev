# setup-windows-simple.ps1 - Configuración inicial simplificada

Write-Host "Configurando entorno de desarrollo para Windows..." -ForegroundColor Blue

# Verificar Docker Desktop
Write-Host "Verificando Docker Desktop..." -ForegroundColor Blue
try {
    $dockerVersion = docker --version
    Write-Host "Docker encontrado: $dockerVersion" -ForegroundColor Green
}
catch {
    Write-Host "Docker no está instalado o no está en el PATH." -ForegroundColor Red
    Write-Host "Descarga Docker Desktop desde: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

# Verificar Docker Compose
Write-Host "Verificando Docker Compose..." -ForegroundColor Blue
try {
    $composeVersion = docker-compose --version
    Write-Host "Docker Compose encontrado: $composeVersion" -ForegroundColor Green
}
catch {
    Write-Host "Docker Compose no está disponible." -ForegroundColor Red
    exit 1
}

# Verificar Node.js
Write-Host "Verificando Node.js..." -ForegroundColor Blue
try {
    $nodeVersion = node --version
    Write-Host "Node.js encontrado: $nodeVersion" -ForegroundColor Green
}
catch {
    Write-Host "Node.js no está instalado." -ForegroundColor Red
    Write-Host "Descarga Node.js desde: https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

# Verificar/Instalar pnpm
Write-Host "Verificando pnpm..." -ForegroundColor Blue
try {
    $pnpmVersion = pnpm --version
    Write-Host "pnpm encontrado: $pnpmVersion" -ForegroundColor Green
}
catch {
    Write-Host "pnpm no está instalado. Instalando..." -ForegroundColor Yellow
    try {
        npm install -g pnpm
        $pnpmVersion = pnpm --version
        Write-Host "pnpm instalado: $pnpmVersion" -ForegroundColor Green
    }
    catch {
        Write-Host "Error al instalar pnpm" -ForegroundColor Red
        exit 1
    }
}

# Verificar política de ejecución de PowerShell
Write-Host "Verificando política de ejecución de PowerShell..." -ForegroundColor Blue
$executionPolicy = Get-ExecutionPolicy
if ($executionPolicy -eq "Restricted") {
    Write-Host "La política de ejecución está restringida." -ForegroundColor Yellow
    Write-Host "Ejecuta como administrador: Set-ExecutionPolicy RemoteSigned" -ForegroundColor Yellow
} else {
    Write-Host "Política de ejecución: $executionPolicy" -ForegroundColor Green
}

# Crear archivo .env si no existe
if (-not (Test-Path ".env")) {
    Write-Host "Creando archivo .env desde .env.example..." -ForegroundColor Blue
    if (Test-Path ".env.example") {
        Copy-Item ".env.example" ".env"
        Write-Host "Archivo .env creado." -ForegroundColor Green
    } else {
        Write-Host "Archivo .env.example no encontrado." -ForegroundColor Yellow
    }
}

Write-Host "Configuración completada!" -ForegroundColor Green
Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Cyan
Write-Host "1. Asegúrate de que Docker Desktop esté ejecutándose"
Write-Host "2. Ejecuta: .\dev-docker.ps1 -Command build"
Write-Host "3. Ejecuta: .\dev-docker.ps1 -Command up"
Write-Host "4. Visita: http://localhost:8000"