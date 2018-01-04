variable "greeter_version"
variable "greeter_repo_id"
variable "greeter_repo_url"

variable "aws_region" {}
variable "aws_ami" {}

variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "aws_private_key" {}
variable "aws_public_key" {}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

resource "aws_security_group" "greeter" {
  name = "greeter-security"
  description = "Allow SSH"

  # TCP access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "jenkins" {
  key_name      = "jenkins"
  public_key    = "${var.aws_public_key}"
}

resource "aws_instance" "greeter" {
  connection {
    type           = "ssh"
    user           = "ubuntu"
    private_key    = "${file("${var.aws_private_key}")}"
    agent          = false
    timeout        = "2m"
  }

  ami                       = "${var.aws_ami}"
  instance_type             = "t2.micro"
  key_name                  = "jenkins"
  vpc_security_group_ids    = [ "${aws_security_group.greeter.id}" ]

  provisioner "remote-exec" {
    inline = [
      "mvn dependency:get -DremoteRepositories=${var.greeter_repo_id}::::${var.greeter_repo_url} -DgroupId=com.mossneto -DartifactId=greeter -Dversion=${var.greeter_version} -Dtransitive=false -Ddest=.",
      "java -jar com.mossneto.greeter-${var.greeter_version}.jar"
    ]
  }
}

resource "aws_eip" "ip" {
  instance = "${aws_instance.greeter.id}"
}
