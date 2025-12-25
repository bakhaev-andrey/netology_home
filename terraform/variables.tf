variable "yc_token" {
  description = "Yandex Cloud OAuth token or IAM token. Prefer setting via environment variable YC_TOKEN instead of tfvars."
  type        = string
  sensitive   = true
}

variable "yc_cloud_id" {
  description = "Cloud ID where resources will be created."
  type        = string
}

variable "yc_folder_id" {
  description = "Folder ID that hosts the diploma infrastructure."
  type        = string
}

variable "use_existing_network" {
  description = "Use existing VPC network instead of creating new one."
  type        = bool
  default     = false
}

variable "existing_network_id" {
  description = "ID of existing VPC network to use (if use_existing_network is true)."
  type        = string
  default     = ""
}

variable "default_zone" {
  description = "Default availability zone for regional resources."
  type        = string
  default     = "ru-central1-a"
}

variable "zones" {
  description = "Zones used for spreading instances (must match subnet cidr lists)."
  type        = list(string)
  default     = ["ru-central1-a", "ru-central1-b"]
}

variable "public_subnets" {
  description = "CIDRS for public subnets per zone. Length must match zones length."
  type        = list(string)
  default     = ["10.70.10.0/24", "10.70.11.0/24"]
}

variable "private_subnets" {
  description = "CIDRS for private subnets per zone. Length must match zones length."
  type        = list(string)
  default     = ["10.70.1.0/24", "10.70.2.0/24"]
}

variable "ssh_user" {
  description = "Default user that Ansible will connect with."
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key" {
  description = "Public SSH key contents (ssh-rsa ...)."
  type        = string
}

variable "image_family" {
  description = "Image family for compute instances."
  type        = string
  default     = "ubuntu-2204-lts"
}

variable "platform_id" {
  description = "Compute platform (standard-v3 recommended)."
  type        = string
  default     = "standard-v3"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to reach the bastion host over SSH."
  type        = string
  default     = "0.0.0.0/0"
}

variable "allowed_http_cidr" {
  description = "CIDR block allowed to access the public site via ALB."
  type        = string
  default     = "0.0.0.0/0"
}

variable "allowed_grafana_cidr" {
  description = "CIDR block allowed to access Grafana UI."
  type        = string
  default     = "0.0.0.0/0"
}

variable "allowed_kibana_cidr" {
  description = "CIDR block allowed to access Kibana UI."
  type        = string
  default     = "0.0.0.0/0"
}

variable "vm_specs" {
  description = "Instance sizing per role."
  type = map(object({
    cores     = number
    memory_gb = number
    disk_gb   = number
  }))
  default = {
    bastion = {
      cores     = 2
      memory_gb = 2
      disk_gb   = 20
    }
    web = {
      cores     = 2
      memory_gb = 2
      disk_gb   = 20
    }
    prometheus = {
      cores     = 2
      memory_gb = 4
      disk_gb   = 30
    }
    grafana = {
      cores     = 2
      memory_gb = 2
      disk_gb   = 20
    }
    elasticsearch = {
      cores     = 4
      memory_gb = 8
      disk_gb   = 50
    }
    kibana = {
      cores     = 2
      memory_gb = 4
      disk_gb   = 20
    }
  }
}

variable "snapshot_schedule" {
  description = "Snapshot schedule parameters."
  type = object({
    expression      = string
    retention_days  = number
    snapshot_labels = map(string)
  })
  default = {
    expression     = "0 3 * * *"
    retention_days = 7
    snapshot_labels = {
      purpose = "daily-backup"
    }
  }
}
