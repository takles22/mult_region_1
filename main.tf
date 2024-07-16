resource "aws_vpc" "vpc_1" {
  provider = aws.west
  cidr_block = var.cidr_block1
  enable_dns_hostnames = true 
  tags = {
    Name      = "VPC west"
    Terraform = "true"
  }
}
resource "aws_vpc" "vpc_2" {
  cidr_block = var.cidr_block2
  enable_dns_hostnames = true 
 tags = {
    Name      = "VPC east"
    Terraform = "true"
  }
}

#2- Deploy the public subnets
resource "aws_subnet" "public_subnets_1" {
  provider = aws.west
  vpc_id                  = aws_vpc.vpc_1.id
  cidr_block              = cidrsubnet(var.cidr_block1, 8, var.public_subnets1["us-west-1a"])
  map_public_ip_on_launch = true
  availability_zone       = "us-west-1a"
  tags = {
    Name      = "west_public_subnet1"
    Terraform = "true"
  }
}

resource "aws_subnet" "public_subnets_2" {
  vpc_id                  = aws_vpc.vpc_2.id
  cidr_block              = cidrsubnet(var.cidr_block2, 8, var.public_subnets2["us-east-1a"])
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name      = "east_public_subnet2"
    Terraform = "true"
  }
}

#3- Deploy the private subnets
resource "aws_subnet" "private_subnets_1" {
  provider = aws.west
  vpc_id                  = aws_vpc.vpc_1.id
  cidr_block              = cidrsubnet(var.cidr_block1, 8, var.private_subnets1["us-west-1c"])
  map_public_ip_on_launch = true
  availability_zone       = "us-west-1a"
  tags = {
    Name      = "west_Private_subnet1"
    Terraform = "true"
  }
}

resource "aws_subnet" "private_subnets_2" {
  vpc_id                  = aws_vpc.vpc_2.id
  cidr_block              = cidrsubnet(var.cidr_block2, 8, var.private_subnets2["us-east-1b"])
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name      = "east_Private_subnet2"
    Terraform = "true"
  }
}

#4- create Internet gateway 

resource "aws_internet_gateway" "gw_1" {
  provider = aws.west
  vpc_id = aws_vpc.vpc_1.id
  tags = {
    Name      = "igw_west"
  }
}

resource "aws_internet_gateway" "gw_2" {
  vpc_id = aws_vpc.vpc_2.id
  tags = {
    Name      = "igw_east"
  }
}

# 5- route public table and attachment

resource "aws_route_table" "public_route_1" {
  provider = aws.west
  vpc_id = aws_vpc.vpc_1.id
  route {
    cidr_block = var.outgoing_cidr
    gateway_id = aws_internet_gateway.gw_1.id
  }
}

resource "aws_route_table" "public_route_2" {
  vpc_id = aws_vpc.vpc_2.id
  route {
    cidr_block = var.outgoing_cidr
    gateway_id = aws_internet_gateway.gw_2.id
  }
}

resource "aws_route_table_association" "public_asso_1" {
  provider = aws.west
  subnet_id      = aws_subnet.public_subnets_1.id
  route_table_id = aws_route_table.public_route_1.id
}

resource "aws_route_table_association" "public_asso_2" {
  subnet_id      = aws_subnet.public_subnets_2.id
  route_table_id = aws_route_table.public_route_2.id
}

# 6- route private table and attachment
# no need implicit route 



# 7- source bucket in us-east-1

resource "aws_s3_bucket" "s3_east" {
  bucket = "eastbucket456"
  force_destroy = true
    tags = {
    Name      = "east_bucket"
    Terraform = "true"
  }
}


#source bucket in us-west-1

resource "aws_s3_bucket" "s3_west" {
  provider = aws.west
  bucket = "wastbucket456"
  force_destroy = true
    tags = {
    Name      = "west_bucket"
    Terraform = "true"
  }
}

resource "aws_s3_bucket_acl" "s3_acl" {
  bucket = aws_s3_bucket.s3_west.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "s3_version" {
  bucket = aws_s3_bucket.s3_west.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role" "replication_role" {
  name = "test_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "s3.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "replication_role"
  }
}

resource "aws_iam_policy" "replication_policy" {
  name        = "s3terraform_policy"
  path        = "/"
  description = "My test policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}


resource "aws_iam_role_policy_attachment" "replication_attach" {
  role       = aws_iam_role.replication_role.name
  policy_arn = aws_iam_policy.replication_policy.arn
}

#8- Transit gateway and attachment 
resource "aws_ec2_transit_gateway" "trans_1" {
  provider = aws.west

  tags = {
    Name = "Local TGW"
  }
}

resource "aws_ec2_transit_gateway" "trans_2" {

  tags = {
    Name = "Peer TGW"
  }
}


resource "aws_ec2_transit_gateway_vpc_attachment" "tran_attch_1" {
  provider = aws.west
  subnet_ids         = [aws_subnet.public_subnets_1.id, aws_subnet.private_subnets_1.id]
  transit_gateway_id = aws_ec2_transit_gateway.trans_1.id
  vpc_id             = aws_vpc.vpc_1.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tran_attch_2" {
  subnet_ids         = [aws_subnet.public_subnets_2.id, aws_subnet.private_subnets_2.id]
  transit_gateway_id = aws_ec2_transit_gateway.trans_2.id
  vpc_id             = aws_vpc.vpc_2.id
}

resource "aws_ec2_transit_gateway_peering_attachment" "trans_attach" {
  provider = aws.west
  peer_region             = var.region_2
  peer_transit_gateway_id = aws_ec2_transit_gateway.trans_2.id
  transit_gateway_id      = aws_ec2_transit_gateway.trans_1.id

  tags = {
    Name = "TGW Peering Requestor"
  }
}

# 9- Create Application Load Blanacer 

resource "aws_lb" "alb_1" {
  provider = aws.west
  name               = "west-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg_1.id]
  subnets            = [aws_subnet.public_subnets_1.id ]

  tags = {
    Environment = "SG_WEST"
  }
}

resource "aws_lb" "alb_2" {
  name               = "east-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg_2.id]
  subnets            = [aws_subnet.public_subnets_2.id]

  tags = {
    Environment = "SG_EAST"
  }
}

# 10- ECR 

resource "aws_ecr_repository" "ecr_1" {
  provider = aws.west
  name                 = "ecr1"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_2" {
  provider = aws.west
  name                 = "ecr2"
}

