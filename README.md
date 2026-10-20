# Secure Cloud Networking Sandbox (Azure & Terraform)

## 🎯 Project Goal
Demonstrate an enterprise-grade cloud network deployment utilizing infrastructure as code (Terraform), strict firewall perimeter defense (Network Security Groups), and secure, credential-less remote management via Azure Bastion.

## 🏗️ Architecture Blueprint
The architecture creates a completely isolated hub-and-spoke virtual network topology inside the **Southeast Asia (Singapore)** region:
* **Perimeter Gateway:** Azure Bastion acts as an RDP/SSH TLS proxy, terminating public traffic and dropping interactions safely into the VNet over port 22.
* **Isolated Workloads:** The Ubuntu application server possesses **zero public IP address tracking**, neutralizing direct brute-force attack vectors from the public internet.
* **Network Security Group (NSG):** Associated with the private workload subnet, explicitly implementing an intentional whitelist rule that *only* accepts inbound port 22 traffic originating from the `AzureBastionSubnet` range, dropping all standard internet vectors.

## ⚙️ Tech Stack & Tooling
* **Cloud Platform:** Microsoft Azure
* **Infrastructure as Code:** Terraform (HCL)
* **Remote Management:** Azure Bastion Service, OpenSSH Key Pairs
* **Operating System:** Ubuntu Server 22.04 LTS
* **CI/CD Pipeline:** GitHub Actions

## 🚀 How to Run Locally
1. Authenticate with the Azure CLI:
   ```bash
   az login
   az account set --subscription "YOUR_SUBSCRIPTION_ID"
   ```
2. Provision the remote storage backend for the state files:
   ```bash
   az group create --name rg-terraform-state-prod --location eastus
   az storage account create --name sttfstateperimeter101 --resource-group rg-terraform-state-prod --location eastus --sku Standard_LRS --encryption-services blob
   az storage container create --name tfstate --account-name sttfstateperimeter101
   ```
3. Initialize and execute the Terraform pipeline:
   ```bash
   terraform init
   terraform apply -auto-approve
   ```
