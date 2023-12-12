resource "local_file" "proxy_env_local" {
  content = templatefile("templates/proxy-env.tftpl", {
    proxy_ip_addrs_public = [aws_instance.proxy.public_ip]
    manager_ip_addrs_public = [aws_instance.cluster_manager.public_ip]
    manager_ip_addrs_private = [aws_instance.cluster_manager.private_ip]
    workers_ip_addrs_public = [for i in aws_instance.cluster_workers:i.public_ip]
    workers_instance_ids = [for i in aws_instance.cluster_workers:i.id]
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
    workers_instance_ids = [for i in aws_instance.cluster_workers:i.id]
    ssh_keyfile = ".ssh/ansible-ssh-key.pem"
  })
  filename = "../../apps/proxy/.env.remote"
}

resource "local_file" "trusted_host_env" {
  content = templatefile("templates/trusted_host-env.tftpl", {
    proxy_ip_addrs_public = [aws_instance.proxy.public_ip]
    proxy_ip_addrs_private = [aws_instance.proxy.private_ip]
  })
  filename = "../../apps/trusted_host/.env"
}

resource "local_file" "gatekeeper_env" {
  content = templatefile("templates/gatekeeper-env.tftpl", {
    trusted_ip_addrs_public = [aws_instance.trusted_host.public_ip]
    trusted_ip_addrs_private = [aws_instance.trusted_host.private_ip]
  })
  filename = "../../apps/gatekeeper/.env"
}

resource "local_file" "client_env" {
  content = templatefile("templates/client-env.tftpl", {
    gatekeeper_addrs_public = [aws_instance.gatekeeper.public_ip]
  })
  filename = "../../apps/client/.env"
}