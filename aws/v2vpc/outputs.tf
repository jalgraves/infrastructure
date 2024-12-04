
output "subnets" {
  value = module.vpc.subnets
}

output "vpc" {
  value = module.vpc.vpc
}

output "availability_zones" {
  value = module.vpc.availability_zones
}
