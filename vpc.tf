# Create VPC

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16" 

  tags = {
    Name = "Terraform-VPC"
  }
}

# Create public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24" 
  availability_zone       = "ap-south-1a"   

  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet"
  }
}

# Create private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24" 
  availability_zone       = "ap-south-1b"   

  tags = {
    Name = "PrivateSubnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "terraform-IGW"
  }
}

# Create Route Table for public subnet

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
   Name = "PublicRouteTable"
  }
}

# Associate public route table with the public subnet

resource "aws_route_table_association" "publicrouteassociation" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Creating elastic IP
resource "aws_eip" "elasticip" {
  domain   = "vpc"
}


# NAT Gateway for private subnet
resource "aws_nat_gateway" "natgateway" {
 allocation_id = aws_eip.elasticip.id
 subnet_id  = aws_subnet.public_subnet.id
 

 tags = {
   Name = "Terraform-Natgateway"
 }
}

# Create Route Table for private subnet
resource "aws_route_table" "private_route_table" {
   vpc_id = aws_vpc.my_vpc.id
   
   route {
     cidr_block = "0.0.0.0/0"
     nat_gateway_id = aws_nat_gateway.natgateway.id
   }  
  
   tags = {
    Name = "PrivateRouteTable"
  }
}

# Associate private route table with the private subnet

resource "aws_route_table_association" "privaterouteassociation" {
  subnet_id = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}
