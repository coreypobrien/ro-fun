terraform {
  backend "local" {
    path = "/output/rodemo.tfstate"
  }
}

data "aws_ami" "coreos_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["CoreOS-stable-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "owner-id"
    values = ["595879546273"]
  }
}

resource "aws_vpc" "main" {
  cidr_block = "172.16.0.0/16"
  tags {
    Name = "rodemo"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "172.16.10.0/24"
  availability_zone = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags {
    Name = "rodemo"
  }
}

resource "aws_network_interface" "node" {
  subnet_id = "${aws_subnet.main.id}"
  private_ips = ["172.16.10.100"]
  security_groups = ["${aws_security_group.default.id}"]
  tags {
    Name = "rodemo"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "rodemo"
  }
}

resource "aws_route_table" "default" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    "Name" = "rodemo"
  }
}

resource "aws_route" "gw_route" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = "${aws_route_table.default.id}"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}

resource "aws_main_route_table_association" "main_routes" {
  vpc_id         = "${aws_vpc.main.id}"
  route_table_id = "${aws_route_table.default.id}"
}

resource "aws_security_group" "default" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    "Name" = "rodemo"
  }
}

resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  security_group_id = "${aws_security_group.default.id}"

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ingress_icmp" {
  type              = "ingress"
  security_group_id = "${aws_security_group.default.id}"

  protocol    = "icmp"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 0
  to_port     = 0
}

resource "aws_security_group_rule" "ingress_ssh" {
  type              = "ingress"
  security_group_id = "${aws_security_group.default.id}"

  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 22
  to_port     = 22
}

resource "aws_security_group_rule" "master_ingress_http" {
  type              = "ingress"
  security_group_id = "${aws_security_group.default.id}"

  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 80
  to_port     = 80
}

resource "aws_instance" "rodemo" {
  ami                         = "${data.aws_ami.coreos_ami.id}"
  instance_type               = "t2.micro"
  user_data                   = "${data.ignition_config.node_ignition.rendered}"
  key_name                    = "${var.ssh_key_name}"

  network_interface {
     network_interface_id = "${aws_network_interface.node.id}"
     device_index = 0
  }

  tags {
    Name = "rodemo"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = ["image_id"]
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.rodemo.public_ip} >> /output/public_ip.txt"
  }
}
