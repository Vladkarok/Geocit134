output "private_ip_db" {
  value = google_compute_instance.geo_db.network_interface.0.network_ip
}

output "public_ip_web" {
  value = google_compute_instance.geo_web.network_interface.0.access_config.0.nat_ip
}
