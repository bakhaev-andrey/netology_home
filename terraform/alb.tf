resource "yandex_alb_target_group" "web" {
  name = "web-target-group"

  dynamic "target" {
    for_each = { for idx, inst in yandex_compute_instance.web : idx => inst }
    content {
      subnet_id  = target.value.network_interface[0].subnet_id
      ip_address = target.value.network_interface[0].ip_address
    }
  }
}

resource "yandex_alb_backend_group" "web" {
  name = "web-backend"

  http_backend {
    name             = "web-http"
    port             = 80
    target_group_ids = [yandex_alb_target_group.web.id]

    load_balancing_config {
      panic_threshold = 50
    }

    healthcheck {
      timeout             = "2s"
      interval            = "5s"
      unhealthy_threshold = 2
      healthy_threshold   = 2

      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "web" {
  name = "web-router"
}

resource "yandex_alb_virtual_host" "web" {
  name           = "web-virtualhost"
  http_router_id = yandex_alb_http_router.web.id

  route {
    name = "root"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web.id
      }
    }
  }
}

resource "yandex_alb_load_balancer" "web" {
  name               = "web-alb"
  network_id         = local.network_id
  security_group_ids = [yandex_vpc_security_group.alb.id]

  allocation_policy {
    dynamic "location" {
      for_each = toset(var.zones)
      content {
        zone_id   = location.value
        subnet_id = yandex_vpc_subnet.public[location.value].id
      }
    }
  }

  listener {
    name = "http-listener"
    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }
    # Примечание: В задании указан тип "auto", но в Yandex Cloud ALB используется тип "http"
    # для HTTP listener. Тип "auto" не существует в API Yandex Cloud ALB.
    http {
      handler {
        http_router_id = yandex_alb_http_router.web.id
      }
    }
  }
}
