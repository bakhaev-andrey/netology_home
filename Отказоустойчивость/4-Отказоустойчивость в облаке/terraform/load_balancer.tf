# Health Check для проверки работоспособности серверов
resource "google_compute_health_check" "http_health_check" {
  name                = "http-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  http_health_check {
    port         = 80
    request_path = "/"
  }
}

# Instance Group (unmanaged) для объединения VM
resource "google_compute_instance_group" "web_servers" {
  name        = "web-servers-group"
  description = "Instance group for web servers"
  zone        = var.zone

  instances = google_compute_instance.web_server[*].self_link

  named_port {
    name = "http"
    port = 80
  }
}

# Backend Service
resource "google_compute_backend_service" "web_backend" {
  name                  = "web-backend-service"
  protocol              = "HTTP"
  port_name             = "http"
  timeout_sec           = 30
  health_checks         = [google_compute_health_check.http_health_check.id]
  load_balancing_scheme = "EXTERNAL"

  backend {
    group           = google_compute_instance_group.web_servers.id
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

# URL Map
resource "google_compute_url_map" "web_url_map" {
  name            = "web-url-map"
  default_service = google_compute_backend_service.web_backend.id
}

# HTTP Proxy
resource "google_compute_target_http_proxy" "web_proxy" {
  name    = "web-http-proxy"
  url_map = google_compute_url_map.web_url_map.id
}

# Резервация внешнего IP адреса
resource "google_compute_global_address" "lb_ip" {
  name = "web-lb-ip"
}

# Forwarding Rule (входная точка для балансировщика)
resource "google_compute_global_forwarding_rule" "http_forwarding_rule" {
  name                  = "http-forwarding-rule"
  target                = google_compute_target_http_proxy.web_proxy.id
  port_range            = "80"
  ip_address            = google_compute_global_address.lb_ip.address
  load_balancing_scheme = "EXTERNAL"
}

