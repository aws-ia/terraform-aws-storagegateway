module "SGW_Instance" {
    source = "terraform-aws-modules/ec2-instance/aws"
    name = "EC2-S3FileGateway"
    vpc_security_group_ids = [module.ec2_sg.security_group_id]
    subnet_id = "${module.vpc.public_subnets[0]}"
    ami = var.image_id
    instance_type = var.instance_type
    key_name = aws_key_pair.keypair.key_name
    ebs_optimized     = true
    root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      volume_size = 80
    },
  ]
}
resource "aws_eip" "ip" {
  instance = module.SGW_Instance.id
  vpc      = true
}

resource "aws_key_pair" "keypair" {
  key_name   = "surampa"
  public_key = file("surampa.pub")
}

resource "aws_volume_attachment" "ebs_volume" {
  device_name = "/dev/xvdb"
  volume_id   = aws_ebs_volume.cache-disk.id
  instance_id = module.SGW_Instance.id
}

resource "aws_ebs_volume" "cache-disk" {
  availability_zone = module.vpc.azs[0]
  size              = 150
}
