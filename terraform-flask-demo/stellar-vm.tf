data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
resource "aws_instance" "stellar_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.stellar_subnet1.id
  security_groups = [aws_security_group.stellar_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              wget https://s3.amazonaws.com/mountpoint-s3-release/latest/x86_64/mount-s3.deb
              apt-get install -y ./mount-s3.deb
              mkdir /mnt/stellar_bucket
              mount-s3 ${aws_s3_bucket.stellar_bucket.bucket} /mnt/stellar_bucket
              EOF

  tags = {
    Name = "stellar_instance"
  }
}

