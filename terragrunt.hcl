remote_state {
  backend = "gcs"
  generate = {
    path      = "_backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket   = "terr-tf-state-ssita"
    prefix   = "${path_relative_to_include()}/terragrunt_terraform.tfstate"
    project  = "elaborate-art-343920"
    location = "us-west1"
  }
}

generate "terraform_providers" {
  path      = "_providers.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
  zone    = var.gcp_zone
}
provider "aws" {
  region = var.aws_region
}
variable "gcp_project" {}
variable "gcp_region" {}
variable "gcp_zone" {}
variable "aws_region" {}
  EOF
}

# Load Variables
terraform {
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()

    required_var_files = [
      "${get_terragrunt_dir()}/common.tfvars",
    ]
  }
}
