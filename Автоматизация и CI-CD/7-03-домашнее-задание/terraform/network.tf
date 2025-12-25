# Создаем VPC сеть в Google Cloud
resource "google_compute_network" "develop" {
  name                    = "develop-fops-${var.flow}"
  auto_create_subnetworks = false
}

# Создаем подсеть в зоне A
resource "google_compute_subnetwork" "develop_a" {
  name          = "develop-fops-${var.flow}-us-central1-a"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.gcp_region
  network       = google_compute_network.develop.id
}

# Создаем подсеть в зоне B
resource "google_compute_subnetwork" "develop_b" {
  name          = "develop-fops-${var.flow}-us-central1-b"
  ip_cidr_range = "10.0.2.0/24"
  region        = var.gcp_region
  network       = google_compute_network.develop.id
}

# Создаем Cloud NAT для выхода в интернет
resource "google_compute_router" "router" {
  name    = "fops-router-${var.flow}"
  region  = var.gcp_region
  network = google_compute_network.develop.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "fops-nat-${var.flow}"
  router                            = google_compute_router.router.name
  region                            = var.gcp_region
  nat_ip_allocate_option            = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Создаем правила firewall для бастиона
resource "google_compute_firewall" "bastion" {
  name    = "bastion-fw-${var.flow}"
  network = google_compute_network.develop.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["bastion"]
}

# Создаем правила firewall для веб-серверов
resource "google_compute_firewall" "web" {
  name    = "web-fw-${var.flow}"
  network = google_compute_network.develop.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]
}

# Создаем правила firewall для SSH доступа к веб-серверам через бастион
resource "google_compute_firewall" "web_ssh" {
  name    = "web-ssh-fw-${var.flow}"
  network = google_compute_network.develop.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["10.0.1.0/24", "10.0.2.0/24"]
  target_tags   = ["web"]
}

# Создаем правила firewall для внутреннего трафика
resource "google_compute_firewall" "internal" {
  name    = "internal-fw-${var.flow}"
  network = google_compute_network.develop.name

  allow {
    protocol = "tcp"
  }

  source_ranges = ["10.0.1.0/24", "10.0.2.0/24"]
}

# Создаем правила firewall для исходящего трафика
resource "google_compute_firewall" "egress" {
  name    = "egress-fw-${var.flow}"
  network = google_compute_network.develop.name
  direction = "EGRESS"

  allow {
    protocol = "tcp"
  }

  destination_ranges = ["0.0.0.0/0"]
}
