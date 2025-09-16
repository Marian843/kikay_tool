# PowerShell script to automate Docker-based model conversion

Write-Host "Starting TensorFlow Lite Model Conversion with Docker" -ForegroundColor Cyan
Write-Host "=" * 60

# Check if Docker is installed and running
Write-Host "`n1. Checking Docker installation..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "   $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "   ERROR: Docker is not installed or not in PATH" -ForegroundColor Red
    Write-Host "   Please install Docker Desktop from https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

# Check if Docker daemon is running
try {
    $dockerInfo = docker info > $null 2>&1
    Write-Host "   Docker daemon is running" -ForegroundColor Green
} catch {
    Write-Host "   ERROR: Docker daemon is not running" -ForegroundColor Red
    Write-Host "   Please start Docker Desktop and try again" -ForegroundColor Yellow
    exit 1
}

# Check if required model files exist
Write-Host "`n2. Checking model files..." -ForegroundColor Yellow
$skintoneModel = "models/mobilenet_skintone_final.h5"
$undertoneModel = "models/mobilenet_undertone_final.h5"

if (Test-Path $skintoneModel) {
    $skintoneSize = (Get-Item $skintoneModel).Length / 1MB
    Write-Host "   Found $skintoneModel ($([math]::Round($skintoneSize, 2)) MB)" -ForegroundColor Green
} else {
    Write-Host "   ERROR: $skintoneModel not found" -ForegroundColor Red
    exit 1
}

if (Test-Path $undertoneModel) {
    $undertoneSize = (Get-Item $undertoneModel).Length / 1MB
    Write-Host "   Found $undertoneModel ($([math]::Round($undertoneSize, 2)) MB)" -ForegroundColor Green
} else {
    Write-Host "   ERROR: $undertoneModel not found" -ForegroundColor Red
    exit 1
}

# Check if Dockerfile exists
Write-Host "`n3. Checking Docker configuration..." -ForegroundColor Yellow
if (Test-Path "Dockerfile") {
    Write-Host "   Found Dockerfile" -ForegroundColor Green
} else {
    Write-Host "   ERROR: Dockerfile not found in current directory" -ForegroundColor Red
    exit 1
}

# Check if conversion script exists
if (Test-Path "convert_models.py") {
    Write-Host "   Found convert_models.py" -ForegroundColor Green
} else {
    Write-Host "   ERROR: convert_models.py not found in current directory" -ForegroundColor Red
    exit 1
}

# Build Docker image
Write-Host "`n4. Building Docker image..." -ForegroundColor Yellow
try {
    docker build -t tflite-converter .
    Write-Host "   Docker image built successfully" -ForegroundColor Green
} catch {
    Write-Host "   ERROR: Failed to build Docker image" -ForegroundColor Red
    exit 1
}

# Run conversion in Docker container
Write-Host "`n5. Running model conversion..." -ForegroundColor Yellow
try {
    # Run the conversion and capture output
    docker run -v ${PWD}:/app tflite-converter
    Write-Host "   Model conversion completed" -ForegroundColor Green
} catch {
    Write-Host "   ERROR: Model conversion failed" -ForegroundColor Red
    exit 1
}

# Check if TFLite models were created
Write-Host "`n6. Verifying output files..." -ForegroundColor Yellow
$skintoneTflite = "models/skintone_model.tflite"
$undertoneTflite = "models/undertone_model.tflite"

if (Test-Path $skintoneTflite) {
    $skintoneTfliteSize = (Get-Item $skintoneTflite).Length / 1KB
    Write-Host "   Created $skintoneTflite ($([math]::Round($skintoneTfliteSize, 2)) KB)" -ForegroundColor Green
} else {
    Write-Host "   WARNING: $skintoneTflite was not created" -ForegroundColor Yellow
}

if (Test-Path $undertoneTflite) {
    $undertoneTfliteSize = (Get-Item $undertoneTflite).Length / 1KB
    Write-Host "   Created $undertoneTflite ($([math]::Round($undertoneTfliteSize, 2)) KB)" -ForegroundColor Green
} else {
    Write-Host "   WARNING: $undertoneTflite was not created" -ForegroundColor Yellow
}

Write-Host "`n7. Conversion Summary:" -ForegroundColor Cyan
Write-Host "   The TensorFlow Lite models should now be available in the models directory" -ForegroundColor White
Write-Host "   Next steps:" -ForegroundColor White
Write-Host "   1. Move the TFLite models to your Flutter project's assets/models/ directory" -ForegroundColor White
Write-Host "   2. Add the models to your pubspec.yaml file" -ForegroundColor White
Write-Host "   3. Integrate the models using the tflite_flutter package" -ForegroundColor White

Write-Host "`nConversion process completed!" -ForegroundColor Green