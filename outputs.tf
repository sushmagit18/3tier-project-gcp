output "dns_zone_name" {
  value = google_dns_managed_zone.example_zone.name
}

output "load_balancer_ip" {
  value = google_compute_global_address.example_ip.address
}

output "backend_service_name" {
  value = google_compute_backend_service.example_backend_service.name
}

