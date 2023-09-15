variable "location" {
  	default = "eastus"
}
variable "vm_size" {
  	default = "Standard_D1_v2"
}
variable "vm_username" {
  	default = "azureuser"
}
variable "vm_public_key" {
  	default = "~/.ssh/nnkhanh-GitHub.pub"
}
variable "vm_publisher" {
  	default = "Canonical"
}
variable "vm_offer" {
  	default = "UbuntuServer"
}
variable "vm_sku" {
  	default = "18.04-LTS"
}
variable "vm_version" {
  	default = "latest"
}