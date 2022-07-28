terraform {
  backend "s3" {
    key            = "my-vpc"
    encrypt        = true
  }
}