# Cloud DNS - Creating a DNS Managed Zone
resource "google_dns_managed_zone" "example_zone" {
  name        = "example-zone"
  dns_name    = "mygcp-exampleproject.com."
  description = "Managed zone for my example project."
}

# Global IP Address for Load Balancer
resource "google_compute_global_address" "example_ip" {
  name = "example-ip"
}

# Instance Template for backend instances
resource "google_compute_instance_template" "example_template" {
  name         = "example-template"
  machine_type = "f1-micro"

  tags = ["apache-server"]  # Must match your firewall target tag

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y apache2
    echo "Hello from $(hostname)" > /var/www/html/index.html
    sudo systemctl start apache2
  EOT
}


# Managed Instance Group
resource "google_compute_instance_group_manager" "example_igm" {
  name               = "example-igm"
  base_instance_name = "example"
  zone               = var.zone

  version {
    instance_template = google_compute_instance_template.example_template.self_link
  }

  target_size = 1

  named_port {
    name = "http"
    port = 80
  }
}



# Backend Service with MIG
resource "google_compute_backend_service" "example_backend_service" {
  name     = "example-backend-service"
  protocol = "HTTP"

  backend {
    group = google_compute_instance_group_manager.example_igm.instance_group
  }

  health_checks = [google_compute_http_health_check.example_health_check.self_link]
}

# Cloud Load Balancer - HTTP Health Check
resource "google_compute_http_health_check" "example_health_check" {
  name                = "example-health-check"
  request_path        = "/"
  port                = 80
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
}

# URL Map for HTTP Load Balancer
resource "google_compute_url_map" "example_url_map" {
  name            = "example-url-map"
  default_service = google_compute_backend_service.example_backend_service.self_link
}

# Target HTTP Proxy
resource "google_compute_target_http_proxy" "example_http_proxy" {
  name    = "example-http-proxy"
  url_map = google_compute_url_map.example_url_map.self_link
}

# Global Forwarding Rule
resource "google_compute_global_forwarding_rule" "example_forwarding_rule" {
  name        = "example-forwarding-rule"
  target      = google_compute_target_http_proxy.example_http_proxy.self_link
  port_range  = "80"
  ip_address  = google_compute_global_address.example_ip.address
  ip_protocol = "TCP"
}

# Create a Cloud DNS A Record
resource "google_dns_record_set" "example_a_record" {
  name         = "mygcp-exampleproject.com."
  managed_zone = google_dns_managed_zone.example_zone.name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.example_ip.address]
}
