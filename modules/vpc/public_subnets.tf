# enable IGW for VPC
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.main.id

  tags = {
    name = "${var.product}-${var.env}-igw"
    user = var.user
  }
}

# setup public subnet cidr and count==2
resource "aws_subnet" "public" {
  count = length(var.availability_zones)
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(
                          var.vpc_cidr,
                          length(var.availability_zones),
                          count.index + length(var.availability_zones)
                )

  availability_zone = var.availability_zones[count.index]
  # for public subnet instances auto assign eip
  map_public_ip_on_launch = true
  depends_on = [aws_internet_gateway.default]

  tags ={
    name = format("%s-%s-public-%d", var.product, var.env, count.index)
    user = var.user
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    name = "${var.product}-${var.env}-rt-main"
    user = var.user
  }
}

# enable public subnet to access internet
resource "aws_route" "main" {
  route_table_id = aws_route_table.main.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.default.id
}

# associate route table entry with public subnets [element]
resource "aws_route_table_association" "public" {
  count           = length(var.availability_zones)
  route_table_id  = aws_route_table.main.id
  subnet_id       = element(aws_subnet.public.*.id, count.index)
}