resource "yandex_vpc_security_group" "bastion" {
  name       = "sg-bastion"
  network_id = local.network_id

  ingress {
    protocol       = "TCP"
    description    = "SSH from trusted networks"
    v4_cidr_blocks = [var.allowed_ssh_cidr]
    port           = 22
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "alb" {
  name       = "sg-alb"
  network_id = local.network_id

  # Allow HTTP from internet
  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = [var.allowed_http_cidr]
    port           = 80
    description    = "HTTP from internet"
  }

  # Allow health checks from Yandex Cloud ALB service IPs (required for ALB to work)
  # According to Yandex Cloud docs, ALB health checks come from these ranges
  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["198.18.235.0/24", "198.18.248.0/24"]
    description    = "ALB health checks"
    # No port restriction - health checks can use any port
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "Allow all outbound traffic"
  }
}

resource "yandex_vpc_security_group" "web" {
  name       = "sg-web"
  network_id = local.network_id

  ingress {
    description       = "SSH via bastion"
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion.id
  }

  ingress {
    description    = "HTTP from ALB (via public subnets)"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = concat(
      [for subnet in values(yandex_vpc_subnet.public) : subnet.v4_cidr_blocks[0]],
      ["198.18.235.0/24", "198.18.248.0/24"]  # ALB health check IPs
    )
  }

  ingress {
    description       = "Node exporter"
    protocol          = "TCP"
    port              = 9100
    security_group_id = yandex_vpc_security_group.prometheus.id
  }

  ingress {
    description       = "Nginx log exporter"
    protocol          = "TCP"
    port              = 4040
    security_group_id = yandex_vpc_security_group.prometheus.id
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [
    yandex_vpc_security_group.bastion,
    yandex_vpc_security_group.prometheus
  ]
}

resource "yandex_vpc_security_group" "prometheus" {
  name       = "sg-prometheus"
  network_id = local.network_id

  ingress {
    description       = "SSH via bastion"
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion.id
  }

  ingress {
    description       = "Prometheus UI"
    protocol          = "TCP"
    port              = 9090
    security_group_id = yandex_vpc_security_group.grafana.id
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "grafana" {
  name       = "sg-grafana"
  network_id = local.network_id

  ingress {
    description    = "Grafana HTTP"
    protocol       = "TCP"
    port           = 3000
    v4_cidr_blocks = [var.allowed_grafana_cidr]
  }

  ingress {
    description       = "SSH via bastion"
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion.id
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "elasticsearch" {
  name       = "sg-elasticsearch"
  network_id = local.network_id

  ingress {
    description       = "SSH via bastion"
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion.id
  }

  ingress {
    description       = "Filebeat"
    protocol          = "TCP"
    port              = 9200
    security_group_id = yandex_vpc_security_group.web.id
  }

  ingress {
    description       = "Kibana"
    protocol          = "TCP"
    port              = 9200
    security_group_id = yandex_vpc_security_group.kibana.id
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [
    yandex_vpc_security_group.bastion,
    yandex_vpc_security_group.web,
    yandex_vpc_security_group.kibana
  ]
}

resource "yandex_vpc_security_group" "kibana" {
  name       = "sg-kibana"
  network_id = local.network_id

  ingress {
    description    = "Kibana HTTP"
    protocol       = "TCP"
    port           = 5601
    v4_cidr_blocks = [var.allowed_kibana_cidr]
  }

  ingress {
    description       = "SSH via bastion"
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion.id
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
