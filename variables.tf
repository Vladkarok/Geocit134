variable "gcp_project" {
  default = "elaborate-art-343920"
}

variable "gcp_region" {
  default = "us-west1"
}

variable "gcp_zone" {
  default = "us-west1-b"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-north-1" # Stockholm
}

variable "gcp_machine_type" {
  #  default = "f1-micro"
  default = "e2-standard-4"
}

variable "miname" {
  default = "vladkarok"
}

variable "domain" {
  type        = string
  description = "Domain name"
  default     = "vladkarok.ml"
}

variable "domain_web" {
  type        = string
  description = "Hosted domain web"
  default     = "geocitizen.vladkarok.ml"
}

variable "domain_db" {
  type        = string
  description = "Hosted domain db private ip"
  default     = "dbgeo.vladkarok.ml"
}

variable "nexus_docker_username" {
  type      = string
  sensitive = true
}

variable "nexus_docker_password" {
  type      = string
  sensitive = true
}
