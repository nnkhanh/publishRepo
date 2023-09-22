# generate a random string
resource "random_string" "azustring" {
  length  = 10
  special = false
  upper   = false
  numeric  = false
}

# generate a random pwd
resource "random_password" "password" {
  length      = 16
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
  special     = true
}