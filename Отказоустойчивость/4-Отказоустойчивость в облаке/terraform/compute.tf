# Compute Engine instances
resource "google_compute_instance" "web_server" {
  count        = var.instance_count
  name         = "${var.instance_name_prefix}-${count.index + 1}"
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["http-server", "web-server"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 10
    }
  }

  network_interface {
    network = data.google_compute_network.default.name

    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    startup-script = file("${path.module}/startup-script.sh")
  }

  labels = {
    environment = "homework"
    purpose     = "load-balancer-test"
  }

  # Разрешаем остановку для изменений
  allow_stopping_for_update = true
}

