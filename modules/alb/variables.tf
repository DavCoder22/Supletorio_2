variable "name" {
  description = "The name of the load balancer"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "The VPC ID where the load balancer will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the load balancer"
  type        = list(string)
}

variable "security_group_id" {
  description = "The security group ID to attach to the load balancer"
  type        = string
}

variable "certificate_arn" {
  description = "The ARN of the SSL certificate for HTTPS"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain ALB access logs"
  type        = number
  default     = 90
}

variable "target_groups" {
  description = "List of target group configurations"
  type = list(object({
    name          = string
    port          = number
    protocol      = string
    health_check  = object({
      path                = string
      healthy_threshold   = number
      unhealthy_threshold = number
      timeout             = number
      interval            = number
      matcher             = string
    })
    priority      = number
    host_header   = optional(string)
    path_pattern  = optional(string)
  }))
  default = []
}
