variable "name" {
  description = "Nombre del balanceador"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC donde se desplegará"
  type        = string
}

variable "public_subnets" {
  description = "Lista de subredes públicas para el ALB"
  type        = list(string)
}

variable "alb_sg_id" {
  description = "Lista de subredes públicas para el ALB"
  type        = list(string)
}

variable "protocol" {
  description = "Protocolo del balanceador"
  type        = string
  default     = "HTTP"
}


variable "port" {
  description = "Puerto en el que escuchará el ALB"
  type        = number
  default     = 80
}

variable "node_instance_id" {
  description = "ID de la instancia de Node.js"
  type        = list(string)

}
