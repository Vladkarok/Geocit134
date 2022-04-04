data "aws_route53_zone" "primary" {
  name = var.domain
}

resource "aws_route53_record" "geo" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = var.domain_web
  type    = "A"
  alias {
    name                   = aws_lb.geo_web.dns_name
    zone_id                = aws_lb.geo_web.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "db_domain" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = var.domain_db
  type    = "A"
  ttl     = "300"
  records = [aws_instance.Amazon_Linux_DB.private_ip]
}
