data "yandex_vpc_network" "existing" {
  count = var.use_existing_network ? 1 : 0
  network_id = var.existing_network_id != "" ? var.existing_network_id : null
  name       = var.existing_network_id == "" ? "n8n-network" : null
}

resource "yandex_vpc_network" "main" {
  count = var.use_existing_network ? 0 : 1
  name  = "fops-diploma-network"
}


resource "yandex_vpc_gateway" "nat" {
  name = "fops-nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "private" {
  name       = "fops-private-rt"
  network_id = local.network_id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat.id
  }
}

resource "yandex_vpc_subnet" "public" {
  for_each       = local.zone_public_subnets
  name           = "public-${each.key}"
  zone           = each.key
  network_id     = local.network_id
  v4_cidr_blocks = [each.value]
}

resource "yandex_vpc_subnet" "private" {
  for_each       = local.zone_private_subnets
  name           = "private-${each.key}"
  zone           = each.key
  network_id     = local.network_id
  v4_cidr_blocks = [each.value]
  route_table_id = yandex_vpc_route_table.private.id
}
