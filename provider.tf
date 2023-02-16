provider "aws" {
  region  = "ca-central-1"
  profile = "dev"
}

provider "aws" {
  alias   = "demo"
  region  = "ca-central-1"
  profile = "demo"
}
