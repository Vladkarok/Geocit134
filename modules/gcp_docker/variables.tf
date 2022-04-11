# Changable variables:
variable "gcp_machine_type" {}
variable "tag" {}
variable "web_ports" {
  type = list(string)
}
variable "source_ranges" {}
# Default variables:
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
