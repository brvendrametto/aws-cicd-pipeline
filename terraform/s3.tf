resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket = "tf-artifacts-br"
}

resource "aws_s3_bucket_ownership_controls" "codepipeline_artifacts_ctrl" {
  bucket = aws_s3_bucket.codepipeline_artifacts.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "codepipeline_artifacts_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.codepipeline_artifacts_ctrl]

  bucket = aws_s3_bucket.codepipeline_artifacts.id
  acl    = "private"
}