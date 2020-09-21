resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true

  tags ={
    user = var.user
    name = "${var.product}-${var.env}-${var.region}vpc"
  }
}

resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name         = "${var.product}-${var.region}-${var.env}-priv.${var.domain}"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    Name = "${var.product}-${var.env}-dhcp"
    User = var.user
  }
}

resource "aws_default_route_table" "main-route-table" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  tags = {
    Name = "${var.product}-${var.env}-rt-default-main"
    User = var.user
  }
}

