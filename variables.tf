variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "db_username" {
  description = "Database administrator username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}

variable "certificate_arn" {
  description = "The ARN of the SSL certificate for the ALB"
  type        = string
}

variable "key_name" {
  description = "The key pair name for SSH access to EC2 instances"
  type        = string
  default     = ""
}

# Microservices configuration
variable "microservices" {
  description = "Configuration for microservices"
  type = map(object({
    instance_type = string
    min_size      = number
    max_size      = number
    desired_size  = number
    port          = number
    health_check  = string
  }))
  default = {
    "user-service" = {
      instance_type = "t3.micro"
      min_size      = 1
      max_size      = 3
      desired_size  = 1
      port          = 8080
      health_check  = "/health"
    }
    "order-service" = {
      instance_type = "t3.micro"
      min_size      = 1
      max_size      = 3
      desired_size  = 1
      port          = 8081
      health_check  = "/health"
    }
    "product-service" = {
      instance_type = "t3.micro"
      min_size      = 1
      max_size      = 3
      desired_size  = 1
      port          = 8082
      health_check  = "/health"
    }
    "payment-service" = {
      instance_type = "t3.micro"
      min_size      = 1
      max_size      = 3
      desired_size  = 1
      port          = 8083
      health_check  = "/health"
    }
    "notification-service" = {
      instance_type = "t3.micro"
      min_size      = 1
      max_size      = 3
      desired_size  = 1
      port          = 8084
      health_check  = "/health"
    }
  }
}
