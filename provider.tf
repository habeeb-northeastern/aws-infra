provider "aws" {
  region  = "us-east-1"
  profile = "demo"
}

provider "aws" {
  alias   = "dev"
  region  = "us-east-1"
  profile = "demo"
}
