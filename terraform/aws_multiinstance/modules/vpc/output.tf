output "vpc_id" {
  description = "El ID de la VPC creada."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" { 
  description = "Id de la subred pública"
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Id de la subred privada"
  value = aws_subnet.private[*].id
}

# output "nat_gateway"{
#   description="Nat Gateway de la subred privada"
#   value= aws_eip.nat_eip.public_ip
# }