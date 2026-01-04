resource "aws_s3_bucket" "stellar_bucket" {
  bucket = "stellar-bucket-0011223344"

  tags = {
    Name        = "stellar_bucket"
    Environment = "Dev"
  }
}