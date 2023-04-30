terraform {
  #required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.65.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "tf_state" {
  bucket = "tf-state-bucket-br"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "tf_state_ctrl" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "tf_state_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.tf_state_ctrl]

  bucket = aws_s3_bucket.tf_state.id
  acl    = "private"
}