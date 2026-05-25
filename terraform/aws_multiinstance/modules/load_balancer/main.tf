
# El Balanceador de Carga
resource "aws_lb" "load_balancer" {
  name               = var.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.alb_sg_id
  subnets            = var.public_subnets #ids de subredes públicas
  tags = { Name = "App-ALB" }
}

# Grupo Objetivo (Target Group)
resource "aws_lb_target_group" "lb_group" {
  name     = "${var.name}-tg"
  port     = var.port
  protocol = var.protocol
  vpc_id   = var.vpc_id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

# El listener maneja las peticiones de tráfico hacia el balanceador
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = var.port
  protocol          = var.protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_group.arn
  }
}

# Asociamos las instanacias al target group
resource "aws_lb_target_group_attachment" "node_attachment" {
    count            = length(var.node_instance_id)
  target_group_arn = aws_lb_target_group.lb_group.arn
  #count = leng
  target_id        = var.node_instance_id[count.index]
  port             = 80
}