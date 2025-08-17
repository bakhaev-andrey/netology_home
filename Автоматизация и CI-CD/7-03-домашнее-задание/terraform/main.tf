# Основная конфигурация Terraform для Google Cloud Platform
# Домашнее задание 7-03: Подъём инфраструктуры в Google Cloud

# Бастион сервер - единственная точка входа в приватную сеть
resource "google_compute_instance" "bastion" {
  name         = "bastion"
  machine_type = var.machine_type
  zone         = var.gcp_zone_a

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = var.disk_size_gb
    }
  }

  metadata = {
    user-data = templatefile("${path.module}/../cloud-init.yml", {
      ssh_public_key = file(var.ssh_public_key_path)
    })
    block-project-ssh-keys = true
  }

  network_interface {
    subnetwork = google_compute_subnetwork.develop_a.name
    access_config {
      // Ephemeral public IP
    }
  }

  tags = ["bastion", "ssh"]

  labels = {
    env   = "dev"
    owner = "andrey"
  }
}

# Веб-сервер A
resource "google_compute_instance" "web_a" {
  name         = "web-a"
  machine_type = var.machine_type
  zone         = var.gcp_zone_a

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = var.disk_size_gb
    }
  }

  metadata = {
    user-data = templatefile("${path.module}/../cloud-init.yml", {
      ssh_public_key = file(var.ssh_public_key_path)
    })
    block-project-ssh-keys = true
  }

  network_interface {
    subnetwork = google_compute_subnetwork.develop_a.name
    // No access_config - private IP only
  }

  tags = ["web", "http-server", "https-server"]

  labels = {
    env   = "dev"
    owner = "andrey"
  }
}

# Веб-сервер B
resource "google_compute_instance" "web_b" {
  name         = "web-b"
  machine_type = var.machine_type
  zone         = var.gcp_zone_b

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = var.disk_size_gb
    }
  }

  metadata = {
    user-data = templatefile("${path.module}/../cloud-init.yml", {
      ssh_public_key = file(var.ssh_public_key_path)
    })
    block-project-ssh-keys = true
  }

  network_interface {
    subnetwork = google_compute_subnetwork.develop_b.name
    // No access_config - private IP only
  }

  tags = ["web", "http-server", "https-server"]

  labels = {
    env   = "dev"
    owner = "andrey"
  }
}

# Генерация Ansible inventory файла
resource "local_file" "inventory" {
  content = <<-XYZ
[bastion]
${google_compute_instance.bastion.network_interface.0.access_config.0.nat_ip}

[webservers]
${google_compute_instance.web_a.network_interface.0.network_ip}
${google_compute_instance.web_b.network_interface.0.network_ip}

[webservers:vars]
ansible_user=user
ansible_ssh_private_key_file=../ssh_keys/id_rsa
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -p 22 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p -q user@${google_compute_instance.bastion.network_interface.0.access_config.0.nat_ip}"'
XYZ

  filename = "./hosts.ini"
}
