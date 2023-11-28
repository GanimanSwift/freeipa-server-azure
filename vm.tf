#
# Virtual Machine
#

resource "azurerm_public_ip" "freeipa_pip" {
  name                = "pip-freeipa-${var.environment}-${var.location}-01"
  resource_group_name = azurerm_resource_group.freeipa_rg.name
  location            = azurerm_resource_group.freeipa_rg.location
  allocation_method   = "Static"

  tags = {
    Environment = var.environment
    Location = var.location
  }
}

resource "azurerm_network_interface" "freeipa_nic" {
  name                = "nic-freeipa-${var.environment}-${var.location}-01"
  location            = azurerm_resource_group.freeipa_rg.location
  resource_group_name = azurerm_resource_group.freeipa_rg.name

  ip_configuration {
    name                          = "ip-freeipa-${var.environment}-${var.location}-01"
    subnet_id                     = azurerm_subnet.freeipa_subnet.id
    public_ip_address_id          = azurerm_public_ip.freeipa_pip.id
    private_ip_address_allocation = "Static"
    private_ip_address            = phpipam_first_free_address.freeipa_ip.ip_address
  }

  tags = {
    Environment = var.environment
    Location  = var.location
  }

  depends_on = [
    azurerm_public_ip.freeipa_pip
  ]
}

data "template_file" "cloud_init" {
  template = file("cloud-init.txt")
  vars = {
    dbpassword = random_password.dbpassword.result
  }
}

data "template_cloudinit_config" "config" {
  gzip = true
  base64_encode = true
  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = "${data.template_file.cloud_init.rendered}"
  }
}

resource "azurerm_linux_virtual_machine" "freeipa_vm" {
  name                = var.freeipa_hostname
  resource_group_name = azurerm_resource_group.freeipa_rg.name
  location            = azurerm_resource_group.freeipa_rg.location
  size                = "Standard_F4s"
  admin_username      = "azureuser"

  encryption_at_host_enabled = true

  network_interface_ids = [
    azurerm_network_interface.freeipa_nic.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "procomputers"
    offer     = "rocky-lnx-9-minimal"
    sku       = "rocky-linux-9-minimal"
    version   = "latest"
  }

  plan {
    name = "rocky-linux-9-minimal"
    product = "rocky-lnx-9-minimal"
    publisher = "procomputers"
    
  }

  identity {
    type = "SystemAssigned"
  }

  custom_data = data.template_cloudinit_config.config.rendered

  tags = {
    Environment = var.environment
    Location  = var.location
  }

  lifecycle {
    ignore_changes = [
      custom_data,
      tags
    ]
  }
}
