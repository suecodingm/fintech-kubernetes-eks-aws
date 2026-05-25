variable "cidr_block" {
  description = "El bloque CIDR para la VPC."
  type        = string
}

variable "name" {
  description = "El nombre de la VPC."
  type        = string
}

variable "public_subnets_cidr" {
  description = "Lista de bloques CIDR para las subredes públicas."
  type        = list(string)
}

variable "private_subnets_cidr" {
  description = "Lista de bloques CIDR para las subredes privadas."
  type        = list(string)
}
variable "availability_zone" {
    description = "zonas para despliegue de VPC"
    type        = list(string)
  
}