output "manager-data" {
  value = {
    ip_address  = aws_instance.cluster_manager.public_ip
    public_dns = aws_instance.cluster_manager.public_dns
  }
  description = "The public IP and DNS of the manager"
}

output "worker-data" {
  value = [
    for instance in aws_instance.cluster_workers : {
      ip_address  = instance.public_ip
      public_dns = instance.public_dns
    }
  ]
  description = "The public IP and DNS of the workers"
}

output "proxy-data" {
  value = {
    ip_address  = aws_instance.proxy.public_ip
    public_dns = aws_instance.proxy.public_dns
  }
  description = "The public IP and DNS of the proxy"
}

output "trusted-data" {
  value = {
    ip_address  = aws_instance.trusted_host.public_ip
    public_dns = aws_instance.trusted_host.public_dns
  }
  description = "The public IP and DNS of the trusted"
}

output "gatekeeper-data" {
  value = {
    ip_address  = aws_instance.gatekeeper.public_ip
    public_dns = aws_instance.gatekeeper.public_dns
  }
  description = "The public IP and DNS of the gatekeeper"
}