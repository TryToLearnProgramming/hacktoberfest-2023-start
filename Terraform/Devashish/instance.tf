resource "aws_instance" "ec2-instance" {
  ami = "${lookup(var.AMIS, var.AWS_REGION)}"
  instance_type = "t3a.micro"
}