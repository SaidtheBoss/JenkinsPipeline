#------------ SECURITY GROUPS ---------------#
resource "aws_security_group" "tf_sg" {
  name        = "tf-sg"
  vpc_id      = aws_vpc.tf_aws_project_vpc.id
  description = "SSH, HTTP & HTTPS accessible"

  tags = {
    "Name"      = "allow ssh, http & https"
    "ManagedBy" = "terraform"
  }
}
# SG RULES
resource "aws_security_group_rule" "sg_rule_SSH" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tf_sg.id
}
resource "aws_security_group_rule" "sg_rule_HTTP" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tf_sg.id
}
resource "aws_security_group_rule" "sg_rule_HTTPS" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tf_sg.id
}
resource "aws_security_group_rule" "public_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tf_sg.id
}