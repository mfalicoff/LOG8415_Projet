resource "local_sensitive_file" "private_key" {
  content = tls_private_key.cluster-key.private_key_pem
  filename          = format("%s/%s/%s", abspath(path.root), ".ssh", "ansible-ssh-key.pem")
  file_permission   = "0400"
}

resource "local_file" "ansible_cfg" {
  content = templatefile("templates/ansible.cfg.tftpl", {
    inventory = local_file.ansible_inventory.filename
  })
  filename = format("%s/%s/playbooks/%s", abspath(path.root), "ansible", "ansible.cfg")
}

resource "local_file" "ansible_inventory" {
  content = templatefile("templates/inventory.tftpl", {
    manager_ip_addrs_public = [aws_instance.cluster_manager.public_ip]
    manager_ip_addrs_private = [aws_instance.cluster_manager.private_ip]
    workers_ip_addrs_public = [for i in aws_instance.cluster_workers:i.public_ip]
    workers_ip_addrs_private = [for i in aws_instance.cluster_workers:i.private_ip]
    proxy_ip_addrs_public = [aws_instance.proxy.public_ip]
    proxy_ip_addrs_private = [aws_instance.proxy.private_ip]
    trusted_host_ip_addrs_public = [aws_instance.trusted_host.public_ip]
    trusted_host_ip_addrs_private = [aws_instance.trusted_host.private_ip]
    gatekeeper_ip_addrs_public = [aws_instance.gatekeeper.public_ip]
    gatekeeper_ip_addrs_private = [aws_instance.gatekeeper.private_ip]
    ssh_keyfile = local_sensitive_file.private_key.filename
  })
  filename = format("%s/%s/%s", abspath(path.root), "ansible", "inventory.ini")
}