locals {
  # Validation: ensure subnet lists match zones length
  _public_subnets_check = length(var.public_subnets) == length(var.zones) ? true : tobool("ERROR: public_subnets length (${length(var.public_subnets)}) must match zones length (${length(var.zones)})")
  _private_subnets_check = length(var.private_subnets) == length(var.zones) ? true : tobool("ERROR: private_subnets length (${length(var.private_subnets)}) must match zones length (${length(var.zones)})")

  zone_public_subnets  = { for idx, zone in var.zones : zone => var.public_subnets[idx] }
  zone_private_subnets = { for idx, zone in var.zones : zone => var.private_subnets[idx] }

  web_nodes = [for idx, zone in var.zones : {
    name = format("web-%s", substr(zone, -1, 1))
    zone = zone
    cidr = local.zone_private_subnets[zone]
  }]

  # Network ID: use existing or create new
  network_id = var.use_existing_network ? data.yandex_vpc_network.existing[0].network_id : yandex_vpc_network.main[0].id
}
