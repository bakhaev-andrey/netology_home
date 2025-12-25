locals {
  bastion_zone    = var.zones[0]
  grafana_zone    = var.zones[0]
  kibana_zone     = var.zones[length(var.zones) > 1 ? 1 : 0]
  prometheus_zone = var.zones[0]
  elastic_zone    = var.zones[length(var.zones) > 1 ? 1 : 0]
}

resource "yandex_compute_instance" "bastion" {
  name                      = "bastion"
  hostname                  = "bastion"
  zone                      = local.bastion_zone
  platform_id               = var.platform_id
  allow_stopping_for_update = true

  resources {
    cores         = var.vm_specs["bastion"].cores
    memory        = var.vm_specs["bastion"].memory_gb
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.default.id
      size     = var.vm_specs["bastion"].disk_gb
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public[local.bastion_zone].id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.bastion.id]
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }
}

resource "yandex_compute_instance" "web" {
  for_each                  = { for zone in var.zones : zone => zone }
  name                      = "web-${each.key}"
  hostname                  = "web-${each.key}"
  zone                      = each.key
  platform_id               = var.platform_id
  allow_stopping_for_update = true

  resources {
    cores         = var.vm_specs["web"].cores
    memory        = var.vm_specs["web"].memory_gb
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.default.id
      size     = var.vm_specs["web"].disk_gb
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private[each.key].id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.web.id]
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }
}

resource "yandex_compute_instance" "prometheus" {
  name                      = "prometheus"
  hostname                  = "prometheus"
  zone                      = local.prometheus_zone
  platform_id               = var.platform_id
  allow_stopping_for_update = true

  resources {
    cores         = var.vm_specs["prometheus"].cores
    memory        = var.vm_specs["prometheus"].memory_gb
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.default.id
      size     = var.vm_specs["prometheus"].disk_gb
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private[local.prometheus_zone].id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.prometheus.id]
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }
}

resource "yandex_compute_instance" "grafana" {
  name                      = "grafana"
  hostname                  = "grafana"
  zone                      = local.grafana_zone
  platform_id               = var.platform_id
  allow_stopping_for_update = true

  resources {
    cores         = var.vm_specs["grafana"].cores
    memory        = var.vm_specs["grafana"].memory_gb
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.default.id
      size     = var.vm_specs["grafana"].disk_gb
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public[local.grafana_zone].id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.grafana.id]
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }
}

resource "yandex_compute_instance" "elasticsearch" {
  name                      = "elasticsearch"
  hostname                  = "elasticsearch"
  zone                      = local.elastic_zone
  platform_id               = var.platform_id
  allow_stopping_for_update = true

  resources {
    cores         = var.vm_specs["elasticsearch"].cores
    memory        = var.vm_specs["elasticsearch"].memory_gb
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.default.id
      size     = var.vm_specs["elasticsearch"].disk_gb
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private[local.elastic_zone].id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.elasticsearch.id]
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }
}

resource "yandex_compute_instance" "kibana" {
  name                      = "kibana"
  hostname                  = "kibana"
  zone                      = local.kibana_zone
  platform_id               = var.platform_id
  allow_stopping_for_update = true

  resources {
    cores         = var.vm_specs["kibana"].cores
    memory        = var.vm_specs["kibana"].memory_gb
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.default.id
      size     = var.vm_specs["kibana"].disk_gb
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public[local.kibana_zone].id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.kibana.id]
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }
}
