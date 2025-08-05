# VPC Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

# Database Outputs
output "db_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = module.database.db_endpoint
}

output "db_instance_id" {
  description = "The RDS instance ID"
  value       = module.database.db_identifier
}

# Kafka (MSK) Outputs
output "kafka_bootstrap_brokers" {
  description = "Plaintext connection host:port pairs for the Kafka brokers"
  value       = module.kafka.bootstrap_brokers
}

output "kafka_zookeeper_connect_string" {
  description = "ZooKeeper connection string"
  value       = module.kafka.zookeeper_connect_string
}

# ALB Outputs
output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "The canonical hosted zone ID of the load balancer"
  value       = module.alb.alb_zone_id
}

# Microservices Outputs
output "microservice_target_groups" {
  description = "Map of microservice names to their target group ARNs"
  value       = { for k, v in module.microservices : k => v.target_group_arn }
}

# Security Group Outputs
output "security_group_ids" {
  description = "Map of security group names to their IDs"
  value = {
    alb    = module.security_groups.alb_security_group_id
    app    = module.security_groups.app_security_group_id
    db     = module.security_groups.db_security_group_id
    kafka  = module.security_groups.kafka_security_group_id
  }
}

# IAM Role Outputs
output "ec2_instance_profile_arn" {
  description = "The ARN of the IAM instance profile for EC2 instances"
  value       = { for k, v in module.microservices : k => v.ec2_instance_profile_arn }
}

# S3 Bucket Outputs
output "s3_bucket_arns" {
  description = "Map of S3 bucket names to their ARNs"
  value = {
    alb_logs = module.alb.alb_logs_bucket_arn
    msk_logs = module.kafka.msk_logs_bucket_arn
  }
}

# Current AWS Account and Region
output "current_account_id" {
  description = "The AWS Account ID number of the account that owns or contains the current entity"
  value       = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}
