# Используем default VPC сеть
data "google_compute_network" "default" {
  name = "default"
}

# Firewall rule для HTTP трафика
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http-lb"
  network = data.google_compute_network.default.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]

  description = "Allow HTTP traffic from anywhere"
}

# Firewall rule для health checks
resource "google_compute_firewall" "allow_health_check" {
  name    = "allow-health-check"
  network = data.google_compute_network.default.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  # Диапазоны IP для Google Cloud Health Checks
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  target_tags   = ["http-server"]

  description = "Allow health check traffic from Google Cloud"
}

