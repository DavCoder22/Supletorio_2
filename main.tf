terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones  = var.availability_zones
  environment         = var.environment
}

# Security Groups Module
module "security_groups" {
  source = "./modules/security_groups"
  
  vpc_id = module.vpc.vpc_id
  environment = var.environment
}

# RDS Database Module
module "database" {
  source = "./modules/database"
  
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  db_username        = var.db_username
  db_password        = var.db_password
  security_group_id  = module.security_groups.db_security_group_id
  environment        = var.environment
}

# MSK (Kafka) Cluster Module
module "kafka" {
  source = "./modules/kafka"
  
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.security_groups.kafka_security_group_id]
  environment        = var.environment
}

# Microservices Module (repeated for each microservice)
module "microservice_1" {
  source = "./modules/microservice"
  
  name              = "microservice-1"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  vpc_cidr          = var.vpc_cidr
  security_group_id = module.security_groups.app_security_group_id
  kafka_brokers     = module.kafka.bootstrap_brokers
  db_endpoint       = module.database.db_endpoint
  db_username       = var.db_username
  db_password       = var.db_password
  environment       = var.environment
}

# Repeat for microservices 2-5 with appropriate names and configurations
# ...

# Application Load Balancer
module "alb" {
  source = "./modules/alb"
  
  name               = "${var.environment}-alb"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  security_group_id  = module.security_groups.alb_security_group_id
  environment        = var.environment
  
  # Add target groups for each microservice
  target_groups = [
    {
      name     = "microservice-1-tg"
      port     = 8080
      path     = "/health"
      protocol = "HTTP"
    },
    # Add target groups for other microservices
  ]
}

# Output important information
output "kafka_bootstrap_brokers" {
  value = module.kafka.bootstrap_brokers
}

output "rds_endpoint" {
  value = module.database.db_endpoint
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}
