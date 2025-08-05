# PowerShell script to generate docker-compose files for all microservices

# Define microservices and their ports
$services = @(
    @{ Name = "time-service"; Port = 3001 },
    @{ Name = "timezone-service"; Port = 3002 },
    @{ Name = "minutes-service"; Port = 3003 },
    @{ Name = "aggregator-service"; Port = 3004 },
    @{ Name = "formatter-service"; Port = 3005 }
)

# Base ports for databases
$mongoBasePort = 27017
$mysqlBasePort = 3306
$kafkaBasePort = 9092
$zookeeperBasePort = 2181
$kafkaUiBasePort = 8080

# Generate docker-compose files and .env files
foreach ($i in 0..($services.Count-1)) {
    $service = $services[$i]
    $serviceName = $service.Name
    $serviceDir = ".\$serviceName"
    
    # Create service directory if it doesn't exist
    if (-not (Test-Path -Path $serviceDir)) {
        New-Item -ItemType Directory -Path $serviceDir
    }
    
    # Calculate ports
    $mongoPort = $mongoBasePort + $i
    $mysqlPort = $mysqlBasePort + $i
    $kafkaPort = $kafkaBasePort + $i
    $zookeeperPort = $zookeeperBasePort + $i
    $kafkaUiPort = $kafkaUiBasePort + $i
    
    # Create .env file
    $envContent = @"
# Service Configuration
SERVICE_NAME=$serviceName
PORT=$($service.Port)

# MongoDB Configuration
MONGO_ROOT_USER=admin
MONGO_ROOT_PASSWORD=admin123
MONGO_USER=user
MONGO_PASSWORD=password
MONGO_PORT=$mongoPort

# MySQL Configuration
MYSQL_ROOT_PASSWORD=root123
MYSQL_USER=user
MYSQL_PASSWORD=password
MYSQL_PORT=$mysqlPort

# Kafka Configuration
KAFKA_PORT=$kafkaPort
ZOOKEEPER_PORT=$zookeeperPort
KAFKA_UI_PORT=$kafkaUiPort

# Service URLs (for inter-service communication)
TIME_SERVICE_URL=http://time-service:3000
TIMEZONE_SERVICE_URL=http://timezone-service:3000
MINUTES_SERVICE_URL=http://minutes-service:3000
AGGREGATOR_SERVICE_URL=http://aggregator-service:3000
FORMATTER_SERVICE_URL=http://formatter-service:3000
"@

    # Save .env file
    $envContent | Out-File -FilePath "$serviceDir\.env" -Force
    
    # Create docker-compose.yml from template
    $dockerComposeContent = Get-Content -Path ".\microservice-template\docker-compose.yml" -Raw
    $dockerComposeContent = $dockerComposeContent -replace '\${SERVICE_NAME}', $serviceName
    $dockerComposeContent | Out-File -FilePath "$serviceDir\docker-compose.yml" -Force
    
    Write-Host "Created configuration for $serviceName"
}

Write-Host "`nMicroservices setup complete!"
Write-Host "To start a microservice, navigate to its directory and run: docker-compose up -d"
