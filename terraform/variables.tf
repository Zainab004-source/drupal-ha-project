variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "us-east-1"
}

variable "allowed_ssh_cidr" {
  description = "IP address allowed to access servers through SSH"
  type        = string
  default     = "102.88.167.187/32"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "Drupal-HA"
}
variable "db_password" {
  description = "Master password for the Drupal database"
  type        = string
  sensitive   = true
}

variable "public_key" {
  description = "SSH public key for the Drupal EC2 instances"
  type        = string
  default     = ""
}
