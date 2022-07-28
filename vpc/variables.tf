
variable "region" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "private_subnets" {
  description = "List of private subnets"
  type = list(string)
}

variable "public_subnets" {
  description = "List of public subnets"
  type = list(string)
}

variable "availability_zone" {
  type = list(string)
}