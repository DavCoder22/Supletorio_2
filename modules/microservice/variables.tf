variable "name" {
  description = "Name of the microservice"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "The VPC ID where the microservice will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Auto Scaling Group"
  type        = list(string)
}

variable "security_group_id" {
  description = "The security group ID to attach to the EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "The key pair name to use for SSH access"
  type        = string
  default     = ""
}

variable "volume_size" {
  description = "The size of the root volume in GB"
  type        = number
  default     = 20
}

variable "desired_capacity" {
  description = "The desired number of instances in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "The minimum number of instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "The maximum number of instances in the Auto Scaling Group"
  type        = number
  default     = 4
}

variable "target_group_arns" {
  description = "List of target group ARNs to register with the Auto Scaling Group"
  type        = list(string)
  default     = []
}

variable "db_endpoint" {
  description = "The database endpoint"
  type        = string
  default     = ""
}

variable "db_name" {
  description = "The database name"
  type        = string
  default     = ""
}

variable "db_username" {
  description = "The database username"
  type        = string
  default     = ""
  sensitive   = true
}

variable "db_password" {
  description = "The database password"
  type        = string
  default     = ""
  sensitive   = true
}

variable "kafka_brokers" {
  description = "Comma-separated list of Kafka bootstrap brokers"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
