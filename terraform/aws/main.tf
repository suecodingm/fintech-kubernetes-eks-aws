resource "aws_security_group" "k3s_sg" {
  name        = "k3s-security-group"
  description = "Allow SSH and Kubernetes traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubernetes API"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "NodePort Services"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "k3s_server" {
  ami           = "ami-0c101f26f147fa7fd"
  instance_type = "t3.medium"
  key_name = "tfm-k3s-key"
  vpc_security_group_ids = [aws_security_group.k3s_sg.id]

 user_data = <<-EOF
	#!/bin/bash
	exec > /var/log/user-data.log 2>&1

	echo "=== START USER DATA ==="

	# esperar red
	sleep 30

	# instalar curl por si acaso
	yum install -y curl

	# metadata
	TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
	-H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

	PUBLIC_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
	-s http://169.254.169.254/latest/meta-data/public-ipv4)

	echo "PUBLIC IP: $PUBLIC_IP"

	# instalar k3s
	curl -sfL https://get.k3s.io | sh -s - server --tls-san $PUBLIC_IP

	echo "=== K3S INSTALLED ==="

	sleep 20

	systemctl status k3s

	kubectl get nodes || true

	echo "=== END USER DATA ==="
EOF  
  tags = {
    Name = "k3s-server"
  }
}

output "instance_ip" {
  value = aws_instance.k3s_server.public_ip
}

