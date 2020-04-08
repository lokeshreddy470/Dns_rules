provider "aws" {
  region = "us-east-1"
}

module "route53-outbound" {
  source            = "../terraform-aws-route53-endpoint"
  allowed_resolvers = ["192.168.100.10/32", "192.168.100.11/32"]
  direction         = "outbound"
  security_group_ids = ["sg-014f95dea8e2267fa"]
  vpc_id            = "vpc-ba9e00c0"

  ip_addresses      = [
    {
      subnet_id = "subnet-52a2eb7c"
    },
    {
      subnet_id = "subnet-dc3ea8e2"
    }
  ]
}


module "route53-rule-ad-corp" {
  source            = "../terraform-aws-route53-resolver-rule"
  associated_vpcs   = ["vpc-ba9e00c0"]
  forward_domain    = "ad.mycompany.com."
  forward_ips       = ["192.168.100.10", "192.168.100.11"]
  resolver_endpoint = "rslvr-out-291d3d1f4e3d4cf38"
}

/*
# AWS Route 53 Resolver rules
module "r53-resolver-rules" {
  #source           = "../rules/"
  source               = "git::https://github.com/lgallard/terraform-aws-route53-resolver-rules.git"
  resolver_endpoint_id = module.route53-outbound.endpoint_ids

  rules = [
    { 
      rule_name   = "r53r-rule-1"
      domain_name = "bar.foo."
      ram_name    = "ram-r53r-1"
      vpc_ids     = ["vpc-ba9e00c0"]
      ips         = ["192.168.10.10", "192.168.10.11:54"]
      principals  = ["123456789101", "101987654321"]
    }
  ]
}

*/
