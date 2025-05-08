output "dns_zone_name" {
  value = google_dns_managed_zone.example_zone.name
}

output "load_balancer_ip" {
  value = google_compute_global_address.example_ip.address
}

output "load_balancer_external_ip" {
  description = "The external IP address for the load balancer"
  value       = google_compute_global_address.example_ip.address
}

output "backend_service_name" {
  value = google_compute_backend_service.example_backend_service.name
}

output "connection_name" {
  value = google_sql_database_instance.db.connection_name
}

output "db_connection_string" {
  description = "PostgreSQL connection string without password"
  value       = "postgresql://${google_sql_user.db_user.name}@${google_sql_database_instance.db.ip_address[0].ip_address}:5432/${var.db_name}"
}


output "db_instance_ip" {
  description = "The public IP address of the database instance"
  value       = google_sql_database_instance.db.ip_address[0].ip_address
}

output "instance_group_manager_name" {
  description = "The name of the instance group manager"
  value       = google_compute_instance_group_manager.example_igm.name
}

output "load_balancer_url" {
  description = "The URL of the load balancer"
  value       = "http://${google_compute_global_address.example_ip.address}"
}
