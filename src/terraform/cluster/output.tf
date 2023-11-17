output "server-data" {
  value = {
    ip_address  = aws_instance.cluster_manager.public_ip
    public_dns = aws_instance.cluster_manager.public_dns
  }
  description = "The public IP and DNS of the servers"
}