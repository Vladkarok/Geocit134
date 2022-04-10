data "aws_route53_zone" "primary" {
  name = var.domain
}

resource "aws_route53_record" "geo" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = var.domain_web
  type    = "A"
  ttl     = "300"
  records = [google_compute_instance.geo_web.network_interface.0.access_config.0.nat_ip]
}

resource "aws_route53_record" "db_domain" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = var.domain_db
  type    = "A"
  ttl     = "300"
  records = [google_compute_instance.geo_db.network_interface.0.network_ip]
}
