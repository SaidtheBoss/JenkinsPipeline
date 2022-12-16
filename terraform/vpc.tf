#--------- VPCs ---------------#
resource "aws_vpc" "tf_aws_project_vpc" {
  cidr_block = var.vpc_cird

  tags = {
    "Name"      = "tf_aws_project_vpc"
  }
}
#-------- SUBNETS -------------------#
resource "aws_subnet" "tf_public" {
  vpc_id            = aws_vpc.tf_aws_project_vpc.id
  cidr_block        = var.sub_cidr_pub
  availability_zone = var.sub_az_1

  tags = {
    "Name"      = "project_public_sub"
  }
}

resource "aws_subnet" "tf_public2" {
  vpc_id            = aws_vpc.tf_aws_project_vpc.id
  cidr_block        = var.sub_cidr_pub2
  availability_zone = var.sub_az_2

  tags = {
    "Name"      = "project_public2_sub"
  }
}

#------------- GATEWAYS -----------------#
resource "aws_internet_gateway" "tf_igw" {
  vpc_id = aws_vpc.tf_aws_project_vpc.id

  tags = {
    "Name"      = "project_igw"
  }
}
#------------ ROUTE TABLES ---------------#
resource "aws_route_table" "route_public" {
  vpc_id = aws_vpc.tf_aws_project_vpc.id

  tags = {
    "Name"      = "project_route_public"
  }
}
resource "aws_route" "igw-route" {
  route_table_id         = aws_route_table.route_public.id
  destination_cidr_block = var.cidr_all_ips
  gateway_id             = aws_internet_gateway.tf_igw.id
}
# RT ASSOCIATIONS
resource "aws_route_table_association" "assign_route_public" {
  route_table_id = aws_route_table.route_public.id
  subnet_id      = aws_subnet.tf_public.id
}
resource "aws_route_table_association" "assign_route_public2" {
  route_table_id = aws_route_table.route_public.id
  subnet_id      = aws_subnet.tf_public2.id
}