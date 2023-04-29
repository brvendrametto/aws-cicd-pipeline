terraform {
  backend "s3" {
    bucket  = "tf-state-bucket-br"
    encrypt = true
    key     = "terraform.tfstate"
  }
}
