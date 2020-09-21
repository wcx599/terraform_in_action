resource "aws_subnet" "private" {
  count = length(var.availability_zones)
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(
                          var.vpc_cidr,
                          length(var.availability_zones),
                          count.index + length(var.availability_zones)
                )

  availability_zone = var.availability_zones[count.index]
  # private subnet instance will not assign eip
  map_public_ip_on_launch = false
  depends_on = [aws_subnet.public]

  tags ={
    name        = format("%s-%s-public-%d", var.product, var.env, count.index)
    user        = var.user
    Is_private  = "true"
  }
}
