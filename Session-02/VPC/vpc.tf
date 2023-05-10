resource "aws_vpc" "automated-vpc" { # This Name belongs to terraform
    cidr_block ="10.0.0.0/16"
    instance_tenancy = "default"


tags = {
    Name = "automated-vpc"
}
}

resource "aws_subnet" "pub-sub-automated" { # This is belongs to Terraform
vpc_id = aws_vpc.automated-vpc.id # it will feach vpc id above code
cidr_block = "10.0.1.0/24"

 tags = {
    Name = "pub-sub-automated" # this is belongs to AWS
  }
}

resource "aws_subnet" "private-sub-automated" { # This is belongs to Terraform
vpc_id = aws_vpc.automated-vpc.id # it will feach vpc id above code
cidr_block = "10.0.2.0/24"

 tags = {
    Name = "private-sub-automated" # this is belongs to AWS
  }
}

resource "aws_internet_gateway" "automated-igw" { # this is belongs to terraform
  vpc_id = aws_vpc.automated-vpc.id

  tags = {
    Name = "automated-igw" # This is belongs to AWS
  }
}

resource "aws_route_table" "automated_public_crtb" {
    vpc_id = aws_vpc.automated-vpc.id
route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.automated-igw.id
}

tags = {
    Name = "automated_public_crtb"
}
}

resource "aws_route_table" "automated_private_crtb" {
    vpc_id = aws_vpc.automated-vpc.id
route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.automated-ngw.id
}

tags = {
    Name = "aautomated_private_crtb"
}
}

resource "aws_eip" "auto-elastic-ip" {

  tags = {
    Name = "auto-elastic-ip"
  }

}

resource "aws_nat_gateway" "automated-ngw" {
  allocation_id = aws_eip.auto-elastic-ip.id
  subnet_id     = aws_subnet.pub-sub-automated.id

  tags = {
    Name = "automated-ngw"
  }

# To ensure proper ordering, it is recommened to add an explicit dependency
# on the Internet Gateway for tje VPC
depends_on = [aws_internet_gateway.automated-igw]
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.pub-sub-automated.id
  route_table_id = aws_route_table.automated_public_crtb.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private-sub-automated.id
  route_table_id = aws_route_table.automated_private_crtb.id
}