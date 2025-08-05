variable "subnet_ids" {
  description = "List of subnet IDs for the MSK cluster"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to the MSK cluster"
  type        = list(string)
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "kafka_version" {
  description = "The desired Kafka version"
  type        = string
  default     = "2.8.1"
}

variable "number_of_broker_nodes" {
  description = "The desired total number of broker nodes in the kafka cluster. It must be a multiple of the number of specified client subnets."
  type        = number
  default     = 3
}

variable "broker_instance_type" {
  description = "The instance type to use for the Kafka brokers"
  type        = string
  default     = "kafka.m5.large"
}

variable "ebs_volume_size" {
  description = "The size in GiB of the EBS volume for the data drive on each broker node"
  type        = number
  default     = 1000
}

variable "enhanced_monitoring" {
  description = "Enable enhanced monitoring for the MSK cluster"
  type        = bool
  default     = true
}

variable "cloudwatch_logs_enabled" {
  description = "Enable CloudWatch Logs for MSK cluster"
  type        = bool
  default     = true
}

variable "s3_logs_enabled" {
  description = "Enable S3 Logs for MSK cluster"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain logs in CloudWatch"
  type        = number
  default     = 30
}

variable "s3_logs_retention_days" {
  description = "Number of days to retain logs in S3"
  type        = number
  default     = 90
}

variable "vpc_id" {
  description = "The VPC ID where the MSK cluster will be created"
  type        = string
}
