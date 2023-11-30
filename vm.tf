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
    freeipa_realm = var.freeipa_realm
    freeipa_domain = var.freeipa_domain
    freeipa_parent_hostname = var.freeipa_parent_hostname
    letsencrypt_email = var.letsencrypt_email
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
  name                = "${var.freeipa_hostname}.${var.dns_zone_name}"
  resource_group_name = azurerm_resource_group.freeipa_rg.name
  location            = azurerm_resource_group.freeipa_rg.location
  size                = var.vm_size
  admin_username      = "azureuser"

  encryption_at_host_enabled = true

  network_interface_ids = [
    azurerm_network_interface.freeipa_nic.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("${var.ssh_public_key_file}")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = var.vm_publisher
    offer     = var.vm_offer
    sku       = var.vm_sku
    version   = var.vm_version
  }

  plan {
    name = var.plan_name
    product = var.plan_product
    publisher = var.plan_publisher
    
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
