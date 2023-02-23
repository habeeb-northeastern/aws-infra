provider "aws" {
  region  = "us-east-1"
  profile = "dev"
}

provider "aws" {
  alias   = "demo"
  region  = "us-east-1"
  profile = "demo"
}
