resource "aws_security_group" "gatekeeper" {
  name        = "gatekeeper"
  description = "Allow inbound HTTP traffic from the broad internet"
  vpc_id      = data.aws_vpc.cluster-default.id
}

# Allow HTTP traffic from the broad internet to reach the gatekeeper
resource "aws_security_group_rule" "gatekeeper_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.gatekeeper.id
}

# Allow HTTP traffic to exit the gatekeeper
resource "aws_security_group_rule" "gatekeeper_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.gatekeeper.id
}

# Allow SSH traffic to the gatekeeper
 resource "aws_security_group_rule" "gatekeeper_ssh" {
   type              = "ingress"
   from_port         = 22
   to_port           = 22
   protocol          = "tcp"
   cidr_blocks       = ["0.0.0.0/0"]
   security_group_id = aws_security_group.gatekeeper.id
 }

resource "aws_security_group" "trusted_host" {
  name        = "trusted_host"
  description = "Allow inbound HTTP traffic from the broad internet"
  vpc_id      = data.aws_vpc.cluster-default.id
}

# Allow HTTP traffic from the gatekeeper to the trusted host
resource "aws_security_group_rule" "trusted_host_ingress" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.trusted_host.id
  source_security_group_id = aws_security_group.gatekeeper.id
}

# Allow HTTP traffic to exit the trusted host
resource "aws_security_group_rule" "trusted_host_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.trusted_host.id
}

# Allow SSH traffic to the trusted host
 resource "aws_security_group_rule" "trusted_host_ssh" {
   type              = "ingress"
   from_port         = 22
   to_port           = 22
   protocol          = "tcp"
   cidr_blocks       = ["0.0.0.0/0"]
   security_group_id = aws_security_group.trusted_host.id
 }

resource "aws_security_group" "proxy" {
  name        = "proxy"
  description = "Allow inbound HTTP traffic from the broad internet"
  vpc_id      = data.aws_vpc.cluster-default.id
}

# Allow HTTP traffic from the trusted host to the proxy
resource "aws_security_group_rule" "proxy_ingress" {
  type                      = "ingress"
  from_port                 = 0
  to_port                   = 0
  protocol                  = "-1"
  security_group_id         = aws_security_group.proxy.id
  source_security_group_id  = aws_security_group.trusted_host.id
}

# Allow HTTP traffic to exit the proxy
resource "aws_security_group_rule" "proxy_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.proxy.id
}

# Allow SSH traffic to the proxy
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
  vpc_id      = data.aws_vpc.cluster-default.id
}

# Allow HTTP traffic from the Proxy to the cluster
resource "aws_security_group_rule" "cluster_ingress" {
  type                      = "ingress"
  from_port                 = 0
  to_port                   = 0
  protocol                  = "-1"
  security_group_id         = aws_security_group.cluster.id
  source_security_group_id  = aws_security_group.proxy.id
}

# Allow HTTP traffic from the cluster to the cluster
resource "aws_security_group_rule" "cluster_ingress_internal" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.cluster.id
  security_group_id        = aws_security_group.cluster.id
}

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

