resource "aws_s3_bucket" "stellar_bucket" {
  bucket = "stellar-bucket-0011223344"

  tags = {
    Name        = "stellar_bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_object" "local_files_folder" {
  bucket = aws_s3_bucket.stellar_bucket.bucket
  key    = "local-files/"
}

resource "aws_s3_object" "remote_files" {
  bucket = aws_s3_bucket.stellar_bucket.bucket
  key    = "local-files/DevOps_Details.txt"
  source = "/mnt/c/DevOps/DevOps_Details.txt"
}

