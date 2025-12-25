# Переменные для Terraform конфигурации Google Cloud

variable "gcp_project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "gcp_region" {
  description = "Google Cloud region"
  type        = string
  default     = "us-central1"
}

variable "gcp_zone_a" {
  description = "Google Cloud zone A"
  type        = string
  default     = "us-central1-a"
}

variable "gcp_zone_b" {
  description = "Google Cloud zone B"
  type        = string
  default     = "us-central1-b"
}

variable "flow" {
  description = "Flow identifier for resource naming"
  type        = string
  default     = "dev"
}

variable "machine_type" {
  description = "Machine type for compute instances"
  type        = string
  default     = "e2-micro"
}

variable "disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
  default     = 10
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file"
  type        = string
}
