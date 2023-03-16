variable "cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "available_zones" {
  type = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]

}
variable "region" {
  type    = string
  default = "us-east-1"
}

variable "app_port" {
  default = 8080
}

variable "profile" {
  type    = string
  default = "prod"
}
variable "ami_id" {
  type    = string
  default = "ami-02badb092d4d180e3"

}

variable "password" {
  type = string
  default = "Coffeebites1$"
}
variable "name" {
  type = string
  default = "csye6225"
}
variable "AWS_KEY" {
  type    = string
  default = "AKIASEE4BOWZQWZFG24R"
}
variable "AWS_ID" {
  type    = string
  default = "SW/dtHWwa+STX99V1o9jnSPbID0ahYpwZSpV8bLy"
}
variable "aws_eip_vpc" {
  type        = bool
  default = true
}
variable "route53_record_name" {
  type        = string
  default = "habeebuddinmir.live"
}

variable "route53_record_zone_id" {
  type        = string
  default = "Z06139253KWDTBJLHKVYA"
}

variable "route53_record_type" {
  type        = string
  default = "A"
}

variable "route53_record_ttl" {
  type        = string
  default = "60"
}