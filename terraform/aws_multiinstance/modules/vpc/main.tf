#Módulo para la creacion de una VPC con subredes públicas y privadas
# 1. VPC: esta red contendrá nuestras subredes
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = var.name
  }
}

#El segmento de la VPC para las subredes públicas
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets_cidr)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets_cidr[count.index]
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone[count.index]
  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

# Generamos un Gateway para la salida a internet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = { Name = "main-igw" }
}

#Para poder enrutar el tráfico creamos una tabla de rutas
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0" # Indicamos que tipo de tráfico vamos a enviar hacia afuera
    gateway_id = aws_internet_gateway.igw.id 
  }

  tags = { Name = "public-route-table" }
}

# Finalmente asociamos las rutas declaradas para la gateway con la subred pública
resource "aws_route_table_association" "public_assoc" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

####################################################################

# Para las subredes privadas necesitamos un NAT Gateway y una Elastic IP
#resource "aws_eip" "nat_eip" {
#  domain = "vpc"
#  tags   = { Name = "nat-gateway-eip" }
#}


# Generamos un NAT Gateway para que las instancias en la subred privada puedan salir a internet
#resource "aws_nat_gateway" "nat" {
#  allocation_id = aws_eip.nat_eip.id
#  subnet_id     = aws_subnet.public[0].id # Se apoya en la pública para salir
#  tags          = { Name = "main-nat-gateway" }

  # Para asegurar orden, se crea después del IGW público
#  depends_on = [aws_internet_gateway.igw]
#}

# Generamos una subred privada y demas recursos que se requieran
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  count                   = length(var.private_subnets_cidr)
  cidr_block              = var.private_subnets_cidr[count.index]
  availability_zone       = var.availability_zone[count.index]
  map_public_ip_on_launch = false # Sin IP pública
  tags = {
    Name = "private-subnet-1"
  } 
}


# Actualizamos la Tabla de Rutas para la subred privada
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  #route {
  #  cidr_block     = "0.0.0.0/0"
  #  nat_gateway_id = aws_nat_gateway.nat.id # enviamos el tráfico al NAT Gateway
  #}

  tags = { Name = "private-route-table" }
}

# Asociamos la subred privada con la regla de trafico
resource "aws_route_table_association" "private_assoc" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt.id

}

