terraform {
  source = "../../"
}

inputs = {
  name        = "api"
  environment = "prod"
  description = "API service"
  visibility  = "private"
}
