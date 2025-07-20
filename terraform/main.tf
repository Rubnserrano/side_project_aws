resource "aws_s3_bucket" "side_project_bucket" {
  bucket = "rubens-side-project-bucket"
  force_destroy = true

  tags = {
    Environment = "dev"
    Project     = "side_project"
  }
}

resource "aws_s3_bucket_ownership_controls" "side_project_ownership" {
  bucket = aws_s3_bucket.side_project_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "side_project_public_block" {
  bucket = aws_s3_bucket.side_project_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}
