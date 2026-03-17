# ------------------------------------------------------------------
# Data source: available AZs
# Instead of hardcoding "us-east-1a", "us-east-1b", we ask AWS
# which AZs are available. This means the code works in any region.
# ------------------------------------------------------------------
data "aws_availability_zones" "available" {
  state = "available"
}

# ------------------------------------------------------------------
# VPC
# /16 gives us 65,536 IP addresses. More than we need for learning,
# but in production you want room to grow. The CIDR must not overlap
# with any VPC you might peer with later.
# ------------------------------------------------------------------
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name}-vpc"
  }
}

# ------------------------------------------------------------------
# Internet Gateway
# Attaches to the VPC. Without this, nothing in the VPC can reach
# the internet. One IGW per VPC. It is free (no hourly charge).
# ------------------------------------------------------------------
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-igw"
  }
}

# ------------------------------------------------------------------
# Public Subnets
# count = length(var.public_subnet_cidrs) creates one subnet per
# CIDR in the list. With the default of 2 CIDRs, this creates 2
# subnets, each in a different AZ for high availability.
#
# map_public_ip_on_launch = true: any EC2 instance launched here
# automatically gets a public IP. This is what makes it "public."
# ------------------------------------------------------------------
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-public-${count.index + 1}"
  }
}

# ------------------------------------------------------------------
# Private Subnets
# Same pattern as public, but no public IP assignment. Resources
# here are not directly reachable from the Internet.
#
# We are NOT creating a NAT Gateway. NAT Gateways cost ~$32/month
# even when idle. For this project, private subnets simply have no
# outbound internet. In production, you would add a NAT Gateway if
# private instances need to download packages or reach APIs.
# ------------------------------------------------------------------
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.name}-private-${count.index + 1}"
  }
}

# ------------------------------------------------------------------
# Public Route Table
# A route table is a set of rules that determine where traffic goes.
# This one sends all internet-bound traffic (0.0.0.0/0) to the IGW.
# Without this route, even public subnets cannot reach the internet.
# ------------------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.name}-public-rt"
  }
}

# ------------------------------------------------------------------
# Route Table Associations
# Each subnet uses the VPC's "main" route table by default, which
# has no internet route. We must explicitly associate public subnets
# with our public route table so they can reach the internet.
# ------------------------------------------------------------------
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
