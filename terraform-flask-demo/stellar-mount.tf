resource "aws_s3_bucket" "stellar_bucket" {
  bucket = "stellar_bucket_0011223344"

  tags = {
    Name        = "stellar_bucket"
    Environment = "Dev"
  }
}