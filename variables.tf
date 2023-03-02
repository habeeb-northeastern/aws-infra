variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "no_of_pub_subnets" {
  default = 3
}

variable "no_of_pri_subnets" {
  default = 3
}

variable "private_subnet" {
  type    = list(string)
  default = ["10.0.2.0/24", "10.0.4.0/24", "10.0.6.0/24"]
}

variable "public_subnet" {
  type    = list(string)
  default = ["10.0.24.0/24", "10.0.26.0/24", "10.0.28.0/24"]
}

variable "ami_id" {
  type    = string
  default = "ami-0be02d8846066057c"
}

variable "app_port" {
  default = 8080
}
