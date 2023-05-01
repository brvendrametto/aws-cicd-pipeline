resource "aws_s3_bucket" "codepipeline_artifacts1" {
  bucket        = "s3-brvendra1"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "codepipeline_artifacts_ctrl1" {
  bucket = aws_s3_bucket.codepipeline_artifacts1.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "codepipeline_artifacts_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.codepipeline_artifacts_ctrl1]

  bucket = aws_s3_bucket.codepipeline_artifacts1.id
  acl    = "private"
}