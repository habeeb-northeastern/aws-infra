module "myNetwork" {
  source          = "./module/networking"
  cidr            = "10.0.0.0/16"
  region          = "us-east-1"
  available_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  profile         = "demo"
  ami_id          = "ami-02badb092d4d180e3"
  app_port        = "8080"
  password        = "Coffeebites1$"
  name            = "csye6225"
  AWS_KEY         = "SW/dtHWwa+STX99V1o9jnSPbID0ahYpwZSpV8bLy"
  AWS_ID          = "AKIASEE4BOWZQWZFG24R"

}
