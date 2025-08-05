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

# Microservices Modules - 2 instances each
module "microservice_1" {
  source = "./modules/microservice"
  
  name              = "microservice-1"
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.private_subnet_ids
  vpc_cidr          = var.vpc_cidr
  security_group_id = module.security_groups.app_security_group_id
  kafka_brokers     = module.kafka.bootstrap_brokers
  db_endpoint       = module.database.db_endpoint
  db_username       = var.db_username
  db_password       = var.db_password
  environment       = var.environment
  instance_count    = 2
  desired_capacity  = 2
  min_size          = 2
  max_size          = 4
}

module "microservice_2" {
  source = "./modules/microservice"
  
  name              = "microservice-2"
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.private_subnet_ids
  vpc_cidr          = var.vpc_cidr
  security_group_id = module.security_groups.app_security_group_id
  kafka_brokers     = module.kafka.bootstrap_brokers
  db_endpoint       = module.database.db_endpoint
  db_username       = var.db_username
  db_password       = var.db_password
  environment       = var.environment
  instance_count    = 2
  desired_capacity  = 2
  min_size          = 2
  max_size          = 4
}

module "microservice_3" {
  source = "./modules/microservice"
  
  name              = "microservice-3"
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.private_subnet_ids
  vpc_cidr          = var.vpc_cidr
  security_group_id = module.security_groups.app_security_group_id
  kafka_brokers     = module.kafka.bootstrap_brokers
  db_endpoint       = module.database.db_endpoint
  db_username       = var.db_username
  db_password       = var.db_password
  environment       = var.environment
  instance_count    = 2
  desired_capacity  = 2
  min_size          = 2
  max_size          = 4
}

module "microservice_4" {
  source = "./modules/microservice"
  
  name              = "microservice-4"
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.private_subnet_ids
  vpc_cidr          = var.vpc_cidr
  security_group_id = module.security_groups.app_security_group_id
  kafka_brokers     = module.kafka.bootstrap_brokers
  db_endpoint       = module.database.db_endpoint
  db_username       = var.db_username
  db_password       = var.db_password
  environment       = var.environment
  instance_count    = 2
  desired_capacity  = 2
  min_size          = 2
  max_size          = 4
}

module "microservice_5" {
  source = "./modules/microservice"
  
  name              = "microservice-5"
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.private_subnet_ids
  vpc_cidr          = var.vpc_cidr
  security_group_id = module.security_groups.app_security_group_id
  kafka_brokers     = module.kafka.bootstrap_brokers
  db_endpoint       = module.database.db_endpoint
  db_username       = var.db_username
  db_password       = var.db_password
  environment       = var.environment
  instance_count    = 2
  desired_capacity  = 2
  min_size          = 2
  max_size          = 4
}

# Application Load Balancer
module "alb" {
  source = "./modules/alb"
  
  name               = "${var.environment}-alb"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  security_group_id  = module.security_groups.alb_security_group_id
  environment        = var.environment
  
  # Target groups for each microservice
  target_groups = [
    {
      name     = "microservice-1-tg"
      port     = 3000
      path     = "/health"
      protocol = "HTTP"
      target_type = "instance"
    },
    {
      name     = "microservice-2-tg"
      port     = 3000
      path     = "/health"
      protocol = "HTTP"
      target_type = "instance"
    },
    {
      name     = "microservice-3-tg"
      port     = 3000
      path     = "/health"
      protocol = "HTTP"
      target_type = "instance"
    },
    {
      name     = "microservice-4-tg"
      port     = 3000
      path     = "/health"
      protocol = "HTTP"
      target_type = "instance"
    },
    {
      name     = "microservice-5-tg"
      port     = 3000
      path     = "/health"
      protocol = "HTTP"
      target_type = "instance"
    }
  ]
  
  # Listener rules for routing traffic to each microservice
  listener_rules = [
    {
      priority = 100
      path_patterns = ["/ms1/*"]
      target_group_name = "microservice-1-tg"
    },
    {
      priority = 200
      path_patterns = ["/ms2/*"]
      target_group_name = "microservice-2-tg"
    },
    {
      priority = 300
      path_patterns = ["/ms3/*"]
      target_group_name = "microservice-3-tg"
    },
    {
      priority = 400
      path_patterns = ["/ms4/*"]
      target_group_name = "microservice-4-tg"
    },
    {
      priority = 500
      path_patterns = ["/ms5/*"]
      target_group_name = "microservice-5-tg"
    }
  ]
}

# Outputs are defined in outputs.tf
