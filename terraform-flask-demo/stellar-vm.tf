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

resource "tls_private_key" "stellar_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "stellar_keypair" {
  key_name   = "stellar-key"
  public_key = tls_private_key.stellar_key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.stellar_key.private_key_pem
  filename        = "/mnt/c/DevOps/AWS/stellar-key.pem"
  file_permission = "0400"
}

resource "aws_instance" "stellar_instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.stellar_subnet1.id
  security_groups             = [aws_security_group.stellar_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.stellar_devops_instance_profile.name
  key_name                    = aws_key_pair.stellar_keypair.key_name
  associate_public_ip_address = true

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

output "instance_public_ip" {
  value = aws_instance.stellar_instance.public_ip
}

output "private_key_path" {
  value = "/mnt/c/DevOps/AWS/stellar-key.pem"
}

