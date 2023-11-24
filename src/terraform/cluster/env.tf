resource "local_file" "proxy_env_local" {
  content = templatefile("templates/proxy-env.tftpl", {
    proxy_ip_addrs_public = [aws_instance.proxy.public_ip]
    manager_ip_addrs_public = [aws_instance.cluster_manager.public_ip]
    manager_ip_addrs_private = [aws_instance.cluster_manager.private_ip]
    workers_ip_addrs_public = [for i in aws_instance.cluster_workers:i.public_ip]
    ssh_keyfile = local_sensitive_file.private_key.filename
  })
  filename = "../../apps/proxy/.env.local"
}

resource "local_file" "proxy_env_remote" {
  content = templatefile("templates/proxy-env.tftpl", {
    proxy_ip_addrs_public = [aws_instance.proxy.public_ip]
    manager_ip_addrs_public = [aws_instance.cluster_manager.public_ip]
    manager_ip_addrs_private = [aws_instance.cluster_manager.private_ip]
    workers_ip_addrs_public = [for i in aws_instance.cluster_workers:i.public_ip]
    ssh_keyfile = ".ssh/ansible-ssh-key.pem"
  })
  filename = "../../apps/proxy/.env.remote"
}