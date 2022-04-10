terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "gcs" {
    bucket = "tf-state-ssita"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
  zone    = var.gcp_zone
}

provider "aws" {
  region = var.aws_region
}

#-----------------------------------------------------------------
# Network
resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

resource "google_compute_address" "static_web" {
  name = "ipv4-address-web"
}
resource "google_compute_address" "static_db" {
  name = "ipv4-address-db"
}

# Instances
#=================================================================
# Images
#-----------------------------------------------------------------

data "google_compute_image" "ubuntu_image" {
  family  = "ubuntu-2004-lts"
  project = "ubuntu-os-cloud"
}
data "google_compute_image" "centos_image" {
  family  = "centos-7"
  project = "centos-cloud"
}

#-----------------------------------------------------------------
# WEB
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

resource "google_compute_instance" "geo_web" {
  name         = "terraform-instance-web"
  machine_type = var.gcp_machine_type
  tags         = ["web", "dev"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu_image.self_link
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
      nat_ip = google_compute_address.static_web.address
    }
  }
  metadata_startup_script = data.template_file.template_web.rendered

  depends_on = [
    google_compute_instance.geo_db,
  ]
}
# DB
resource "google_compute_instance" "geo_db" {
  name         = "terraform-instance-db"
  machine_type = var.gcp_machine_type
  tags         = ["db", "dev"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.centos_image.self_link
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
      nat_ip = google_compute_address.static_db.address
    }
  }
  metadata_startup_script = data.template_file.template_db.rendered

}
#=================================================================
#-----------------------------------------------------------------
# Firewall
#-----------------------------------------------------------------

resource "google_compute_firewall" "allow_web" {
  name          = "allow-web"
  description   = "Allow Web access"
  network       = google_compute_network.vpc_network.name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["8080", "22", "80"]
  }
}

resource "google_compute_firewall" "allow_db_psql" {
  name        = "allow-db-psql"
  description = "Allow DB access for psql"
  network     = google_compute_network.vpc_network.name
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
  network       = google_compute_network.vpc_network.name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["db"]
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
