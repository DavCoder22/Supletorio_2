# MSK Configuration
resource "aws_msk_configuration" "config" {
  kafka_versions = ["2.8.1"]
  name           = "${var.environment}-msk-configuration"

  server_properties = <<PROPERTIES
auto.create.topics.enable = true
delete.topic.enable = true
log.retention.hours = 168
num.io.threads = 8
num.network.threads = 5
num.partitions = 3
num.replica.fetchers = 2
replica.lag.time.max.ms = 30000
socket.request.max.bytes = 104857600
unclean.leader.election.enable = true
zookeeper.session.timeout.ms = 18000
  PROPERTIES
}

# MSK Cluster
resource "aws_msk_cluster" "main" {
  cluster_name           = "${var.environment}-msk-cluster"
  kafka_version         = "2.8.1"
  number_of_broker_nodes = 3
  
  broker_node_group_info {
    instance_type   = "kafka.m5.large"
    ebs_volume_size = 1000  # 1TB per broker
    
    client_subnets = var.subnet_ids
    
    security_groups = var.security_group_ids
  }
  
  configuration_info {
    arn      = aws_msk_configuration.config.arn
    revision = aws_msk_configuration.config.latest_revision
  }
  
  encryption_info {
    encryption_in_transit {
      client_broker = "TLS_PLAINTEXT"
      in_cluster    = true
    }
  }
  
  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = true
      }
      
      node_exporter {
        enabled_in_broker = true
      }
    }
  }
  
  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.msk_logs.name
      }
      
      s3 {
        enabled = true
        bucket  = aws_s3_bucket.msk_logs_bucket.id
        prefix  = "logs/msk/"
      }
    }
  }
  
  tags = {
    Name        = "${var.environment}-msk-cluster"
    Environment = var.environment
  }
}

# CloudWatch Log Group for MSK
resource "aws_cloudwatch_log_group" "msk_logs" {
  name              = "/aws/msk/${var.environment}-cluster-logs"
  retention_in_days = 30
  
  tags = {
    Name        = "${var.environment}-msk-logs"
    Environment = var.environment
  }
}

# S3 Bucket for MSK Logs
resource "aws_s3_bucket" "msk_logs_bucket" {
  bucket = "${var.environment}-msk-logs-${data.aws_caller_identity.current.account_id}"
  
  tags = {
    Name        = "${var.environment}-msk-logs"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_acl" "msk_logs_acl" {
  bucket = aws_s3_bucket.msk_logs_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "msk_logs_lifecycle" {
  bucket = aws_s3_bucket.msk_logs_bucket.id
  
  rule {
    id     = "log-rotation"
    status = "Enabled"
    
    expiration {
      days = 90
    }
    
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

# IAM Role for MSK to access CloudWatch and S3
resource "aws_iam_role" "msk_logging" {
  name = "${var.environment}-msk-logging-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "kafka.amazonaws.com"
        }
      }
    ]
  })
  
  tags = {
    Name        = "${var.environment}-msk-logging-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "msk_cloudwatch" {
  role       = aws_iam_role.msk_logging.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_role_policy_attachment" "msk_s3" {
  role       = aws_iam_role.msk_logging.name
  policy_arn = aws_iam_policy.msk_s3_logging.arn
}

resource "aws_iam_policy" "msk_s3_logging" {
  name        = "${var.environment}-msk-s3-logging"
  description = "Policy for MSK to write logs to S3"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "${aws_s3_bucket.msk_logs_bucket.arn}",
          "${aws_s3_bucket.msk_logs_bucket.arn}/*"
        ]
      }
    ]
  })
}

# Data source for current AWS account
# Data source for current AWS account
data "aws_caller_identity" "current" {}

# Outputs
output "bootstrap_brokers" {
  description = "Plaintext connection host:port pairs"
  value       = aws_msk_cluster.main.bootstrap_brokers
}

output "bootstrap_brokers_tls" {
  description = "TLS connection host:port pairs"
  value       = aws_msk_cluster.main.bootstrap_brokers_tls
}

output "cluster_arn" {
  description = "Amazon Resource Name (ARN) of the MSK cluster"
  value       = aws_msk_cluster.main.arn
}

output "zookeeper_connect_string" {
  description = "A comma separated list of one or more hostname:port pairs to use to connect to the Apache Zookeeper cluster"
  value       = aws_msk_cluster.main.zookeeper_connect_string
}

output "current_version" {
  description = "Current version of the MSK Cluster used for updates"
  value       = aws_msk_cluster.main.current_version
}

output "logging_role_arn" {
  description = "The ARN of the IAM role used for logging"
  value       = aws_iam_role.msk_logging.arn
}

output "s3_logging_bucket" {
  description = "The name of the S3 bucket used for MSK logs"
  value       = aws_s3_bucket.msk_logs_bucket.id
}
