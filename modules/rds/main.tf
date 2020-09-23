data "terraform_remote_state" "vpc"{
  backend   = "s3"

  config    = {
    bucket  = "${var.product}-${var.region}-${var.env}-remote-state"
    key     = "vpc/terraform.state"
    region  = "ap-northeast-1"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "db instance subnet group"
  subnet_ids = [data.terraform_remote_state.vpc.outputs.private_subnets]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_security_group" "db" {
  name        = "${var.product}-${var.env}-${var.db_name}-sg"
  description = "db traffic"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 3306
    protocol    = "tcp"
    security_group_id = var.server_sg_id
  }

  tags = {
    Name    = "${var.product}-${var.env}-${var.db_name}-sg"
    User    = var.user
    Env     = var.env
    Product = var.product
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_instance" "db" {
  allocated_storage    = 50
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "sampledb"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql5.7"
  apply_immediately    = true

  tags = {
    Name    = "${var.product}-${var.env}-${var.db_name}"
    User    = var.user
    Env     = var.env
    Product = var.product
  }

  lifecycle {
    prevent_destroy = true
  }
}