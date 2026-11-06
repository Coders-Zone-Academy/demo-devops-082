resource "azurerm_resource_group" "first" {
    name = "first-rg"
    location = var.location

    tags = {
    Environment = "develop"
    Service = "2p"
  }

}

resource "azurerm_virtual_network" "first" {
  name                = "vnet-network"
  location            = azurerm_resource_group.first.location
  resource_group_name = azurerm_resource_group.first.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    Environment = "develop"
    Service = "2p"
  }
}

resource "azurerm_subnet" "first" {
  name                 = "snet-first"
  resource_group_name  = azurerm_resource_group.first.name
  virtual_network_name = azurerm_virtual_network.first.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_security_group" "first" {
  name                = "nsg-first"
  location            = azurerm_resource_group.first.location
  resource_group_name = azurerm_resource_group.first.name

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = chomp(data.http.my_ip.body)
    destination_address_prefix = "*"
  }

  tags = {
    Environment = "develop"
    Service = "2p"
  }
}

resource "azurerm_subnet_network_security_group_association" "first" {
  subnet_id                 = azurerm_subnet.first.id
  network_security_group_id = azurerm_network_security_group.first.id
}

data "http" "my_ip" {
    url = "https://ifconfig.me/ip"
}

resource "azurerm_public_ip" "first" {
  name                = "pip-first"
  resource_group_name = azurerm_resource_group.first.name
  location            = azurerm_resource_group.first.location
  allocation_method   = "Static"

  tags = {
    Environment = "develop"
    Service = "2p"
  }
}

resource "azurerm_network_interface" "first" {
  name                = "first-nic"
  location            = azurerm_resource_group.first.location
  resource_group_name = azurerm_resource_group.first.name

  ip_configuration {
    name                          = "public"
    subnet_id                     = azurerm_subnet.first.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.first.id
  }

  tags = {
    Environment = "develop"
    Service = "2p"
  }
}

resource "tls_private_key" "first" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
    content = tls_private_key.first.private_key_pem
    filename = pathexpand("~/.ssh/vm1")
    file_permission = "0600"
}

resource "local_file" "public_key" {
  content = tls_private_key.first.public_key_openssh
  filename = pathexpand("~/.ssh/vm1.pub")
}

resource "azurerm_linux_virtual_machine" "first" {
  name                = "first-vm"
  resource_group_name = azurerm_resource_group.first.name
  location            = azurerm_resource_group.first.location
  size                = "Standard_D2als_v6"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.first.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.first.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  tags = {
    Environment = "develop"
    Service = "2p"
  }
}

