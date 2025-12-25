terraform {
  required_version = ">= 1.5.7"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.104.0"
    }
  }
}

provider "yandex" {
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.default_zone
  token     = var.yc_token
}
