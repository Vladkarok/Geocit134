include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "..//modules/gcp_docker"
}

inputs = {
  gcp_machine_type = "f1-micro"
  tag              = "dev"
  web_ports        = ["22", "8080"]
  source_ranges    = "0.0.0.0/0"
}
