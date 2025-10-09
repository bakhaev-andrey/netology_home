variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "n8n-prod-461317"
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "europe-west3"
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "europe-west3-c"
}

variable "instance_count" {
  description = "Number of VM instances"
  type        = number
  default     = 2
}

variable "machine_type" {
  description = "Machine type for instances"
  type        = string
  default     = "e2-micro"
}

variable "instance_name_prefix" {
  description = "Prefix for instance names"
  type        = string
  default     = "web-server"
}

