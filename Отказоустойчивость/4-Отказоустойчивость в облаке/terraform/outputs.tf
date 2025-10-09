output "load_balancer_ip" {
  description = "External IP address of the load balancer"
  value       = google_compute_global_address.lb_ip.address
}

output "load_balancer_url" {
  description = "URL to access the load balancer"
  value       = "http://${google_compute_global_address.lb_ip.address}"
}

output "instance_names" {
  description = "Names of created instances"
  value       = google_compute_instance.web_server[*].name
}

output "instance_ips" {
  description = "External IP addresses of instances"
  value       = google_compute_instance.web_server[*].network_interface[0].access_config[0].nat_ip
}

output "instance_group_url" {
  description = "URL of the instance group"
  value       = google_compute_instance_group.web_servers.self_link
}

output "health_check_url" {
  description = "URL of the health check"
  value       = google_compute_health_check.http_health_check.self_link
}

output "instructions" {
  description = "Next steps"
  value = <<-EOT
    
    ✅ Инфраструктура создана успешно!
    
    🌐 URL балансировщика: http://${google_compute_global_address.lb_ip.address}
    
    ⏳ Подождите 3-5 минут для:
       - Завершения установки Nginx на серверах
       - Прохождения health checks
       - Активации балансировщика
    
    🔍 Проверить статус:
       gcloud compute backend-services get-health web-backend-service --global
    
    🧪 Тестировать балансировку:
       for i in {1..10}; do curl -s http://${google_compute_global_address.lb_ip.address} | grep "Сервер:"; done
    
    📊 Веб-консоль GCP:
       https://console.cloud.google.com/net-services/loadbalancing/list/loadBalancers?project=${var.project_id}
    
  EOT
}

