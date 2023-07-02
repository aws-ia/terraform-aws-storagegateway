##########################
## Create EC2 Instance ##
##########################

resource "aws_instance" "ec2-sgw" {
  ami                    = data.aws_ami.sgw-ami.id
  vpc_security_group_ids = var.create_security_group ? [aws_security_group.ec2_sg["ec2_sg"].id] : [var.security_group_id]
  subnet_id              = var.subnet_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ec2_sgw_key_pair.key_name
  ebs_optimized          = true
  availability_zone      = var.availability_zone

  root_block_device {
    encrypted   = true
    volume_size = try(tonumber(var.root_block_device["disk_size"]), 80)
    volume_type = try(var.root_block_device["volume_type"], "gp3")
    kms_key_id  = try(var.root_block_device["kms_key_id"], null)
  }
  tags = {
    Name = var.name
  }

  lifecycle {
    # the Security group ID must be non-empty or create_security_group must be true
    precondition {
      condition     = var.create_security_group || try((length(var.security_group_id) > 3 && substr(var.security_group_id, 0, 3) == "sg-"),false)
      error_message = "Please specify create_security_group = true or provide a valid Security Group ID for var.security_group_id"
    }
  }
}

data "aws_ami" "sgw-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["aws-storage-gateway-*"]
  }
}

resource "aws_eip" "ip" {
  instance = aws_instance.ec2-sgw.id
}

resource "aws_key_pair" "ec2_sgw_key_pair" {
  key_name   = var.ssh_key_name
  public_key = file(var.ssh_public_key_path)
}

resource "aws_volume_attachment" "ebs_volume" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.cache-disk.id
  instance_id = aws_instance.ec2-sgw.id
}

resource "aws_ebs_volume" "cache-disk" {
  availability_zone = aws_instance.ec2-sgw.availability_zone
  encrypted         = true
  size              = try(tonumber(var.cache_block_device["disk_size"]), 150)
  type              = try(var.cache_block_device["volume_type"], "gp3")
  kms_key_id        = try(var.cache_block_device["kms_key_id"], null)
}