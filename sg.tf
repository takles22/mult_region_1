# Create Security group ALBSG

resource "aws_security_group" "lb_sg_1" {
  provider = aws.west
  name        = "WEST_ALBSG"
  description = "Allow HTTP inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.vpc_1.id

  tags = {
    Name = "ALBSG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_HTTP1_ipv4" {
  security_group_id = aws_security_group.lb_sg_1.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_HTTP1_traffic_ipv4" {
  security_group_id = aws_security_group.lb_sg_1.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#------------------------------------------------#

resource "aws_security_group" "lb_sg_2" {
  provider = aws.west
  name        = "WEST_ALBSG"
  description = "Allow HTTP inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.vpc_1.id

  tags = {
    Name = "ALBSG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_HTTP1_ipv4_2" {
  security_group_id = aws_security_group.lb_sg_2.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_HTTP1_traffic_ipv4_2" {
  security_group_id = aws_security_group.lb_sg_2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
