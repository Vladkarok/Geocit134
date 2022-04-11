# Network
#=================================================================
resource "google_compute_address" "static_web" {
  name = "ipv4-address-web"
}
resource "google_compute_address" "static_db" {
  name = "ipv4-address-db"
}
# Instances
#=================================================================
# Get images
#-----------------------------------------------------------------

data "google_compute_image" "ubuntu_image" {
  family  = "ubuntu-2004-lts"
  project = "ubuntu-os-cloud"
}
data "google_compute_image" "centos_image" {
  family  = "centos-7"
  project = "centos-cloud"
}
# Create template files for metadata_startup_script
#-----------------------------------------------------------------
data "template_file" "template_web" {
  template = file("./init-web.tftpl")
  vars = {
    docker_username = "${var.nexus_docker_username}"
    docker_password = "${var.nexus_docker_password}"
  }
}
data "template_file" "template_db" {
  template = file("./init-db.tftpl")
  vars = {
    docker_username = "${var.nexus_docker_username}"
    docker_password = "${var.nexus_docker_password}"
  }
}
# Web instance
#-----------------------------------------------------------------
resource "google_compute_instance" "geo_web" {
  name         = "terraform-instance-web"
  machine_type = var.gcp_machine_type
  tags         = ["web", var.tag]
  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu_image.self_link
    }
  }
  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.static_web.address
    }
  }
  metadata_startup_script = data.template_file.template_web.rendered
  depends_on = [
    google_compute_instance.geo_db
  ]
}
# Web instance
#-----------------------------------------------------------------
resource "google_compute_instance" "geo_db" {
  name         = "terraform-instance-db"
  machine_type = var.gcp_machine_type
  tags         = ["db", var.tag]
  boot_disk {
    initialize_params {
      image = data.google_compute_image.centos_image.self_link
    }
  }
  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.static_db.address
    }
  }
  metadata_startup_script = data.template_file.template_db.rendered
}
# Firewall
#=================================================================
# Firewall for web server
#-----------------------------------------------------------------
resource "google_compute_firewall" "allow_web" {
  name          = "allow-web"
  description   = "Allow Web access"
  network       = "default"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = var.web_ports
  }
}
# Firewall for db server
#-----------------------------------------------------------------
resource "google_compute_firewall" "allow_db_psql" {
  name        = "allow-db-psql"
  description = "Allow DB access for psql"
  network     = "default"
  source_tags = ["web"]
  target_tags = ["db"]
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }
}
resource "google_compute_firewall" "allow_db_ssh" {
  name          = "allow-db-ssh"
  description   = "Allow DB access for ssh"
  network       = "default"
  source_ranges = ["${var.source_ranges}"]
  target_tags   = ["db"]
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
