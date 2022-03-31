variable "region" {
  type        = string
  description = "AWS region"
  default     = "eu-north-1" # Stockholm
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC cidr block"
  default     = "10.255.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.255.1.0/24"
}

variable "allow_ports_web" {
  type        = list(any)
  description = "Ports to open for web application"
  default     = ["22", "8080"]
}

variable "all_cidr_block" {
  type        = string
  description = "Cidr block to open all word"
  default     = "0.0.0.0/0"
}

variable "instance_type" {
  type        = string
  description = "The AWS instance type"
  default     = "t3.micro"
}

variable "ssh_key_name" {
  type        = string
  description = "SSH public key name"
  default     = "ss_geocit"
}
# ___________________________________________
# You should change values starting from here
variable "domain" {
  type        = string
  description = "Hosted domain pure"
  default     = "vladkarok.ml"
}

variable "domain_web" {
  type        = string
  description = "Hosted domain web"
  default     = "geocitizen.vladkarok.ml"
}

variable "domain_web_www" {
  type        = string
  description = "Hosted domain www web"
  default     = "www.geocitizen.vladkarok.ml"
}

variable "domain_db" {
  type        = string
  description = "Hosted domain db private ip"
  default     = "dbgeo.vladkarok.ml"
}
