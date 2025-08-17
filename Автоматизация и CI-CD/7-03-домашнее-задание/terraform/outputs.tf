# Выводы Terraform для Google Cloud

output "bastion_external_ip" {
  description = "Внешний IP адрес бастион сервера"
  value       = google_compute_instance.bastion.network_interface.0.access_config.0.nat_ip
}

output "web_a_internal_ip" {
  description = "Внутренний IP адрес веб-сервера A"
  value       = google_compute_instance.web_a.network_interface.0.network_ip
}

output "web_b_internal_ip" {
  description = "Внутренний IP адрес веб-сервера B"
  value       = google_compute_instance.web_b.network_interface.0.network_ip
}

output "vpc_network_id" {
  description = "ID созданной VPC сети"
  value       = google_compute_network.develop.id
}

output "vpc_network_name" {
  description = "Имя созданной VPC сети"
  value       = google_compute_network.develop.name
}

output "subnet_a_id" {
  description = "ID подсети в зоне A"
  value       = google_compute_subnetwork.develop_a.id
}

output "subnet_b_id" {
  description = "ID подсети в зоне B"
  value       = google_compute_subnetwork.develop_b.id
}

output "ansible_inventory_file" {
  description = "Путь к сгенерированному файлу Ansible inventory"
  value       = local_file.inventory.filename
}

// Удалён вывод cloud_nat_ip, так как при AUTO_ONLY IP не доступен как значение
