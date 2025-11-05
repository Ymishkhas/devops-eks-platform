locals {
  nat_public_ips_string = join(",", [for ip in module.vpc.nat_public_ips : format("%s/32", ip)])
}