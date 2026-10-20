resource "azurerm_resource_group" "network_rg" {
    name = "rg-secure-sandbox-prod"
    location = "eastasia"
}

resource "azurerm_virtual_network" "vnet" {
    name = "vnet-sandbox-prod"
    address_space = ["10.0.0.0/16"]
    location = azurerm_resource_group.network_rg.location
    resource_group_name = azurerm_resource_group.network_rg.name
}

resource "azurerm_subnet" "bastion_subnet" {
    name = "AzureBastionSubnet"
    resource_group_name = azurerm_resource_group.network_rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "private_subnet" {
    name = "snet-private-workloads"
    resource_group_name = azurerm_resource_group.network_rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = ["10.0.2.0/24"]
}
resource "azurerm_public_ip" "bastion_pip" {
    name = "pip-bastion"
    location = azurerm_resource_group.network_rg.location
    resource_group_name = azurerm_resource_group.network_rg.name
    allocation_method = "Static"
    sku = "Standard"
}
resource "azurerm_bastion_host" "bastion" {
    name = "bastion-perimeter-service"
    location =azurerm_resource_group.network_rg.location
    resource_group_name = azurerm_resource_group.network_rg.name

    ip_configuration {
        name = "configuration"
        subnet_id = azurerm_subnet.bastion_subnet.id
        public_ip_address_id = azurerm_public_ip.bastion_pip.id
    }
}

resource "azurerm_network_security_group" "private_nsg" {
    name = "nsg-private-workloads"
    location = azurerm_resource_group.network_rg.location
    resource_group_name = azurerm_resource_group.network_rg.name

    security_rule {
        name = "AllowBastionSSHInbound"
        priority = 100
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "22"
        source_address_prefix = "10.0.1.0/24"
        destination_address_prefix = "*"
    }

    security_rule {
        name = "DenyAllInternetInbound"
        priority = 900
        direction = "Inbound"
        access = "Deny"
        protocol = "*"
        source_port_range = "*"
        destination_port_range = "*"
        source_address_prefix = "Internet"
        destination_address_prefix = "*"
    }
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
    subnet_id = azurerm_subnet.private_subnet.id
    network_security_group_id = azurerm_network_security_group.private_nsg.id
}

resource "azurerm_network_interface" "vm_nic" {
    name = "nic-linux-workload-asia"
    location = azurerm_resource_group.network_rg.location
    resource_group_name = azurerm_resource_group.network_rg.name

    ip_configuration {
        name = "internal"
        subnet_id = azurerm_subnet.private_subnet.id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_linux_virtual_machine" "linux_vm" {
    name = "vm-secure-linux"
    resource_group_name = azurerm_resource_group.network_rg.name
    location = azurerm_resource_group.network_rg.location
    size = "Standard_D2s_v5"
    admin_username = "sandboxadmin"
    network_interface_ids = [azurerm_network_interface.vm_nic.id]

    admin_ssh_key {
        username = "sandboxadmin"
        public_key = file("~/.ssh/id_rsa.pub")
    }

    os_disk {
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer = "0001-com-ubuntu-server-jammy"
        sku = "22_04-lts"
        version = "latest"
    }
}