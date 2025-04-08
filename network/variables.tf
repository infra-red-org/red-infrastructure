variable "project_id" {
  description = "The project ID"
  type        = string
}

variable "region" {
  description = "The region for the subnet"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
}

variable "subnet_cidr" {
  description = "The CIDR range for the subnet"
  type        = string
}

variable "pod_cidr" {
  description = "The CIDR range for pods"
  type        = string
}

variable "service_cidr" {
  description = "The CIDR range for services"
  type        = string
}
