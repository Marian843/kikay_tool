# Check if Docker is installed and running
Write-Host "Checking Docker installation..." -ForegroundColor Yellow

try {
    # Check if Docker command is available
    $dockerVersion = docker --version
    Write-Host "Docker is installed: $dockerVersion" -ForegroundColor Green
    
    # Check if Docker daemon is running
    $dockerInfo = docker info
    Write-Host "Docker is running and ready to use" -ForegroundColor Green
    
    Write-Host "`nYou can now convert your models using Docker:" -ForegroundColor Cyan
    Write-Host "1. Build the Docker image:" -ForegroundColor White
    Write-Host "   docker build -t tflite-converter ." -ForegroundColor Gray
    Write-Host "2. Run the conversion:" -ForegroundColor White
    Write-Host "   docker run -v ${PWD}:/app tflite-converter" -ForegroundColor Gray
}
catch {
    Write-Host "Docker is not installed or not running properly" -ForegroundColor Red
    Write-Host "Please install Docker Desktop from https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    Write-Host "After installation, make sure Docker Desktop is running" -ForegroundColor Yellow
}