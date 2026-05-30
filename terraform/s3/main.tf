resource "aws_s3_bucket" "artifacts" {
  bucket = var.bucket_name

  tags = {
    Name        = "Jenkins Artifacts"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "artifacts_versioning" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

## this resource enables server-side Encryption on the s3 bucket by default.(encryts data before storing it)
resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts_encryption" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"                  ## AES256 is a specifies the encryption algorithm, 
                                                ## aws automatically create and manages the encryption key,
                                                ## rotates and protect them internally.
      # we have another option that is sse-kms
      # we didn't used it cause of its paid                                           
    }
  }
} 

resource "aws_s3_bucket_public_access_block" "artifacts_public_access" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
