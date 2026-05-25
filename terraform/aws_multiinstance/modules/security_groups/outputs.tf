output "worker_nodes_sg_id" {
   value = aws_security_group.worker_nodes.id
   }


output "k3s_server_sg_id" {
   value = aws_security_group.server_k3s.id
}


#output "load_balancer_sg_id" {
 #  value = aws_security_group.alb_sg.id 
#}
