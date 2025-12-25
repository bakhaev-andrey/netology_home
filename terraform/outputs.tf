output "ssh_user" {
  value       = var.ssh_user
  description = "Default SSH user used by Ansible."
}

output "bastion_public_ip" {
  value       = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
  description = "Bastion public IP for SSH proxy."
}

output "bastion_private_ip" {
  value       = yandex_compute_instance.bastion.network_interface[0].ip_address
  description = "Bastion private IP (for documentation)."
}

output "web_private_ips" {
  value = { for zone, inst in yandex_compute_instance.web : zone => inst.network_interface[0].ip_address }
}

output "prometheus_private_ip" {
  value = yandex_compute_instance.prometheus.network_interface[0].ip_address
}

output "grafana_private_ip" {
  value = yandex_compute_instance.grafana.network_interface[0].ip_address
}

output "grafana_public_ip" {
  value = yandex_compute_instance.grafana.network_interface[0].nat_ip_address
}

output "elasticsearch_private_ip" {
  value = yandex_compute_instance.elasticsearch.network_interface[0].ip_address
}

output "kibana_private_ip" {
  value = yandex_compute_instance.kibana.network_interface[0].ip_address
}

output "kibana_public_ip" {
  value = yandex_compute_instance.kibana.network_interface[0].nat_ip_address
}

output "alb_public_ip" {
  value = yandex_alb_load_balancer.web.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
}

output "snapshot_schedule_id" {
  value       = yandex_compute_snapshot_schedule.daily.id
  description = "ID of the snapshot schedule applied to all VM disks."
}

output "target_group_id" {
  value = yandex_alb_target_group.web.id
}
