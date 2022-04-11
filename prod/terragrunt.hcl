include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "..//modules/gcp_docker"
}

inputs = {
  gcp_machine_type = "e2-standard-4"
  tag              = "prod"
  web_ports        = ["8080"]
  source_ranges    = "127.0.0.1/32"
}
