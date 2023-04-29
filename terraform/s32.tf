resource "aws_s3_bucket" "cicd_bucket" {
  bucket        = "tf-cicd-bucket-br"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "cicd_bucket_ctrl" {
  bucket = aws_s3_bucket.cicd_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "cicd_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.cicd_bucket_ctrl]

  bucket = aws_s3_bucket.cicd_bucket.id
  acl    = "private"
}