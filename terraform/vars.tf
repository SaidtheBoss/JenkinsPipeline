variable "default_region" {
  type    = string
  default = "us-east-1"
}
##---- vpc vars -----
variable "vpc_cird" {
  type    = string
  default = "124.10.0.0/16"
}

variable "sub_cidr_pub" {
  type    = string
  default = "124.10.1.0/24"
}
variable "sub_cidr_pub2" {
  type    = string
  default = "124.10.2.0/24"
}


variable "cidr_all_ips" {
  type    = string
  default = "0.0.0.0/0"
}
variable "sub_az_1" {
  type    = string
  default = "us-east-1b"
}
variable "sub_az_2" {
  type    = string
  default = "us-east-1a"
}
#---------ec2
variable "instance-type" {
  type    = string
  default = "t2.micro"
}
variable "ssh-key" {
  default     = "key-for-server"
  description = "key for ssh into ec2 instance"
}