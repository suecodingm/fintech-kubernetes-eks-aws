# Configuración del Proveedor
provider "aws" {
  region = var.region[0]
}

#Creacion de VPC, llamamos a nuestro modulo VPC
module "app_vpc" {
  availability_zone = ["us-east-1a", "us-east-1b"]
  source     = "../../modules/vpc"
  name       = "app-vpc"
  cidr_block = var.cidr_block[0]
  public_subnets_cidr = ["10.0.1.0/24","10.0.2.0/24"]
  private_subnets_cidr = ["10.0.3.0/24"]

}

# Grupo de Seguridad para nuestro escenario
# usando nuestro módulo de Security Groups

module "security_groups" {
  source = "../../modules/security_groups"
  vpc_id = module.app_vpc.vpc_id
}


resource "aws_instance" "control_plane" {
  ami           = var.server_k3s 
  instance_type = "t3.medium"
  key_name = "tfm-k3s-key"
  vpc_security_group_ids = [module.security_groups.k3s_server_sg_id]
  subnet_id     = module.app_vpc.public_subnet_ids[1]
 root_block_device {
    volume_size = 20 # Cambiamos de 8 a 20GB mínimo
    volume_type = "gp3"
  }
  user_data = <<-EOF
        #!/bin/bash
        exec > /var/log/user-data.log 2>&1

        sleep 30

        dnf install -y curl
        TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
        -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

        PUBLIC_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
        -s http://169.254.169.254/latest/meta-data/public-ipv4)
        curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --token tfm-cluster-token --tls-san $PUBLIC_IP" sh - 
      EOF  
  tags = {
    Name = "control_plane"
  }
}




resource "aws_instance" "app_workernodes" {
  ami           = var.worker_nodes 
  instance_type = "t3.small"
  key_name = "tfm-k3s-key"
  vpc_security_group_ids = [module.security_groups.worker_nodes_sg_id]
  subnet_id     = module.app_vpc.public_subnet_ids[0]
  associate_public_ip_address = true
  root_block_device {
    volume_size = 20 # Cambiamos de 8 a 20GB mínimo
    volume_type = "gp3"
  }
  user_data = <<-EOF
    #!bin/bash
    exec > /var/log/user-data.log 2>&1

    sleep 30

    dnf update -y
    dnf install -y curl

    echo "Installing k3s agent..."

    export K3S_URL="https://${aws_instance.control_plane.private_ip}:6443"
    export K3S_TOKEN="tfm-cluster-token"

    curl -sfL https://get.k3s.io | sh -

    echo "k3s agent installed"

    systemctl enable k3s-agent
    systemctl start k3s-agent
    systemctl is-active k3s-agent
      EOF  
    tags = {
      Name = "worker_nodes"
    }


  depends_on = [aws_instance.control_plane]
  
}

