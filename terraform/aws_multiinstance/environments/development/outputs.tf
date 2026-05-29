output "instance_private_ip_workernode" {
  description = "Ip Privada de las instancias Worker"
  value       = aws_instance.app_workernodes.private_ip
}

output "instance_private_ip_server" {
  description = "Ip privada de las instancias del server controlplane"
  value       = aws_instance.control_plane.private_ip
}


output "instance_public_ip_server" {
  description = "Ip Publica de las instancias de server controlplane"
  value       = aws_instance.control_plane.public_ip
}
# output "instance_public_ip_apollo" {
#   description = "Ip Publica de las instancias de Apollo"
#   value       = aws_instance.apollo_app.public_ip
# }

# output "instance_id_stack" {
#   description = "La Id de la instancia ELK"
#   value       = aws_instance.elk.id
# }

# output "instance_id_apollo" {
#   description = "IDs de las instancias de Apollo"
#   value = aws_instance.apollo_app.id   
# }
