# ----------------------
# Route53
# ----------------------
# ゾーン
resource "aws_route53_zone" "route53_zone" {
  name          = var.domain
  force_destroy = false # 削除時にレコードを削除するかどうか

  tags = {
    Name    = "${var.project}-${var.environment}-domain"
    Project = var.project
    Env     = var.environment
  }
}
# Aレコード(ALBへのルーティングをマッピング用)
resource "aws_route53_record" "route53_record" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "dev-elb.${var.domain}"
  type    = "A"
  # AWSリソースへのルーティング
  alias {
    name                   = aws_lb.alb.dns_name # ALBのDNS名
    zone_id                = aws_lb.alb.zone_id  # ALBのZone ID
    evaluate_target_health = true              # ターゲットのヘルスチェックを有効にするかどうか
  }
}
