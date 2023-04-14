variable "cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "available_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]

}
variable "region" {
  type    = string
  default = "us-east-1"

}
variable "profile" {
  type = string

}
variable "ami_id" {
  type = string

}
variable "app_port" {
  type    = string
  default = "8080"

}
variable "password" {
  type    = string
  default = "Coffeebites1$"

}
variable "name" {
  type    = string
  default = "csye6225"

}
variable "AWS_KEY" {
  type    = string
  default = "SW/dtHWwa+STX99V1o9jnSPbID0ahYpwZSpV8bLy"
}
variable "AWS_ID" {
  type    = string
  default = "AKIASEE4BOWZQWZFG24R"
}

variable "record_name" {
  type    = string
  default = "demo.habeebuddinmir.live"
}
variable "record_zone_id" {
  type    = string
  default = "Z060912111HCKNH0SG9LA"
}
