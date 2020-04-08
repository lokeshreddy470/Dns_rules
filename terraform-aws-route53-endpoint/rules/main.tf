resource "aws_route53_resolver_rule" "r" {
  count = length(local.rules)

  rule_type            = "FORWARD"
  resolver_endpoint_id = var.resolver_endpoint_id

  domain_name = lookup(element(local.rules, count.index), "domain_name", null)
  name        = lookup(element(local.rules, count.index), "rule_name", null)

  dynamic "target_ip" {
    for_each = lookup(element(local.rules, count.index), "ips", [])
    content {
      ip   = split(":", target_ip.value)[0]
      port = length(split(":", target_ip.value)) == 1 ? 53 : split(":", target_ip.value)[1]
    }
  }

  tags = var.tags
}

resource "aws_route53_resolver_rule_association" "ra" {
  count = length(local.vpcs_associations)
  resolver_rule_id = element(aws_route53_resolver_rule.r.*.id,
    index(aws_route53_resolver_rule.r.*.domain_name, lookup(element(local.vpcs_associations, count.index), "domain_name")
  ))
  vpc_id = lookup(element(local.vpcs_associations, count.index), "vpc_id")

  depends_on = [aws_route53_resolver_rule.r]
}
