resource "aws_iam_group" "developers" {
  name = "developers"
  path = "/${var.product}/"
}

resource "aws_iam_user" "user_one" {
  name = "developer-user"
}

resource "aws_iam_user" "user_two" {
  name = "test-user"
}

# will conflict with itself if used more than once with the same group
resource "aws_iam_group_membership" "team" {
  name = "tf-develop-group-membership"
  users = [
    aws_iam_user.user_one.name,
    aws_iam_user.user_two.name,
  ]
  group = aws_iam_group.developers.name
}

# attach iam policy to group
# https://learn.hashicorp.com/tutorials/terraform/aws-iam-policy
resource "aws_iam_group_policy" "developer_policy" {
  name  = "developer_policy"
  group = aws_iam_group.developers.name

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ec2:*"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "sts:AssumeRole"
        ],
        "Service": ["ec2.amazonaws.com"]
      }
    ]
  }
  EOF
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "assume_role_ec2" {
  name = "ec2_assume_role"

  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow"
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Sid": "allow_ec2_assume_role"
      }
    ]
  }
  EOF

  tags = {
    Name    = "${element(split("-", var.product), 0)}-${var.env}-${var.region}-role-policy"
    User    = var.user
    Product = "${var.product}-${var.region}"
  }
}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "vpc"{
  backend   = "s3"

  config    = {
    bucket  = "${var.product}-${var.region}-${var.env}-remote-state"
    key     = "vpc/terraform.state"
    region  = "ap-northeast-1"
  }
}

resource "aws_s3_bucket" "data" {
  bucket = "${element(split("-", var.product), 0)}-${var.env}-${var.region}-s3-data"
  acl    = "private"

  tags = {
    Name    = "${element(split("-", var.product), 0)}-${var.env}-${var.region}-s3-data"
    User    = var.user
    Product = "${var.product}-${var.region}"
  }
}