output "public_key" {
  value = tls_private_key.first.public_key_openssh
}

output "public_ip_address" {
    value = azurerm_public_ip.first.ip_address
}
