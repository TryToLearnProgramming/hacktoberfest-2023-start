provider "aws"{
	region = "us-east-2"
}

resource "aws_vpc" "vcbtfp1"{
	cidr_block  = "192.168.6.0/25"
	tags = {
		Name = "vpc_created_by_terr_p1"
		}
}
resource "aws_internet_gateway" "igwcbtfp1"{
	vpc_id = aws_vpc.vcbtfp1.id
	tags = {
		Name = "internetgateway_created_by_terr_p1"
		}
}
resource "aws_main_route_table_association" "vrta1cbtfps1"{
	vpc_id = aws_vpc.vcbtfp1.id
	route_table_id = aws_route_table.rtcbtfpsp1.id
}
resource "aws_route_table" "rtcbtfpsp1"{
	vpc_id = aws_vpc.vcbtfp1.id
//	route{
//		cidr_block = aws_subnet.pscbtfp1.cidr_block
//		gateway_id = "local"
//	}
	route{
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.igwcbtfp1.id
		}
	tags = {
		Name = "public_route_table_created_by_terr_p1"
		}
}
resource "aws_route_table_association" "purta1cbtfp1"{
	subnet_id = aws_subnet.pscbtfp1.id
	route_table_id = aws_route_table.rtcbtfpsp1.id
}
resource "aws_route_table" "rtcbtfprsp1"{
	vpc_id = aws_vpc.vcbtfp1.id
	tags = {
		Name = "private_route_table_created by terr_p1"
		}
}
resource "aws_route_table_association" "prrta1cbtfp1"{
	subnet_id = aws_subnet.prscbtfp1.id
	route_table_id  = aws_route_table.rtcbtfprsp1.id
}
resource "aws_subnet" "prscbtfp1"{
	vpc_id = aws_vpc.vcbtfp1.id
	cidr_block = "192.168.6.64/26"
	tags = {
		Name = "private_subnet_created_bt_terr_p1"
		}
}
resource "aws_subnet" "pscbtfp1"{
	vpc_id = aws_vpc.vcbtfp1.id
	cidr_block = "192.168.6.0/26"
	map_public_ip_on_launch = true
	tags = {
		Name = "public_subnet_created_by_terr_p1"
	}
}
resource "aws_security_group" "sgcbtfp1"{
	name = "Security_group_created_by_terr_p1_for_ec2"
	description = "Security_group_created_by_terr_p1_for_ec2_${timestamp()}"
	vpc_id = aws_vpc.vcbtfp1.id
	ingress{
		from_port = 443
		to_port = 443
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
		}
	ingress{
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks= ["49.249.103.254/32"]
		}
	ingress{
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks= ["0.0.0.0/0"]
		}
	egress{
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
		}
	tags = {
		Name = "Security_group_created_by_terr_p1_for_ec2"
		}
}
resource "aws_instance" "ec2cbtfp1"{
	ami = "ami-08fdd91d87f63bb09"
	instance_type = "t4g.small"
//	vpc_id = aws_vpc.vcbtfp1.id
	subnet_id = aws_subnet.pscbtfp1.id
	vpc_security_group_ids = [aws_security_group.sgcbtfp1.id]
	key_name = "terra"
	user_data = <<-EOF
				#!/bin/bash
				sudo apt update -y
				sudo apt-get install ca-certificates curl gnupg -y
				sudo install -m 0755 -d /etc/apt/keyrings
				curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
				sudo chmod a+r /etc/apt/keyrings/docker.gpg
				echo \
				  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
				  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
				  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
				sudo apt-get update -y
				sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
				mkdir /home/ubuntu/html
				cd /home/ubuntu/html
				wget "https://www.free-css.com/assets/files/free-css-templates/download/page296/browny.zip"
				sudo apt install unzip -y
				unzip browny
				sudo docker run --name ngginx -d -p 80:80 -v /home/ubuntu/html/browny-v1.0:/usr/share/nginx/html nginx nginx -g 'daemon off;'
				EOF
	user_data_replace_on_change = true
	tags = {
		Name = "ec2_instance_created_by_terr_p1"
		}
}
resource "aws_eip" "eipcbtfp1"{
	instance = aws_instance.ec2cbtfp1.id
	domain = "vpc"
	tags = {
		Name = "eip_created_by_terr_pt"
		}
}
output "EIP--" {
	value = aws_eip.eipcbtfp1.public_ip
}
//redource "aws"
//resource "<provider>_<resource_type>" "name"
//{//
//	config options......
//	key = "value"
//	key2  = "another value"
//}

//resource "aws_instance" "ec2-{
//	ami = "ami-0a0c8eebcdd6dcbd0"
//	instance_type = "t4g.small"
//	tags = {
//		Name = "ec2-1"
//		}
//}
//resource "aws_vpc" "vcbt"{
//	cidr_block  = "172.25.20.0/25"
//	tags = {
//		Name = "vpc_created_by_terra"
//	}
//}
//resource "aws_subnet" "scbt"{
//	vpc_id = aws_vpc.vcbt.id
//	cidr_block = "172.25.20.0/26"
//	tags = {
//		Name = "sub_created ny terra"
//		}
//}
		
//resource "aws_instance" "ec2-//1"{
//	ami = "ami-053b0d53c279acc90"
//	instance_type = "t2.micro"
//	tags = {
//		Name = "ec2-1"
//		}
//}
