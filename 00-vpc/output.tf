output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.private_subnet_ids
}
output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "database_subnet_ids" {
  value = module.vpc.database_subnet_ids
}