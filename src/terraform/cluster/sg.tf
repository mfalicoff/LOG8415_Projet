resource "aws_security_group" "proxy" {
  name        = "proxy"
  description = "Allow inbound HTTP traffic from the broad internet"
  vpc_id      = data.aws_vpc.default.id

}

# Allow HTTP traffic from the broad internet to reach the ALB
resource "aws_security_group_rule" "proxy_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.proxy.id
}

# Allow HTTP traffic from the load balancer to EC2 instances
resource "aws_security_group_rule" "proxy_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id        = aws_security_group.proxy.id
}

 resource "aws_security_group_rule" "proxy_ssh" {
   type              = "ingress"
   from_port         = 22
   to_port           = 22
   protocol          = "tcp"
   cidr_blocks       = ["0.0.0.0/0"]
   security_group_id = aws_security_group.proxy.id
 }

resource "aws_security_group" "cluster" {
  name        = "cluster"
  description = "Allow inbound HTTP traffic from the broad internet"
  vpc_id      = data.aws_vpc.default.id
}

# Allow HTTP traffic from the broad internet to reach the ALB
resource "aws_security_group_rule" "cluster_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks      = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cluster.id
}

# Allow MySQL traffic from the broad internet to reach the ALB
#resource "aws_security_group_rule" "cluster_ingress_mysql" {
#  type                   = "ingress"
#  from_port              = 3306
#  to_port                = 3306
#  protocol               = "tcp"
#  source_security_group_id = aws_security_group.proxy.id
#  security_group_id      = aws_security_group.cluster.id
#}
#
#resource "aws_security_group_rule" "cluster_ingress_mysql-cluster" {
#  type                      = "ingress"
#  from_port                 = 1186
#  to_port                   = 1186
#  protocol                  = "tcp"
#  source_security_group_id  = aws_security_group.proxy.id
#  security_group_id         = aws_security_group.cluster.id
#}

# Allow all egress traffic
resource "aws_security_group_rule" "cluster_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.cluster.id
}

# Uncomment to allow SSH traffic to the orchestrator instance
 resource "aws_security_group_rule" "cluster_ssh" {
   type              = "ingress"
   from_port         = 22
   to_port           = 22
   protocol          = "tcp"
   cidr_blocks       = ["0.0.0.0/0"]
   security_group_id = aws_security_group.cluster.id
 }

