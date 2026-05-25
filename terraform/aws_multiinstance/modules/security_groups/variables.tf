#variable "name" {
#  description = "Nombre del security group"
#  type        = string
#}

variable "vpc_id" {
  description = "ID de la VPC donde se desplegará"
  type        = string
}

#variable "vpc_cidr" {
#  description = "Lista de subredes permitidas"
#  type        = string
#}


#variable "server_ports"{
#  description = "puertos para habilitar el servidor stack"
#  type = list(string)
#}

#variable "admin_ip"{
#  description = "Ip de administracion"
#  type        = string
#}