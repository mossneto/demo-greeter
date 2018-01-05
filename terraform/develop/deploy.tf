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

resource "aws_elb" "greeter-lb" {
    name            = "greeter-lb"
    security_groups = [ "${aws_security_group.greeter.id}" ]
    availability_zones = [ "us-east-1a", "us-east-1b" ]

    listener {
        instance_port = 8080
        instance_protocol = "http"
        lb_port = 80
        lb_protocol = "http"
    }

    health_check {
        healthy_threshold = 2
        unhealthy_threshold = 2
        timeout = 3
        target = "HTTP:80/"
        interval = 30
    }
}

resource "aws_key_pair" "greeter" {
  key_name      = "${var.aws_key_pair_name}"
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
  instance_type             = "${var.aws_instance_type}"
  key_name                  = "${var.aws_key_pair_name}"
  vpc_security_group_ids    = [ "${aws_security_group.greeter.id}" ]

  provisioner "remote-exec" {
    inline = [
      "mvn dependency:get -DremoteRepositories=${var.greeter_repo_id}::::${var.greeter_repo_url} -DgroupId=com.mossneto -DartifactId=greeter -Dversion=${var.greeter_version} -Dtransitive=false -Ddest=.",
      "java -jar com.mossneto.greeter-${var.greeter_version}.jar"
    ]
  }
}
