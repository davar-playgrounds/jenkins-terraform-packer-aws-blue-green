provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "tag:Name"
    values = ["${var.app_name}"]
  }

  filter {
    name   = "tag:Version"
    values = ["${var.version}"]
  }

  owners = ["self"]
}

## Creating Launch Configuration
resource "aws_launch_configuration" "lc-app" {
  name                 = "lc-app_${data.aws_ami.app_ami.id}"
  image_id             = "${data.aws_ami.app_ami.id}"
  instance_type        = "t2.micro"
  security_groups      = ["sg-c29d7c8f"]
  key_name             = "opswerk"
  iam_instance_profile = "TestRole"
  associate_public_ip_address = "true"

  user_data = <<-EOF
              #!/bin/bash
              yum install -y epel-release
              rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
              yum install -y nginx php70w-fpm
              echo "<?php phpinfo(); ?>" > /usr/share/nginx/html/index.php
              for i in php-fpm nginx; do service $i start; done
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

## Creating AutoScaling Group
resource "aws_autoscaling_group" "asg-app" {
  name_prefix           = "asg-${aws_launch_configuration.lc-app.id}"
  launch_configuration  = "${aws_launch_configuration.lc-app.id}"
  availability_zones    = ["us-east-1a", "us-east-1b"]
  vpc_zone_identifier   = ["subnet-cf6864ab", "subnet-e770d5c9"]
  min_size              = 2
  max_size              = 10
  wait_for_elb_capacity = 2
  desired_capacity      = 2
  load_balancers        = ["${aws_elb.elb-app.name}"]
  health_check_type     = "ELB"
  termination_policies  = ["OldestInstance"]

  tag {
    key                 = "Name"
    value               = "demo-app"
    propagate_at_launch = true
  }

  tag {
    key                 = "platform"
    value               = "demo"
    propagate_at_launch = true
  }

  tag {
    key                 = "product"
    value               = "app"
    propagate_at_launch = true
  }

  tag {
    key                 = "application"
    value               = "demo-app"
    propagate_at_launch = true
  }

  tag {
    key                 = "environment"
    value               = "dev"
    propagate_at_launch = true
  }

  tag {
    key                 = "owner"
    value               = "Jeff Miller"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

### Creating ELB
resource "aws_elb" "elb-app" {
  name            = "elb-demo-app-${var.ami_name}"
  security_groups = ["sg-c29d7c8f"]

  #  availability_zones = ["us-east-1a", "us-east-1b"]
  subnets = ["subnet-cf6864ab", "subnet-e770d5c9"]

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:80/"
  }

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "80"
    instance_protocol = "http"
  }

  listener {
    instance_port      = 80
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:us-east-1:816913093305:certificate/80676f27-5b6f-4a32-b518-082482e8dacf"
}

  tags {
    Name        = "app-elb"
    platform    = "demo"
    product     = "app"
    application = "demo-app"
    environment = "dev"
    owner       = "Jeff Miller"
  }
}

### Creating Route 53 DNS Update
data "aws_route53_zone" "r53-demo-app" {
  name = "opswerk.com."
}

resource "aws_route53_record" "r53-demo-app" {
  zone_id = "${data.aws_route53_zone.r53-demo-app.zone_id}"
  name    = "app.opswerk.com"
  type    = "A"

  alias {
    name                   = "dualstack.${aws_elb.elb-app.dns_name}"
    zone_id                = "${aws_elb.elb-app.zone_id}"
    evaluate_target_health = false
  }
}
