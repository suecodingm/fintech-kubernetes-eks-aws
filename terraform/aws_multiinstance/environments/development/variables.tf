variable "region" {
  type        = list(string)
  default = ["us-east-1"]
}

variable "server_k3s" {
  type        = string
  default = "ami-0c101f26f147fa7fd"
}

variable "worker_nodes" {
  type        = string
  default= "ami-0c101f26f147fa7fd"
}

variable "cidr_block" {
  description = "El bloque CIDR para la VPC."
  type        = list(string)
  default = [ "10.0.0.0/16" ]
}