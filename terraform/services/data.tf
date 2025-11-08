# Reference compute outputs from the compute/ folder
data "terraform_remote_state" "compute" {
  backend = "local"
  config = {
    path = "../compute/terraform.tfstate"
  }
}

# Reference global outputs from the global/ folder
data "terraform_remote_state" "global" {
  backend = "local"
  config = {
    path = "../global/terraform.tfstate"
  }
}
