locals {
  production-use1-ecr = {
    environment = "production"
    region      = "us-east-1"
    region_code = "use1"
    repositories = [
      "beantownpub",
      "thehubpub",
      "wavelengths",
      "drdavisicecream",
      "psql",
      "menu-api",
      "contact-api"
    ]
  }
}
