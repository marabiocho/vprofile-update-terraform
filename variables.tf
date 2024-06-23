variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr_block" {
  default = "196.168.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  default = [
    "196.168.1.0/24",
    "196.168.2.0/24",
  ]
}

variable "private_subnet_cidr_blocks" {
  default = [
    "196.168.4.0/24",
    "196.168.5.0/24",
  ]
}

variable "availability_zones" {
  default = [
    "us-east-1a",
    "us-east-1b",
  ]
}


