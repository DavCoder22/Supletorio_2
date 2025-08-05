#!/bin/bash

# Set environment variables
export ENVIRONMENT=${environment}
export APP_NAME=${app_name}
export DB_HOST=${db_host}
export DB_NAME=${db_name}
export DB_USERNAME=${db_username}
export DB_PASSWORD=${db_password}
export KAFKA_BROKERS=${kafka_brokers}

# Update the system
yum update -y

# Install required packages
yum install -y \
    amazon-cloudwatch-agent \
    java-11-amazon-corretto \
    docker \
    git \
    jq

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Add ec2-user to the docker group
usermod -aG docker ec2-user

# Configure CloudWatch Agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << EOF
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "/aws/ec2/${ENVIRONMENT}-${APP_NAME}/system",
            "log_stream_name": "{instance_id}",
            "retention_in_days": 30
          },
          {
            "file_path": "/var/log/docker",
            "log_group_name": "/aws/ec2/${ENVIRONMENT}-${APP_NAME}/docker",
            "log_stream_name": "{instance_id}",
            "retention_in_days": 30
          }
        ]
      }
    }
  },
  "metrics": {
    "metrics_collected": {
      "disk": {
        "measurement": [
          "used_percent"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "/"
        ]
      },
      "mem": {
        "measurement": [
          "mem_used_percent"
        ],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF

# Start CloudWatch Agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# Start Docker service
systemctl enable docker
systemctl start docker

# Create application directory
mkdir -p /opt/${APP_NAME}
chown -R ec2-user:ec2-user /opt/${APP_NAME}

# Create environment file for the application
cat > /opt/${APP_NAME}/.env << EOF
ENVIRONMENT=${ENVIRONMENT}
APP_NAME=${APP_NAME}
DB_HOST=${DB_HOST}
DB_NAME=${DB_NAME}
DB_USERNAME=${DB_USERNAME}
DB_PASSWORD=${DB_PASSWORD}
KAFKA_BROKERS=${KAFKA_BROKERS}
EOF

# Create a simple health check endpoint
cat > /opt/${APP_NAME}/health_check.sh << 'EOL'
#!/bin/bash

# Check if Docker is running
if ! systemctl is-active --quiet docker; then
  echo "Docker is not running"
  exit 1
fi

# Check if application container is running
if [ -z "$(docker ps -q -f name=${APP_NAME})" ]; then
  echo "Application container is not running"
  exit 1
fi

# Check if application is responding
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/health)
if [ "$RESPONSE" -ne 200 ]; then
  echo "Application health check failed with status code $RESPONSE"
  exit 1
fi

echo "Application is healthy"
exit 0
EOL

chmod +x /opt/${APP_NAME}/health_check.sh

# Create a systemd service for the application
cat > /etc/systemd/system/${APP_NAME}.service << EOF
[Unit]
Description=${APP_NAME} Microservice
After=docker.service
Requires=docker.service

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/${APP_NAME}
EnvironmentFile=/opt/${APP_NAME}/.env
ExecStart=/usr/local/bin/docker-compose up
ExecStop=/usr/local/bin/docker-compose down
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Create a cron job for health checks
cat > /etc/cron.d/health-check << EOF
* * * * * root /opt/${APP_NAME}/health_check.sh || systemctl restart ${APP_NAME}.service
EOF

# Enable and start the application service
systemctl enable ${APP_NAME}.service
systemctl start ${APP_NAME}.service

echo "User data script completed" > /tmp/user-data-complete
