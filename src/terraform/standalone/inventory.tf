resource "local_sensitive_file" "private_key" {
  content = tls_private_key.standalone-key.private_key_pem
  filename          = format("%s/%s/%s", abspath(path.root), ".ssh", "ansible-ssh-key.pem")
  file_permission   = "0600"
}

resource "local_file" "ansible_inventory" {
  content = templatefile("templates/inventory.tftpl", {
    ip_addrs = [aws_instance.standalone.public_ip]
    ssh_keyfile = local_sensitive_file.private_key.filename
  })
  filename = format("%s/%s/%s", abspath(path.root), "ansible", "inventory.ini")
}