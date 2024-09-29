data "terraform_remote_state" "example" {
  backend = "local"
  config = {
    path = "./terraform.tfstate"
  }
}

resource "local_file" "inventory" {
  content = <<EOF
[example]
${data.terraform_remote_state.example.outputs.instance_ip}
EOF
  filename = "${path.module}/inventory"
}
