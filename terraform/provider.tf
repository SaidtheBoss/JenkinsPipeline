provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      owner = "said"
    }
  }
}

terraform {
 backend "s3" {
  bucket = "websites23r3rfd"
  key    = "tfstate"
  region = "us-east-1"
  }
}