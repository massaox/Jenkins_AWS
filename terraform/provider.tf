provider "aws" {
  version = "~> 2.52"
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
  region     = var.AWS_REGION
}

provider "local" {
  version = "~> 1.4"
}

provider "template" {
  version = "~> 2.1"
}


