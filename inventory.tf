data "terraform_remote_state" "example" {
  backend = "local"
  config = {
    path = "${path.module}/terraform.tfstate"
  }
}
