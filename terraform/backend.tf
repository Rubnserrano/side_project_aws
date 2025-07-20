terraform {
  backend "s3" {
    bucket         = "rubens-side-project-terraform-state"    # Debe ser un bucket que tú crees antes
    key            = "terraform.tfstate"
    region         = "eu-west-1"                              # Cambia a la región que uses
    dynamodb_table = "rubens-terraform-lock"                  # Tabla para bloqueo, debes crearla antes
    encrypt        = true
  }
}
